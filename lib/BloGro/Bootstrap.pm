package BloGro::Bootstrap;
use strict;
use warnings;
use utf8;

use Scope::Container;

sub run {
    my $class = shift;

    my $scope = start_scope_container();
    $class->init;
    return $scope;
}

sub init {
    my $class = shift;
}

1;
