package DNS::Oterica::NodeFamily::Jeeves;
our $VERSION = '0.092570';

use Moose;
extends 'DNS::Oterica::NodeFamily';

sub name { 'com.example.jeeves' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
