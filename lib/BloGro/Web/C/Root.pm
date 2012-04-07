package BloGro::Web::C::Root;
use strict;
use warnings;
use utf8;

use BloGro::Container 'model';

sub index {
    my($class, $c) = @_;
    $c->render('index.tx');
}

sub logout {
    my($class, $c) = @_;
    $c->session->expire;
    $c->redirect('/');
};
