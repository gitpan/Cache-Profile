
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Measure the performance of a cache',
  'AUTHOR' => 'Yuval Kogman',
  'BUILD_REQUIRES' => {
    'CHI' => '0',
    'Cache::Bounded' => '0',
    'Cache::FastMmap' => '0',
    'Cache::MemoryCache' => '0',
    'Cache::Ref::CART' => '0',
    'Cache::Ref::CLOCK' => '0',
    'Cache::Ref::FIFO' => '0',
    'Cache::Ref::LRU' => '0',
    'List::Util' => '0',
    'Test::More' => '0',
    'ok' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Cache-Profile',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Cache::Profile',
  'PREREQ_PM' => {
    'CHI' => '0',
    'Cache::Bounded' => '0',
    'Cache::FastMmap' => '0',
    'Cache::MemoryCache' => '0',
    'Cache::Ref' => '0',
    'Carp' => '0',
    'Class::MOP' => '0',
    'Guard' => '0',
    'Moose' => '0',
    'Time::HiRes' => '0',
    'Try::Tiny' => '0',
    'namespace::autoclean' => '0'
  },
  'VERSION' => '0.02',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



