package DNS::Oterica::Node::Host;
our $VERSION = '0.092541';

# ABSTRACT: a host node
use Moose;
extends 'DNS::Oterica::Node';


has hostname => (is => 'ro', isa => 'Str', required => 1);


has aliases  => (
  is => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
  default    => sub { [] },
);


has interfaces => (
  is  => 'ro',
  isa => 'ArrayRef',
  required   => 1,
  auto_deref => 1,
);


has location => (is => 'ro', isa => 'Str', required => 1);


sub world_ip {
  my ($self) = @_;
  my ($if) = grep { $_->[1]->name eq 'world' } $self->interfaces;
  $if->[0];
}


sub fqdn {
  my ($self) = @_;
  sprintf '%s.%s', $self->hostname, $self->domain;
}

sub _family_names {
  my ($self) = @_;
  my @all_families = $self->hub->node_families;
  my @has_self = grep { grep { $_ == $self } $_->nodes } @all_families;

  return map { $_->name } @has_self;
}

sub as_data_lines {
  my ($self) = @_;

  my @lines = $self->rec->comment("begin host ". $self->fqdn);

  push @lines, $self->rec->comment(
    "  families: " . join(q{, }, $self->_family_names)
  );

  push @lines, $self->rec->a_and_ptr({ name => $self->fqdn, node => $self });
  push @lines, $self->rec->a({ name => $_, node => $self }) for $self->aliases;

  push @lines, $self->rec->comment("end host ". $self->fqdn . "\n");

  return @lines;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=head1 NAME

DNS::Oterica::Node::Host - a host node

=head1 VERSION

version 0.092541

=head1 OVERVIEW

C<DNS::Oterica::Node::Host> represents an individual machine in DNS::Oterica.
A node has interfaces (which have IP addresses), a network location, and is
part of a named domain.

=head1 ATTRIBUTES

=head2 hostname

This is the name of the host.  B<It does not include the domain name.>

=head2 aliases

This is an arrayref of other fully-qualified names that refer to this host.

=head2 interfaces

This is an arrayref of pairs, each one an IP address and a location.

This attribute is pretty likely to change later.

=head2 location

The name of the network location of this host

=head1 METHODS

=head2 world_ip

The C<world> location IP address for this host.

=head2 fqdn

This is the fully-qualified domain name of this host.

=head1 AUTHOR

  Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 


