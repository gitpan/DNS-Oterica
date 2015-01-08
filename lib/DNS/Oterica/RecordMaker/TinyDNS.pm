use strict;
use warnings;
package DNS::Oterica::RecordMaker::TinyDNS;
# ABSTRACT: a tinydns recordmaker for DNSO.
$DNS::Oterica::RecordMaker::TinyDNS::VERSION = '0.205';
#pod =head1 DESCRIPTION
#pod
#pod This role provides logic for generating lines for the F<tinydns-data> program
#pod to consume.
#pod
#pod =cut

sub _default_ttl { 1800 }

sub _serial_number {
  return($ENV{DNS_OTERICA_SN} || $^T)
}

#pod =method comment
#pod
#pod   my $line = $rec->comment("Hello, world!");
#pod
#pod This returns a line that is a one-line commment.
#pod
#pod =cut

sub comment {
  my ($self, $comment) = @_;

  return "# $comment\n";
}

#pod =method location
#pod
#pod This returns a location line.
#pod
#pod =cut

sub location {
  my ($self, $location) = @_;

  return if $location->code eq '';

  Carp::confess("location codes must be two-character")
    unless length $location->code == 2;

  my @prefixes = $location->_class_prefixes;
  map { sprintf "%%%s:%s\n", $location->code, $_ } @prefixes;
}

sub __ip_locode_pairs {
  my ($self, $rec) = @_;

  Carp::confess('no node provided') unless $rec->{node};

  return
    map  {; [ $_->[0] => $_->[1]->code ] }
    $rec->{node}->interfaces;
}

sub _generic {
  my ($self, $op, $rec) = @_;

  my @lines;
  for my $if ($self->__ip_locode_pairs($rec)) {
    push @lines, sprintf "%s%s:%s:%s:%s:%s\n",
      $op,
      $rec->{name},
      $if->[0],
      $rec->{ttl} || $self->_default_ttl,
      $self->_serial_number,
      $if->[1],
    ;
  }

  return @lines;
}

#pod =method a_and_ptr
#pod
#pod Generate an C<=> line, the bread and butter A and PTR record pair for a
#pod hostname and IP.
#pod
#pod =cut

# =fqdn:ip:ttl:timestamp:lo
sub a_and_ptr {
  my ($self, $rec) = @_;

  return (
    $self->_generic(q{+}, $rec),
    $self->ptr($rec),
  );
}

#pod =method ptr
#pod
#pod Generate an C<^> line, for the reverse DNS of an IP address.
#pod
#pod =cut

# ^fqdn:ip:ttl:timestamp:lo
# can't use __generic here because it wants to look at interfaces, and we want
# the reverse of that
sub ptr {
  my ($self, $rec) = @_;

    my @lines;
    for my $if ($self->__ip_locode_pairs($rec)) {
      my $ip = $if->[0];
      my @bytes = reverse split /\./, $ip;

      splice @bytes, 1, 1, '0-24', $bytes[1] unless $bytes[-1] eq '10';

      my $extended_arpa = join '.', @bytes, 'in-addr', 'arpa';
      push @lines, sprintf "^%s:%s:%s:%s:%s\n",
        $extended_arpa,
        $rec->{name},
        $rec->{ttl} || $self->_default_ttl,
        $self->_serial_number,
        $if->[1] eq 'FB' ? '' : $if->[1];
    }
    return @lines;
}

# TODO find out why we generate Z and & records for our IPs and refactor this
# to not duplicate effort with &ptr and the like. problem is that &a calls &ptr
# so having the code there means it gets called for every time we generate a +
# record, totally not what we want. What we want is for this to be called once
# for every IP address, not every hostname.
sub soa_and_ns_for_ip {
  my ($self, $rec) = @_;

  my @lines;
  my $node = $rec->{node};
  my $ns_f = $node->hub->ns_family;
  my %ns   = $node->hub->node_family($ns_f)->ns_nodes;
  my $ns_1 = (keys %ns)[0];
  my $addr = $node->hub->soa_rname;
  my $ip   = $rec->{ip};
  my @bytes = reverse split /\./, $ip;
  my $arpa = join '.', @bytes, 'in-addr', 'arpa';

  push @lines, sprintf "Z%s:%s:%s::::::%s:%s:%s\n",
    $arpa,
    $ns_1,
    $addr,
    $self->_default_ttl,
    $self->_serial_number,
    '',
  ;

  for my $ns (keys %ns) {
    push @lines, $self->domain({
      domain => $arpa,
      ip     => $ip,
      ns     => $ns,
    });
  }
  return @lines;
}

# +fqdn:ip:ttl:timestamp:lo
sub a {
  my ($self, $rec) = @_;
  my @lines = $self->_generic(q{+}, $rec);

  return @lines;
}

# @fqdn:ip:x:dist:ttl:timestamp:lo
sub mx {
  my ($self, $rec) = @_;

  my @lines;

  my $mx_name = defined $rec->{mx} ? $rec->{mx}
              : $rec->{node}       ? $rec->{node}->fqdn
              : Carp::confess('neither mx nor node given as mx for mx record');

  for my $if ($self->__ip_locode_pairs($rec)) {
    push @lines, sprintf "@%s:%s:%s:%s:%s:%s:%s\n",
      $rec->{name},
      ($rec->{no_ip} ? '' : $if->[0]),
      $mx_name,
      $rec->{dist} || 10,
      $rec->{ttl} || $self->_default_ttl,
      $self->_serial_number,
      $if->[1],
    ;
  }

  return @lines;
}

# .fqdn:ip:x:ttl:timestamp:lo
# This doesn't handle nodes, because I don't want to deal with ip-less records,
# which would cause __generic to barf.  This is just a hack for now.
# -- rjbs, 2008-12-15
sub domain {
  my ($self, $rec) = @_;

  my @lines;

  push @lines, sprintf "&%s:%s:%s:%s:%s:%s\n",
    $rec->{domain},
    $rec->{ip} || '',
    $rec->{ns},
    $rec->{ttl} || $self->_default_ttl,
    $self->_serial_number,
    '',
  ;

  return @lines;
}

sub soa_and_ns {
  my ($self, $rec) = @_;

  my @lines;

  push @lines, sprintf "Z%s:%s:%s::::::%s:%s:%s\n",
    $rec->{domain},
    $rec->{ns} || '',
    $rec->{node}->hub->soa_rname,
    $rec->{ttl} || $self->_default_ttl,
    $self->_serial_number,
    '',
  ;

  return @lines;
}


# Cfqdn:p:ttl:timestamp:lo
sub cname {
  my ($self, $rec) = @_;

  my @lines;

  push @lines, sprintf "C%s:%s:%s:%s:%s\n",
    $rec->{cname},
    $rec->{domain} || '',
    $rec->{ttl} || $self->_default_ttl,
    $self->_serial_number,
    '',
  ;

  return @lines;
}

sub txt {
  my ($self, $rec) = @_;
  my @lines;

  my $name = $rec->{name};
  $name = $rec->{node}->fqdn if ! $name && $rec->{node};

  Carp::confess("no record name or node given for txt record")
    unless defined $name and length $name;

  # 'fqdn:s:ttl:timestamp:lo
  push @lines, sprintf qq{'%s:%s:%s:%s:%s\n},
    $name,
    $rec->{text},
    $rec->{ttl} || $self->_default_ttl,
    $self->_serial_number,
    '',
  ;

  return @lines;
}

sub _escaped_octals {
  join q{}, map {; sprintf '\\%03o', ord } split //, pack 'n', $_[0];
}

sub _hostname_to_labels {
  my @labels = split /\./, $_[0];
  my $str = '';
  $str .= sprintf('\\%03o', length) . $_ for @labels;
  $str .= '\000';

  return $str;
}

#pod =method srv
#pod
#pod   @lines = $rec->srv({
#pod     # We want to produce _finger._tcp.example.com for port 70
#pod     domain    => 'example.com',
#pod     service   => 'finger',
#pod     protocol  => 'tcp',
#pod     target    => 'f.example.com',
#pod     port      => 70,
#pod
#pod     priority  => 10,
#pod     weight    => 20,
#pod   });
#pod
#pod This returns lines for SRV records following RFC 2782.  It takes the following
#pod arguments:
#pod
#pod   domain    - the domain offering service
#pod   service   - the well-known service name (http, imaps, finger)
#pod   protocol  - tcp or udp
#pod
#pod   target    - the host providing service
#pod   port      - the port the service listens on
#pod
#pod   priority  - numeric priority; lower numbers should be used first
#pod   weight    - weight to break priority ties; higher numbers preferred
#pod
#pod =cut

sub srv {
  my ($self, $rec) = @_;

  Carp::confess("srv record with no target! use empty string for null target")
    unless defined $rec->{target};

  for my $needed (qw(port service domain)) {
    Carp::confess("tried to make srv record with no $needed!")
      unless defined $rec->{$needed};
  }

  my $priority = $rec->{priority} || 0;
  my $weight   = $rec->{weight}   || 0;

  my @lines;
  push @lines, sprintf ":_%s._%s.%s:33:%s%s%s%s:%s:%s\n",
    $rec->{service},
    $rec->{protocol} || 'tcp',
    $rec->{domain},
    _escaped_octals($priority),
    _escaped_octals($weight),
    _escaped_octals($rec->{port}),
    _hostname_to_labels($rec->{target}),
    $rec->{ttl} || $self->_default_ttl,
    $rec->{location} || '';

  return @lines;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DNS::Oterica::RecordMaker::TinyDNS - a tinydns recordmaker for DNSO.

=head1 VERSION

version 0.205

=head1 DESCRIPTION

This role provides logic for generating lines for the F<tinydns-data> program
to consume.

=head1 METHODS

=head2 comment

  my $line = $rec->comment("Hello, world!");

This returns a line that is a one-line commment.

=head2 location

This returns a location line.

=head2 a_and_ptr

Generate an C<=> line, the bread and butter A and PTR record pair for a
hostname and IP.

=head2 ptr

Generate an C<^> line, for the reverse DNS of an IP address.

=head2 srv

  @lines = $rec->srv({
    # We want to produce _finger._tcp.example.com for port 70
    domain    => 'example.com',
    service   => 'finger',
    protocol  => 'tcp',
    target    => 'f.example.com',
    port      => 70,

    priority  => 10,
    weight    => 20,
  });

This returns lines for SRV records following RFC 2782.  It takes the following
arguments:

  domain    - the domain offering service
  service   - the well-known service name (http, imaps, finger)
  protocol  - tcp or udp

  target    - the host providing service
  port      - the port the service listens on

  priority  - numeric priority; lower numbers should be used first
  weight    - weight to break priority ties; higher numbers preferred

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
