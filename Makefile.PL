use strict;

use ExtUtils::MakeMaker;


my %args = (
    NAME => 'Object::Instant',
    VERSION_FROM => 'lib/Object/Instant.pm',
    PREREQ_PM => {
    },
    LIBS => [],
    DEFINE => '',
    LICENSE => 'perl',
    dist => {
      PREOP => 'pod2text $(VERSION_FROM) > $(DISTVNAME)/README',
    },
    META_MERGE => {
      resources => {
        repository => 'git://github.com/hoytech/Object-Instant.git',
        bugtracker => 'https://github.com/hoytech/Object-Instant/issues',
      },
    },
);

WriteMakefile(%args);
