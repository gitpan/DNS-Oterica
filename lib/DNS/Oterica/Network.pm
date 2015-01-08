package DNS::Oterica::Network;
# ABSTRACT: a network to which results are served
$DNS::Oterica::Network::VERSION = '0.205';
use Moose;

use Net::IP;
use Moose::Util::TypeConstraints;

# TODO: move these to a types library
subtype 'DNS::Oterica::Type::Network'
  => as Object
  => where { $_->isa('Net::IP') };

coerce 'DNS::Oterica::Type::Network'
  => from 'Str'
  => via { Net::IP->new($_) || confess( Net::IP::Error() ) };

#pod =head1 OVERVIEW
#pod
#pod Networks are IP networks to which results are served, and can be used to
#pod implement split horizons.
#pod
#pod Like other DNS::Oterica objects, they should be created through the hub.
#pod
#pod =attr name
#pod
#pod This is the network's unique name.
#pod
#pod =cut

has name => (is => 'ro', isa => 'Str', required => 1);

#pod =attr subnet
#pod
#pod This is the C<Net::IP> range for the network at this network.
#pod
#pod =cut

has subnet => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Type::Network',
  required => 1,
  coerce   => 1,
);

sub _class_prefixes {
  my ($self, $ip) = @_; # $ip arg for testing

  $ip ||= $self->subnet;
  my $pl    = $ip->prefixlen;
  my $class = int( $pl / 8 );
  my @quads = split /\./, $ip->ip;
  my @keep  = splice @quads, 0, $class;
  my $fixed = join q{.}, @keep;
  my $bits  = 8 - ($pl - $class * 8);

  return $fixed if $bits == 8;

  my @prefixes = map {; "$fixed.$_" } (0 .. (2**$bits - 1));
  return @prefixes;
}

sub as_data_lines {
  my ($self) = @_;
  $self->hub->rec->location($self);
}

# Do we really want to keep this?
has delegated => (is => 'ro', isa => 'Bool', required => 0, default => 0);

has code => (is => 'ro', isa => 'Str', required => 1);

with 'DNS::Oterica::Role::HasHub';

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DNS::Oterica::Network - a network to which results are served

=head1 VERSION

version 0.205

=head1 OVERVIEW

Networks are IP networks to which results are served, and can be used to
implement split horizons.

Like other DNS::Oterica objects, they should be created through the hub.

=head1 ATTRIBUTES

=head2 name

This is the network's unique name.

=head2 subnet

This is the C<Net::IP> range for the network at this network.

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
