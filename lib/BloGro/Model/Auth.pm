package BloGro::Model::Auth;
use strict;
use warnings;
use utf8;

use 5.10.0;

use parent qw/BloGro::Model/;
sub readonly    { 0 }
sub db_name     { 'main' }
sub table_name  { 'auth' }
sub column_list { [qw/id service_name service_id author_id created_at updated_at/] }

__PACKAGE__->query(
    'add',
    service_name => 'Str',
    service_id   => 'Str',
    author_id    => 'Int',
    created_at   => +{ isa => 'Str', default => sub { BloGro::Utils::now_db_datetime(__PACKAGE__->driver) } },
    "INSERT INTO @{[ __PACKAGE__->table_name ]}(service_name, service_id, author_id, created_at) VALUES (?, ?, ?, ?)"
);

__PACKAGE__->select_one(
    'fetch_author_id',
    service_name => 'Str',
    service_id   => 'Str',
    "SELECT author_id FROM @{[ __PACKAGE__->table_name ]} WHERE service_name = ? AND service_id = ?"
);

1;
__END__
