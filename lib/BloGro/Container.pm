package BloGro::Container;
use strict;
use warnings;
use utf8;

use Object::Container::Exporter -base;

register_namespace model   => 'BloGro::Model';
register_namespace groonga => 'BloGro::Groonga';

register config => sub {
    my $self = shift;
    $self->load_class('BloGro::Config');
    return BloGro::Config->current;
};

1;
