package BloGro::Web::Middleware;
use strict;
use warnings;
use utf8;

use Plack::Builder;
use BloGro::Utils qw/get_path/;

sub wrap {
    my($class, $app) = @_;

    return builder {
        enable 'Runtime';
        enable 'ReverseProxy';
        enable 'Header',
            set => [
                'X-Content-Type-Options' => 'nosniff',
                'X-Frame-Options'        => 'DENY',
                'Cache-Control'          => 'private'
            ];
        enable 'Static',
            path => qr{^(?:/static/)},
            root => get_path('htdocs');
        enable 'Static',
            path => qr{^(?:/robots\.txt|/favicon\.ico)$},
            root => get_path(htdocs => 'static');
        enable 'Session::Cookie';

        enable '+BloGro::Web::Middleware::Bootstrap';
        $app;
    };
}

1;
