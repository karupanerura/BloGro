package BloGro::Groonga::Article;
use strict;
use warnings;
use utf8;

use 5.10.0;

use parent qw/BloGro::Groonga/;
sub table_name  { 'article' }
sub column_list { [qw/title body tags/] }

use Data::Validator;

sub add {
    state $rule = Data::Validator->new(
        _key  => 'Int',
        title => 'Str',
        body  => 'Str',
        tags  => +{ isa => 'ArrayRef[Str]', default => sub { [] } },
    )->with(qw/Method/);
    my($self, $args) = $rule->validate(@_);

    $self->insert_or_update([$args]);
}

sub fetch {
    state $rule = Data::Validator->new(
        _key  => 'Int',
    )->with(qw/Method/);
    my($self, $args) = $rule->validate(@_);

    my $res = $self->search(+{ _key => $args->{_key}}, +{});
    return unless $res;
    return $res->items->[0];
}

1;
