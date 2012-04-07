package BloGro::GroongaQuery;
use strict;
use warnings;
use utf8;

use 5.10.0;
use Data::Validator;

sub build {
    my $class = shift;
    my $args  = (@_ == 1 and ref($_[0]) eq 'HASH') ? +shift : +{ @_ };

    my @queries;
    foreach my $key (keys %$args) {
        push @queries => $class->_build($key => $args->{$key});
    }

    return join(' OR ', @queries);
}

sub _build {
    state $rule = Data::Validator->new(
        column    => 'Str',
        cond      => 'Defined',
    )->with(qw/Method StrictSequenced/);
    my($self, $args) = $rule->validate(@_);

    my $column = $args->{column};
    my $cond   = $args->{cond};
    my $query  = '';
    if (ref $cond) {
        if (ref $cond eq 'ARRAY') {
            my @vals = @$cond;
            my $join = 'OR';
            $join = shift(@vals) if ($vals[0] eq '+' or $vals[0] eq '-');
            foreach my $val (@vals) {
                $query .= " $join " if $query;
                $query .= $self->_build($column => $val);
            }
            $query = "(${query})";
        }
        elsif (ref $cond eq 'HASH') {
            state $cond_rule_hash = +{
                '<'      => ':<',
                '>'      => ':>',
                '!='     => ':!',
                '<='     => ':<=',
                '>='     => ':>=',
                '-match' => ':@'
            };
            foreach my $cond_rule (keys %$cond) {
                unless (exists $cond_rule_hash->{$cond_rule}) {
                    require Carp;
                    Carp::croak("unknown cond = ref($cond_rule)");
                }
                my $rule = $cond_rule_hash->{$cond_rule};
                my $val  = escape($cond->{$cond_rule});
                $query = "${column}${rule}${val}";
                last;
            }
        }
        else {
            require Carp;
            Carp::croak("unknown cond = ref($cond)");
        }
    }
    else {
        $cond  = escape($cond);
        $query = "${column}:${cond}";
    }

    return $query;
}

sub escape {
    state $rule = Data::Validator->new(
        val  => 'Str',
    )->with(qw/StrictSequenced/);
    my $val = $rule->validate(@_)->{val};
    $val =~ s/"/\\"/g;
    return qq{"${val}"};
}

1;
