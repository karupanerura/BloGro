use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');

use BloGro::Web;
BloGro::Web->to_app;
