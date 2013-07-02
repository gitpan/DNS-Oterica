package DNS::Oterica::Hub;
{
  $DNS::Oterica::Hub::VERSION = '0.201';
}
# ABSTRACT: the center of control for a DNS::Oterica system

use Moose;
with 'DNS::Oterica::Role::RecordMaker';

# use MooseX::AttributeHelpers;

use DNS::Oterica::Network;
use DNS::Oterica::Node;
use DNS::Oterica::Node::Domain;
use DNS::Oterica::Node::Host;
use DNS::Oterica::NodeFamily;


has [ qw(_domain_registry _net_registry _node_family_registry) ] => (
  is  => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default  => sub { {} },
);


has ns_family => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);


has hostmaster => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub soa_rname {
  my ($self) = @_;
  my $addr = $self->hostmaster;
  $addr =~ s/@/./;
  return $addr;
}

use Module::Pluggable
  search_path => [ qw(DNS::Oterica::NodeFamily) ],
  require     => 1;

has fallback_network_name => (is => 'ro', isa => 'Str', default => 'FALLBACK');
has all_network_name   => (is => 'ro', isa => 'Str', default => 'ALL');

sub BUILD {
  my ($self) = @_;

  for my $plugin ($self->plugins) {
    confess "tried to register " . $plugin->name . " twice" if exists
      $self->_node_family_registry->{$plugin->name};
    $self->_node_family_registry->{ $plugin->name }
        = $plugin->new({ hub => $self });
  }

  $self->add_network({
    name => $self->fallback_network_name,
    code => 'FB', # should it be configurable?  eh.
    subnet => '0.0.0.0/0',
  });

  $self->add_network({
    name => $self->all_network_name,
    code => '',
    subnet => '0.0.0.0/32',
  });
}


sub domain {
  my ($self, $name, $arg) = @_;
  my $domreg = $self->_domain_registry;

  confess "tried to create domain $name twice" if $domreg->{$name} and $arg;

  # XXX: This should be possible to do. -- rjbs, 2009-09-11
  # confess "no such domain: $name" if ! defined $arg and ! $domreg->{$name};

  return $domreg->{$name} ||= DNS::Oterica::Node::Domain->new({
    domain => $name,
    %{ $arg || {} },
    hub    => $self,
  });
}


sub network {
  my ($self, $name) = @_;
  return $self->_net_registry->{$name} || confess "no such network '$name'";
}


sub networks {
  my ($self) = @_;
  return values %{ $self->_net_registry };
}


sub add_network {
  my ($self, $arg) = @_;

  my $net = DNS::Oterica::Network->new({ %$arg, hub => $self });

  my $name = $net->name;
  confess "tried to create $name twice" if $self->_net_registry->{$name};

  my $code = $net->code;
  my $ip   = $net->subnet;

  my @errors;
  for my $existing ($self->networks) {
    if ($net->code eq $existing->code) {
      push @errors, sprintf "code '%s' conflicts with network %s",
        $code, $existing->name;
    }

    next if $existing->name eq $self->all_network_name;

    if ($ip->overlaps($existing->subnet) == $Net::IP::IP_IDENTICAL) {
      push @errors, sprintf "network '%s' conflicts with network %s (%s)",
        $ip->ip, $existing->name, $existing->subnet->ip;
    }
  }

  if (@errors) {
    confess("errors registering network $name: " . join q{; }, @errors);
  }

  $self->_net_registry->{$name} = $net;
}


sub host {
  my ($self, $domain_name, $name, $arg) = @_;
  my $domain = $self->domain($domain_name);

  confess "tried to create $name . $domain_name twice"
    if $domain->{$name} and $arg;

  return $domain->{nodes}{$name} ||= DNS::Oterica::Node::Host->new({
    domain   => $domain_name,
    hostname => $name,
    %$arg,
    hub      => $self,
  });
}


sub nodes {
  my ($self) = @_;

  my @nodes;

  for my $domain (values %{ $self->_domain_registry }) {
    push @nodes, values %{ $domain->{nodes} || {} };
  }

  return @nodes;
}


sub node_family {
  my ($self, $name) = @_;

  return $self->_node_family_registry->{$name}
      || confess "unknown family $name";
}


sub node_families {
  my ($self) = @_;
  return values %{ $self->_node_family_registry };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=head1 NAME

DNS::Oterica::Hub - the center of control for a DNS::Oterica system

=head1 VERSION

version 0.201

=head1 OVERVIEW

The hub is the central collector of DNS::Oterica data.  All new entries are
given to the hub to collect.  The hub takes care of preventing duplicates and
keeping data synchronized.

=head1 ATTRIBUTES

=head2 ns_family

This is the name of the family whose hosts will be used for NS records for
hosts and in SOA lines.

=head2 hostmaster

This is the email address to be used as the contact point in SOA lines.

=head1 METHODS

=head2 domain

  my $new_domain = $hub->domain($name => \%arg);

  my $domain = $hub->domain($name);

This method will return a domain found by name, or if C<\%arg> is given, will
create a new domain.

If no domain is found and C<\%arg> is not given, an exception is raised.

If C<\%arg> is given for a domain that already exists, an exception is raised.

=head2 network

  my $net = $hub->network($name);

This method finds the named network and returns it.  If no network for the
given name is registered, an exception is raised.

=head2 networks

  my @net = $hub->networks;

=head2 add_network

  my $net = $hub->add_network(\%arg);

This registers a new network, raising an exception if one already exists for
the given name.

=head2 host

  my $host = $hub->host($domain_name, $hostname);

  my $new_host = $hub->host($domain_name, $hostname, \%arg);

This method will find or create a host, much like the C<L</domain>> method.

=head2 nodes

This method will return a list of all nodes registered with the system.

B<Warning>: at present this will return only hosts.

=head2 node_family

  my $family = $hub->node_family($family_name);

This method will return the named familiy.  If no such family exists, an
exception will be raised.

=head2 node_families

  my @families = $hub->node_families;

This method will return all node families.  (These are set up during hub
initialization.)

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
