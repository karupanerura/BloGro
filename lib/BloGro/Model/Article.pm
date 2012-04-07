package BloGro::Model::Article;
use strict;
use warnings;
use utf8;

use 5.10.0;

use parent qw/BloGro::Model/;
sub readonly    { 0 }
sub db_name     { 'main' }
sub table_name  { 'article' }
sub column_list { [qw/id author_id status published_at created_at updated_at/] }

use Try::Tiny;
use Data::Validator;
use BloGro::Container 'groonga';

__PACKAGE__->query(
    '_add',
    author_id    => 'Int',
    status       => 'Str',
    published_at => 'Str',
    created_at   => +{ isa => 'Str', default => sub { BloGro::Utils::now_db_datetime(__PACKAGE__->driver) } },
    "INSERT INTO @{[ __PACKAGE__->table_name ]}(author_id, status, published_at, created_at) VALUES (?, ?, ?, ?)"
);

sub add {
    state $rule = Data::Validator->new(
        author_id    => 'Int',
        status       => 'Str',
        title        => 'Str',
        body         => 'Str',
        tags         => +{ isa => 'ArrayRef[Str]', default => sub { [] } },
        published_at => +{ isa => 'Str',           default => sub { BloGro::Utils::now_db_datetime(__PACKAGE__->driver) } },
    )->with(qw/Method/);
    my($self, $args) = $rule->validate(@_);

    my $txn = $self->txn_scope;
    my $id;
    try {
        $self->_add(
            author_id    => $args->{author_id},
            status       => $args->{status},
            published_at => $args->{published_at},
        );
        $id = $self->last_insert_id;
        groonga('Article')->add(
            _key  => $id,
            title => $args->{title},
            body  => $args->{body},
            tags  => $args->{tags},
        );
        $txn->commit;
    }
    catch {
        my $e = $_;
        $txn->rollback;
        groonga('Article')->delete(_key => $id) if defined $id;
        die $e;
    };

    return $id;
}

__PACKAGE__->select_row(
    '_fetch_by_id',
    id => 'Int',
    "SELECT @{[ __PACKAGE__->sql_column_list ]} FROM @{[ __PACKAGE__->table_name ]} WHERE id = ?"
);
sub fetch_by_id {
    state $rule = Data::Validator->new(
        id => 'Int',
    )->with(qw/Method/);
    my($self, $args) = $rule->validate(@_);

    return +{
        %{ $self->_fetch_by_id(id => $args->{id}) },
        %{ groonga('Article')->fetch(_key => $args->{id}) }
    };
}

1;
