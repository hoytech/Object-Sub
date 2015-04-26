use strict;

use Test::More tests => 18;

use Object::Sub;



{
  my $o = Object::Sub->new(sub {
    my ($self, $method, @args) = @_;

    is(ref $self, 'Object::Sub');
    is($method, 'hello');
    is($args[0], 'world');
  });

  $o->hello('world');
}








## Test class

{
  package Object::Sub::Test::Counter;

  sub new {
    my ($class, @args) = @_;

    my $self = {
      count => 0,
    };
    bless $self, $class;
  }

  sub add {
    my ($self, $amount) = @_;

    $self->{count} += $amount;

    return $self->{count};
  }

  sub get {
    my ($self) = @_;

    return $self->{count};
  }
}


{
  my $o = Object::Sub->new(sub {
            $_[0] = Object::Sub::Test::Counter->new();

            my ($self, $method, @args) = @_;

            return $self->$method(@args);
          });

  is (ref $o, 'Object::Sub');

  is ($o->add(4), 4);

  is (ref $o, 'Object::Sub::Test::Counter');

  is ($o->add(1), 5);

  is ($o->get(), 5);
}



## Invoked as sub

{
  my $o = Object::Sub->new(sub {
    my ($self, $method, @args) = @_;

    is(ref $self, 'Object::Sub');
    is($method, undef);
    is($args[0], 'hello');
    is($args[1], 'world');
  });

  $o->('hello', 'world');
}



{
  my $o = Object::Sub->new(sub {
    $_[0] = sub { return "AFTER" };

    return "BEFORE";
  });

  is($o->(), "BEFORE");
  is($o->(), "AFTER");
}




## Can use either methods or subs

{
  my $o = Object::Sub->new(sub {
    my ($self, $method, @args) = @_;

    is ($args[0], 123);

    return $method;
  });

  is ($o->(123), undef);
  is ($o->hello(123), 'hello');
}
