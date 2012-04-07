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

__PACKAGE__->load_plugin('Web::Auth' => +{
    module => 'Facebook',
    on_finished => sub {
        my ($c, $token, $user) = @_;
        my $name = $user->{name} || die;

        $c->session->options->{change_id}++;
        return $c->redirect('/');
    }
});

1;
