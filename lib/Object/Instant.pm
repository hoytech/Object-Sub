package Object::Instant;

use strict;

our $VERSION = '0.100';

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


1;



__END__

=encoding utf-8

=head1 NAME

Object::Instant - Create objects without those pesky classes

=head1 SYNOPSIS

    use Object::Instant;

    my $obj = Object::Instant->new(sub {
                  my ($self, $method, @args) = @_;

                  print "method name: $method, first arg: $args[0]\n";
              });

    $obj->whatever(123);
    ## self: Object::Instant=HASH(0xc78eb0), method name: whatever, first arg: 123

=head1 DESCRIPTION

Sometimes you want something that acts like an object but you don't want to go to all the trouble to create a new package, constructor, methods, etc. This module is a trivial wrapper around perl's L<AUTOLOAD> functionality that allows us to intercept method calls.

=head1 USE-CASES

=head2 AUTOLOAD SYNTACTIC SUGAR

L<AUTOLOAD> allows you to dispatch on method names at run-time which can sometimes be quite useful, for example in RPC protocols where you transmit method call messages to another process or server for them to be executed remotely. Unfortunately, using L<AUTOLOAD> is a bit annoying since the interface is somewhat arcane. L<Object::Instance> is a nicer interface to the most commonly used AUTOLOAD functionality:

    my $obj = Object::Instant->new(sub {
                my ($self, $method, @args) = @_;

                my $rpc_input = encode_json({ method => $method, args => [ @args ] });

                my $rpc_output = do_rpc_call($rpc_input);

                return decode_json($rpc_output);
              });

=head2 PLACE-HOLDER OBJECTS

Some APIs require you to pass in or provide an object but don't actually end up using it. Instead of passing in undef and getting a weird C<Can't call method "XYZ" on an undefined value> error, you can pass in an L<Object::Instant> that will throw a helpful exception instead:

    my $obj = Some::Api->new(
                error_logger => Object::Instant->new(sub {
                                  die "Please provide an 'error_logger' object to Some::API"
                                })
              );

=head2 LAZY OBJECT CREATION

Again, some APIs may never end up using an object so you may wish to "lazily" defer the creation of that object until a method is actually called on it.

For example, suppose you have a large L<CGI> script that creates a L<DBI> connection at the start of the script, but only actually accesses the database handle for a small portion of the requests. You can prevent the script from accessing the database on the majority of requests with L<Object::Instant>:

    my $dbh = Object::Instant->new(sub {
                $_[0] = DBI->connect($dsn, $user, $pass, { RaiseError => 1)
                    || die "Unable to connect to database: $DBI::errstr";

                my ($self, $method, @args) = @_;

                return $self->$method(@args);
              });

This works because the C<$_[0]> argument is actually an alias to C<$dbh>. After you call a method on C<$dbh> for the first time it will change from a C<Object::Instant> object into a C<DBI> object (assuming the C<< DBI->connect >> constructor succeeds).

=head1 SEE ALSO

L<Object-Instant github repo|https://github.com/hoytech/Object-Instant>

=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2015 Doug Hoyte.

This module is licensed under the same terms as perl itself.
