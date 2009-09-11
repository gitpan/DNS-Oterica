package DNS::Oterica::NodeFamily;
our $VERSION = '0.092541';

# ABSTRACT: a group of hosts that share common functions
use Moose;


has nodes => (
  is  => 'ro',
  isa => 'ArrayRef',
  auto_deref => 1,
  init_arg   => undef,
  default    => sub { [] },
);


# XXX: do not allow dupes -- rjbs, 2009-09-11
sub add_node {
  my ($self, $node) = @_;
  push @{ $self->nodes }, $node;
}


sub as_data_lines {
  my ($self) = @_;

  my @lines;

  push @lines, $self->rec->comment("begin family " . $self->name);
  push @lines, $_ for inner();
  push @lines, $self->rec->comment("end family " . $self->name);

  return @lines;
}


has hub => (
  is   => 'ro',
  isa  => 'DNS::Oterica::Hub',
  weak_ref => 1,
  required => 1,
  # handles  => 'DNS::Oterica::Role::RecordMaker',
  handles  => [ qw(rec) ],
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=head1 NAME

DNS::Oterica::NodeFamily - a group of hosts that share common functions

=head1 VERSION

version 0.092541

=head1 ATTRIBUTES

=head2 nodes

This is an arrayref of the node objects that are in this family.

=head2 hub

This is the hub object into which the family was registered.

=head1 METHODS

=head2 add_node

  $family->add_node($node);

This adds the given node to the family.

=head2 as_data_lines

This method returns a list of lines of configuration.  By default it only
generates begin and end marking comments.  This method is meant to be augmented
by subclasses.

=head1 AUTHOR

  Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 


