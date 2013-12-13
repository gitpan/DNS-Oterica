use strict;
use warnings;
package DNS::Oterica::RecordMaker::Diagnostic;
{
  $DNS::Oterica::RecordMaker::Diagnostic::VERSION = '0.202';
}
# ABSTRACT: a collector of record generation requests, for testing

use Sub::Install;


my @types = qw(
  comment
  a_and_ptr
  ptr
  soa_and_ns_for_ip
  a
  mx
  domain
  soa_and_ns
  cname
  txt
);

for my $type (@types) {
  my $code = sub {
    return {
      type => $type,
      args => [ @_ ],
    };
  };

  Sub::Install::install_sub({ code => $code, as => $type });
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DNS::Oterica::RecordMaker::Diagnostic - a collector of record generation requests, for testing

=head1 VERSION

version 0.202

=head1 DESCRIPTION

This recordmaker returns hashrefs describing the requested record.

At present, the returned data are very simple.  They will change and improve
over time.

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
