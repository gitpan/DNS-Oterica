package DNS::Oterica::NodeFamily::PostLink;
our $VERSION = '0.092950';


use Moose;
extends 'DNS::Oterica::NodeFamily';

sub name { 'com.example.postlink' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
