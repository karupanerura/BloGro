package BloGro::Web;
use strict;
use warnings;
use utf8;

use parent qw/BloGro Amon2::Web/;

use BloGro::Web::Dispatcher;
use BloGro::Web::Middleware;

# dispatcher
sub dispatch {
    return BloGro::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

sub to_app {
    my $class = shift;

    my $app = $class->SUPER::to_app;
    return BloGro::Web::Middleware->wrap($app);
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::CSRFDefender',
    '+BloGro::Plugin::Web::Xslate',
);

1;
