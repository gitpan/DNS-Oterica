package DNS::Oterica::Node::Domain;
our $VERSION = '0.092541';

# ABSTRACT: a domain node
use Moose;
extends 'DNS::Oterica::Node';


sub fqdn { $_[0]->domain; }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=head1 NAME

DNS::Oterica::Node::Domain - a domain node

=head1 VERSION

version 0.092541

=head1 OVERVIEW

DNS::Oterica::Node::Domain represents a domain name in DNS::Oterica. Domains
have hosts.

=head1 METHODS

=head2 fqdn

The fully qualified domain name for this domain.

=head1 AUTHOR

  Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 


