package BloGro::Model::AuthorProfile;
use strict;
use warnings;
use utf8;

use 5.10.0;

use parent qw/BloGro::Model/;
sub readonly    { 0 }
sub db_name     { 'main' }
sub table_name  { 'author_profile' }
sub column_list { [qw/author_id misc_data/] }

use Data::Validator;
use JSON 2;

sub json {
    my $self = shift;
    $self->{json} ||= JSON->new->utf8;
}

__PACKAGE__->query(
    '_add',
    author_id => 'Int',
    misc_data => 'Str',
    "INSERT INTO @{[ __PACKAGE__->table_name ]}(author_id, misc_data) VALUES (?, ?)"
);

sub add {
    state $rule = Data::Validator->new(
        author_id => 'Int',
        misc_data => '',
    )->with(qw/Method/);
    my($self, $args) = $rule->validate(@_);

    $self->_add(
        author_id => $args->{author_id},
        misc_data => $self->json->encode($args->{misc_data}),
    );
}

__PACKAGE__->select_row(
    '_get',
    author_id => 'Int',
    "SELECT @{[ __PACKAGE__->sql_column_list ]} FROM @{[ __PACKAGE__->table_name ]} WHERE author_id = ?"
);

sub get {
    my $self = shift;
    my $row = $self->_fetch_by_id(@_);
    return unless $row;
    return $self->json->decode($row->{misc_data});
}

1;
