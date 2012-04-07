package BloGro;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

use BloGro::Utils;
use BloGro::Connection;
use BloGro::Container;

sub load_config { container('config') }

1;
