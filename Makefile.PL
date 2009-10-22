
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'DNS-Oterica',
  NAME      => 'DNS::Oterica',
  AUTHOR    => "Ricardo\ SIGNES\ \<rjbs\@cpan\.org\>",
  ABSTRACT  => "DNS\:\:Oterica\ generates\ DNS\ records\ given\ structured\ data",
  VERSION   => '0.092950',
  EXE_FILES => [ qw(bin/dnsoterica) ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "File::Find::Rule" => '0',
    "Module::Pluggable" => '0',
    "Net::IP" => '0',
    "YAML::XS" => '0',
    "IPC::System::Simple" => '0',
    "autodie" => '0',
    "Getopt::Long::Descriptive" => '0',
    "Moose" => '0',
    "File::Slurp" => '0',
  },
  test => {TESTS => 't/*.t'}
);

