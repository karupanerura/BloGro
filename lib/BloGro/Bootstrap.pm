package BloGro::Bootstrap;
use strict;
use warnings;
use utf8;

use Scope::Container;

use Mozilla::CA;
use IO::Socket::SSL;
use Net::SSLeay;
BEGIN {
    IO::Socket::SSL::set_ctx_defaults(
        verify_mode => Net::SSLeay->VERIFY_PEER(),
        ca_file     => Mozilla::CA::SSL_ca_file(),
    );
}

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
