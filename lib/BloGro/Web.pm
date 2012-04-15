package BloGro::Web;
use strict;
use warnings;
use utf8;

use parent qw/BloGro Amon2::Web/;

use 5.10.0;
use Data::Validator;
use Try::Tiny;

use BloGro::Container 'model';
use BloGro::Web::Dispatcher;
use BloGro::Web::Middleware;

# dispatcher
sub dispatch {
    return BloGro::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

sub to_app {
    my $class = shift;

    my $app = $class->SUPER::to_app;
    return BloGro::Web::Middleware->wrap($app);
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::CSRFDefender',
    '+BloGro::Plugin::Web::Xslate',
);

__PACKAGE__->load_plugin('Web::Auth' => +{
    module => 'Facebook',
    on_finished => sub {
        my ($c, $token, $user) = @_;
        return $c->redirect('/error') unless $user;

        return $c->auth(
            service_name => 'facebook',
            service_id   => $user->{id},
            author       => $user->{name},
            token        => $token,
            profile      => +{
                gender => $user->{gender},
                link   => $user->{link},
            },
        );
    }
});

__PACKAGE__->load_plugin('Web::Auth' => +{
    module => 'Twitter',
    on_finished => sub {
        my ($c, $access_token, $access_token_secret, $user_id, $screen_name) = @_;
        return $c->redirect('/error') unless $user_id and $screen_name;

        return $c->auth(
            service_name => 'twitter',
            service_id   => $user_id,
            author       => $screen_name,
            token        => +{
                access_token  => $access_token,
                access_secret => $access_token_secret
            },
            profile => +{
            },
        );
    }
});

sub auth {
    state $rule = Data::Validator->new(
        author       => 'Str',
        service_name => 'Str',
        service_id   => 'Str',
        token        => 'Defined',
        profile      => 'HashRef',
    )->with(qw/Method/);
    my($c, $args) = $rule->validate(@_);
    my $author_id = model('Auth')->fetch_author_id(
        service_name => $args->{service_name},
        service_id   => $args->{service_id},
    );
    unless ($author_id) {
        $author_id = try {
            model('Author')->add(
                service_name => $args->{service_name},
                service_id   => $args->{service_id},
                author       => $args->{author},
                profile      => $args->{profile},
            );
        }
        catch {
            my $e = $_;
            warn $e;
            return;
        };
    }

    return $c->redirect('/error') unless $author_id;

    $c->session->set(user => +{
        service_name => $args->{service_name},
        token        => $args->{token},
        author_id    => $author_id,
    });

    $c->session->options->{change_id}++;
    return $c->redirect('/');
}

1;
