package BloGro::Model;
use strict;
use warnings;
use utf8;

use parent qw/DBIx::Sunny::Schema Class::Singleton/;
use 5.10.0;

use BloGro::Connection;
use SQL::Maker;
SQL::Maker->load_plugin('InsertMulti');

sub new { shift->instance }
sub _new_instance {
    my $class = shift;

    $class->SUPER::new(
        dbh      => undef, # dummy
        readonly => $class->readonly,
    );
}

# db_info
sub dbh    { connection('dbh' => [shift->db_name]) }
sub driver { shift->dbh->{Driver}->{Name}          }

# abstruct methods
sub readonly    { require Carp; Carp::croak 'this is abstruct method' }
sub db_name     { require Carp; Carp::croak 'this is abstruct method' }
sub table_name  { require Carp; Carp::croak 'this is abstruct method' }
sub column_list { require Carp; Carp::croak 'this is abstruct method' }

sub sql_column_list {
    my $invocant = shift;
    return join ',', @{ $invocant->column_list };
}

sub builder {
    state $cache = +{};
    my $invocant = shift;

    return $cache->{$invocant->driver} ||= do {
        SQL::Maker->new(driver => $invocant->driver);
    };
}

sub select {
    my $invocant = shift;

    return $invocant->builder->select(
        $invocant->table_name,
        $invocant->column_list,
        @_,
    );
}

sub search {
    my $invocant = shift;

    return $invocant->dbh->select_all($invocant->select(@_));
}

sub single {
    my $invocant = shift;

    return $invocant->dbh->select_row($invocant->select(@_));
}

foreach my $cond (qw/insert update delete/, [insert_multi => 'bulk_insert']) {
    my($method, $name);
    if (ref $cond) {
        $method = $cond->[0];
        $name   = $cond->[1];
    }
    else {
        $method = $cond;
        $name   = $cond;
    }

    my $code = sub {
        my $invocant = shift;

        my($query, @bind) = $invocant->builder->$method(
            $invocant->table_name,
            @_,
        );

        $invocant->dbh->do($query, undef, @bind);
    };
    {
        no strict 'refs';
        *{$method} = $code;
    }
}

1;

