package BloGro::Groonga;
use strict;
use warnings;
use utf8;

use 5.10.0;

use BloGro::Connection;
use Data::Validator;

sub new         { bless +{} => +shift }
sub table_name  { require Carp; Carp::croak('this is abstruct method') }
sub column_list { require Carp; Carp::croak 'this is abstruct method' }

sub search {
    state $rule = Data::Validator->new(
        query  => 'Str',
        option => +{ isa => 'HashRef', optional => 1 }
    )->with(qw/Method StrictSequenced/);
    my($self, $args) = $rule->validate(@_);

    return connection('groonga')->call(select => +{
        table          => $self->table_name,
        query          => $args->{query},
        output_columns => $self->column_list,
        exists($args->{option}) ? (
            %{ $args->{option} }
        ) : ()
    })->recv;
}

sub insert_or_update {
    state $rule = Data::Validator->new(
        data   => 'ArrayRef[HashRef]',
        option => +{ isa => 'HashRef', optional => 1 },
    )->with(qw/Method StrictSequenced/);
    my($self, $args) = $rule->validate(@_);

    return connection('groonga')->call(load => +{
        values         => $args->{data},
        table          => $self->table_name,
        input_type     => 'json',
        exists($args->{option}) ? (
            %{ $args->{option} }
        ) : ()
    })->recv;
}

sub delete {
    state $rule = Data::Validator->new(
        val  => 'Value',
    )->with(qw/Method StrictSequenced/);
    my($self, $args) = $rule->validate(@_);

    return connection('groonga')->call(delete => +{
        table => $self->table_name,
        key   => $args->{val},
    })->recv;
}

1;
