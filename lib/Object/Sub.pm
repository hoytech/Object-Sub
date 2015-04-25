package Object::Sub;

use strict;

our $VERSION = '0.101';

our $AUTOLOAD;


sub new {
  my ($class, $cb) = @_;

  die "need a callback" if ref $cb ne 'CODE';

  my $self = { cb => $cb, };
  bless $self, $class;

  return $self;
}

sub AUTOLOAD {
  die "$_[0] is not an object" if !ref $_[0];

  my $name = $AUTOLOAD;
  $name =~ s/.*://;

  return $_[0]->{cb}->($_[0], $name, @_[1 .. $#_]);
}

## Prevent DESTROY method from being handled by AUTOLOAD

sub DESTROY {
}


1;



__END__

=encoding utf-8

=head1 NAME

Object::Sub - Create objects without those pesky classes

=head1 SYNOPSIS

    use Object::Sub;

    my $obj = Object::Sub->new(sub {
                  my ($self, $method, @args) = @_;

                  print "self: $self, method name: $method, first arg: $args[0]\n";
              });

    $obj->whatever(123);
    ## self: Object::Sub=HASH(0xc78eb0), method name: whatever, first arg: 123

=head1 DESCRIPTION

Sometimes you want something that acts like an object but you don't want to go to all the trouble of creating a new package, with constructor and methods and so on. This module is a trivial wrapper around perl's L<AUTOLOAD> functionality which intercepts method calls and lets you handle them in a single C<sub>.

=head1 USE-CASES

=head2 AUTOLOAD SYNTACTIC SUGAR

L<AUTOLOAD> allows you to dispatch on method names at run-time which can sometimes be useful, for example in RPC protocols where you transmit method call messages to another process for them to be executed remotely. Unfortunately, using L<AUTOLOAD> is a bit annoying since the interface is somewhat arcane. L<Object::Instance> is a nicer interface to the most commonly used AUTOLOAD functionality:

    my $obj = Object::Sub->new(sub {
                my ($self, $method, @args) = @_;

                my $rpc_input = encode_json({ method => $method, args => [ @args ] });

                my $rpc_output = do_rpc_call($rpc_input);

                return decode_json($rpc_output);
              });

=head2 PLACE-HOLDER OBJECTS

Some APIs require you to pass in or provide an object but then don't actually end up using it. Instead of passing in undef and getting a weird C<Can't call method "XYZ" on an undefined value> error, you can pass in an L<Object::Sub> which will throw a helpful exception instead:

    my $obj = Some::API->new(
                error_logger => Object::Sub->new(sub {
                                  die "Please provide an 'error_logger' object to Some::API"
                                })
              );

=head2 LAZY OBJECT CREATION

Again, some APIs may never end up using an object so you may wish to "lazily" defer the creation of that object until a method is actually called on it.

For example, suppose you have a large L<CGI> script which always opens a L<DBI> connection but only actually accesses this connection for a small portion of runs. You can prevent the script from accessing the database on the majority of runs with L<Object::Sub>:

    my $dbh = Object::Sub->new(sub {
                require DBI;
                $_[0] = DBI->connect($dsn, $user, $pass, { RaiseError => 1 })
                    || die "Unable to connect to database: $DBI::errstr";

                my ($self, $method, @args) = @_;
                return $self->$method(@args);
              });

This works because the C<$_[0]> argument is actually an alias to C<$dbh>. After you call a method on C<$dbh> for the first time it will change from a C<Object::Sub> object into a C<DBI> object (assuming the C<< DBI->connect >> constructor succeeds).

To demonstrate this, here is an example with L<Session::Token>:

    my $o = Object::Sub->new(sub {
              require Session::Token;
              $_[0] = Session::Token->new;

              my ($self, $method, @args) = @_;
              return $self->$method(@args);
            });

    say ref $o;
    ## Object::Sub

    say $o->get;
    ## mhDPtfLlFMGl5kyNcJgFt7

    say ref $o;
    ## Session::Token


=head1 SEE ALSO

L<Object-Sub github repo|https://github.com/hoytech/Object-Sub>

=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2015 Doug Hoyte.

This module is licensed under the same terms as perl itself.
