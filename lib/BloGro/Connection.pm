package BloGro::Connection;
use strict;
use warnings;
use utf8;

use BloGro::Container;
use Scope::Container ();
use Scope::Container::DBI;
use DBIx::Sunny; # for preload

sub import {
    my $class  = shift;
    my $caller = caller;

    # shortcut
    my $connection = sub {
        my($name, $args) = @_;

        unless ($class->can($name)) {
            require Carp;
            Carp::croak("method '${name}' is not defined in $class.");
        }

        return $class->$name(@{ $args || [] });
    };

    {
        no strict 'refs';
        *{"${caller}::connection"} = $connection;
    };
}

sub dbh_connect_info {
    my($class, $name) = @_;

    container('config')->{db}{$name};
}

sub dbh {
    my($class, $name) = @_;

    my $connect_info = $class->dbh_connect_info($name);
    return Scope::Container::DBI->connect(
        $connect_info->{dsn},
        $connect_info->{user},
        $connect_info->{pass},
        +{
            %{ $connect_info->{attr} },
            RootClass => 'DBIx::Sunny',
        },
    );
}

1;
