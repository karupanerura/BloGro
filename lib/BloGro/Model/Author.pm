package BloGro::Model::Author;
use strict;
use warnings;
use utf8;

use 5.10.0;

use parent qw/BloGro::Model/;
sub readonly    { 0 }
sub db_name     { 'main' }
sub table_name  { 'author' }
sub column_list { [qw/id author created_at updated_at/] }

use Try::Tiny;
use Data::Validator;
use BloGro::Container 'model';

__PACKAGE__->query(
    '_add',
    author       => 'Str',
    created_at   => +{ isa => 'Str', default => sub { BloGro::Utils::now_db_datetime(__PACKAGE__->driver) } },
    "INSERT INTO @{[ __PACKAGE__->table_name ]}(author, created_at) VALUES (?, ?)"
);

sub add {
    state $rule = Data::Validator->new(
        author       => 'Str',
        service_name => 'Str',
        service_id   => 'Str',
        profile      => 'HashRef',
        created_at   => +{ isa => 'Str', default => sub { BloGro::Utils::now_db_datetime(__PACKAGE__->driver) } },
    )->with(qw/Method/);
    my($self, $args) = $rule->validate(@_);

    my $txn = $self->txn_scope;
    return try {
        $self->_add(
            author     => $args->{author},
            created_at => $args->{created_at},
        );
        my $id = $self->last_insert_id;
        model('Auth')->add(
            service_name => $args->{service_name},
            service_id   => $args->{service_id},
            author_id    => $id,
        );
        model('AuthorProfile')->add(%{ $args->{profile} });
        $txn->commit;

        return $id;
    }
    catch {
        my $e = $_;
        $txn->rollback;
        die $e;
    };
}

__PACKAGE__->select_all(
    'all',
    "SELECT @{[ __PACKAGE__->sql_column_list ]} FROM @{[ __PACKAGE__->table_name ]}"
);

1;
