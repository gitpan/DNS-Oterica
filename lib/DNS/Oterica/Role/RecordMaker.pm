package DNS::Oterica::Role::RecordMaker;
BEGIN {
  $DNS::Oterica::Role::RecordMaker::VERSION = '0.100001';
}
use Moose::Role;
# ABSTRACT: a delegation class for the DNSO recordmaker.

use DNS::Oterica::RecordMaker::TinyDNS;


has rec => (
  is  => 'ro',
  isa => 'Str', # XXX or object doing role, etc
  default => 'DNS::Oterica::RecordMaker::TinyDNS',
);

no Moose::Role;
1

__END__
=pod

=head1 NAME

DNS::Oterica::Role::RecordMaker - a delegation class for the DNSO recordmaker.

=head1 VERSION

version 0.100001

=head1 DESCRIPTION

C<DNS::Oterica::Role::RecordMaker> delegates to an underlying record maker. It
exposes this record maker with its C<rec> method.

=head1 ATTRIBUTES

=head2 rec

The record maker, e.g. L<DNS::Oterica::RecordMaker::TinyDNS>.

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

