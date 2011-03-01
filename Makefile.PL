
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'build dns configuration more easily',
  'AUTHOR' => 'Ricardo SIGNES <rjbs@cpan.org>',
  'BUILD_REQUIRES' => {
    'Carp' => '0',
    'IPC::System::Simple' => '0',
    'Test::More' => '0.96',
    'autodie' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'DNS-Oterica',
  'EXE_FILES' => [
    'bin/dnsoterica'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'DNS::Oterica',
  'PREREQ_PM' => {
    'File::Find::Rule' => '0',
    'File::Slurp' => '0',
    'Getopt::Long::Descriptive' => '0',
    'IPC::System::Simple' => '0',
    'Module::Pluggable' => '0',
    'Moose' => '0',
    'Moose::Role' => '0',
    'Moose::Util::TypeConstraints' => '0',
    'Net::IP' => '0',
    'Sub::Install' => '0',
    'YAML::XS' => '0',
    'autodie' => '0'
  },
  'VERSION' => '0.100000',
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



