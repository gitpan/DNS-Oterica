package DNS::Oterica::Location;
our $VERSION = '0.092570';

# ABSTRACT: a location at which hosts may reside
use Moose;

use Net::IP;
use Moose::Util::TypeConstraints;

# TODO: move these to a types library
subtype 'DNS::Oterica::Type::Network'
  => as Object
  => where { $_->isa('Net::IP') };

coerce 'DNS::Oterica::Type::Network'
  => from 'Str'
  => via { Net::IP->new($_) };


has name => (is => 'ro', isa => 'Str', required => 1);


has 'network' => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Type::Network',
  required => 0,
  coerce   => 1,
);

# Do we really want to keep this?
has delegated => (is => 'ro', isa => 'Bool', required => 0, default => 0);

has code => (is => 'ro', isa => 'Str', required => 1);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=head1 NAME

DNS::Oterica::Location - a location at which hosts may reside

=head1 VERSION

version 0.092570

=head1 OVERVIEW

Locations are network locations where hosts may be found.  They represent
unique IP ranges with unique names.

Like other DNS::Oterica objects, they should be created through the hub.

=head1 ATTRIBUTES

=head2 name

This is the location's unique name.

=head2 network

This is the C<Net::IP> range for the network at this location.

=head1 AUTHOR

  Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 


