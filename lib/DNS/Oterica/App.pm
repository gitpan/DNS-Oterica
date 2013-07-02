package DNS::Oterica::App;
{
  $DNS::Oterica::App::VERSION = '0.201';
}
# ABSTRACT: the code behind `dnsoterica`

use Moose;
use DNS::Oterica::Hub;
use File::Find::Rule;
use YAML::XS ();


has hub => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Hub',
  writer    => '_set_hub',
  predicate => '_has_hub',
);

sub BUILD {
  my ($self, $arg) = @_;

  confess "both hub and hub_args provided"
    if $self->_has_hub and $arg->{hub_args};

  unless ($self->_has_hub) {
    my %args = %{$arg->{hub_args}};
    $self->_set_hub( DNS::Oterica::Hub->new(\%args || {}) );
  }
}


has root => (
  is       => 'ro',
  required => 1,
);

sub populate_networks {
  my ($self) = @_;

  my $root = $self->root;
  for my $file (File::Find::Rule->file->in("$root/networks")) {
    for my $data (YAML::XS::LoadFile($file)) {
      $self->hub->add_network($data);
    }
  }
}

sub populate_domains {
  my ($self) = @_;
  my $root = $self->root;
  for my $file (File::Find::Rule->file->in("$root/domains")) {
    for my $data (YAML::XS::LoadFile($file)) {
      my $node = $self->hub->domain(
        $data->{domain},
      );

      for my $name (@{ $data->{families} }) {
        my $family = $self->hub->node_family($name);

        $node->add_to_family($family);
      }
    }
  }
}

sub populate_hosts {
  my ($self) = @_;
  my $root = $self->root;
  my $hub  = $self->hub;

  for my $file (File::Find::Rule->file->in("$root/hosts")) {
    for my $data (YAML::XS::LoadFile($file)) {
      my $interfaces;
      if (ref $data->{ip}) {
        $interfaces = [
          map {;
            [
            $data->{ip}{$_} => $hub->network($_) ]
          } keys %{ $data->{ip}}
        ];
      } else {
        $interfaces = [
          [ $data->{ip} => $hub->network( $hub->all_network_name ) ]
        ];
      }

      my $node = $hub->host(
        $data->{domain},
        $data->{hostname},
        {
          interfaces => $interfaces,
          location   => $data->{location},
          aliases    => $data->{aliases} || [],
          (exists $data->{ttl} ? (ttl => $data->{ttl}) : ()),
        },
      );

      for my $name (@{ $data->{families} }) {
        my $family = $hub->node_family($name);

        $node->add_to_family($family);
      }
    }
  }
}

1;

__END__

=pod

=head1 NAME

DNS::Oterica::App - the code behind `dnsoterica`

=head1 VERSION

version 0.201

=head1 ATTRIBUTES

=head2 hub

This is the L<DNS::Oterica::Hub> into which entries will be loaded.

=head2 root

This is a directory in which F<dnsoterica> will look for configuration files.

It will look in the subdirectory F<domains> for domain definitions and F<hosts>
for hosts.

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
