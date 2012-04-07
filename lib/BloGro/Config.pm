package BloGro::Config;
use strict;
use warnings;
use utf8;

use Config::ENV 'PLACK_ENV';

use BloGro::Utils qw/get_path/;
use File::Spec;

my $common      = get_path(conf => 'common.pl');
my $development = get_path(conf => 'development.pl');
my $deployment  = get_path(conf => 'deployment.pl');

common +{
    load($common)
};

config development => +{
    load($development)
};

config deployment => +{
    load($deployment)
};

1;
