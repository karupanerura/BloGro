package BloGro::Web::Middleware::Bootstrap;
use strict;
use warnings;
use utf8;

use parent qw/Plack::Middleware/;
use BloGro::Bootstrap;

sub call {
    my($self, $env) = @_;
    my $guard = BloGro::Bootstrap->run;
    return $self->app->($env);
}

1;
