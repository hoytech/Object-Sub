use strict;

use Test::More tests => 7;

use Object::Instant;



{
  my $o = Object::Instant->new(sub {
    my ($self, $method, @args) = @_;

    is(ref $self, 'Object::Instant');
    is($method, 'hello');
    is($args[0], 'world');
  });

  $o->hello('world');
}




## Test class

{
  package Object::Instant::Test::Counter;

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
  my $o = Object::Instant->new(sub {
            $_[0] = Object::Instant::Test::Counter->new();

            my ($self, $method, @args) = @_;

            return $self->$method(@args);
          });

  is (ref $o, 'Object::Instant');

  is ($o->add(4), 4);

  is (ref $o, 'Object::Instant::Test::Counter');

  is ($o->add(1), 5);
}
