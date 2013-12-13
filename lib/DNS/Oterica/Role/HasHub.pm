package DNS::Oterica::Role::HasHub;
{
  $DNS::Oterica::Role::HasHub::VERSION = '0.202';
}
use Moose::Role;
# ABSTRACT: any part of the dnso system that has a reference to the hub

use namespace::autoclean;

has hub => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Hub',
  weak_ref => 1,
  required => 1,
  # handles  => 'DNS::Oterica::Role::RecordMaker',
  handles  => [ qw(rec) ],
);

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DNS::Oterica::Role::HasHub - any part of the dnso system that has a reference to the hub

=head1 VERSION

version 0.202

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
