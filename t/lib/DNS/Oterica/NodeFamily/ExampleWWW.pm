package DNS::Oterica::NodeFamily::ExampleWWW;
our $VERSION = '0.092950';


use Moose;
extends 'DNS::Oterica::NodeFamily';

sub name { 'com.example.www' }

augment as_data_lines => sub {
  my ($self) = @_;

  my $string = '';
  for my $node ($self->nodes) {
    $string .= $_ for $self->rec->a({
      name => 'www.example.com',
      node => $node,
    });
  }

  return $string;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
