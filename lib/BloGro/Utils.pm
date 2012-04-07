package BloGro::Utils;
use 5.010_000;
use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

use parent qw/Exporter/;
our @EXPORT_OK = qw/is_development get_path to_hash/;

use BloGro::Container;
use Amon2::Util;
use File::Spec;
use File::ShareDir;
use Digest::HMAC_SHA1;

use constant +{
    is_development => $ENV{PLACK_ENV} ? $ENV{PLACK_ENV} eq 'development' : 1,
};

sub get_path {
    state $base_dir = is_development ?
        File::Spec->catfile( Amon2::Util::base_dir(__PACKAGE__), 'blo_gro' ):
        File::ShareDir::dist_dir('BloGro');

    File::Spec->catfile($base_dir, @_);
}

sub to_hash {
    Digest::HMAC_SHA1::hmac_sha1_hex(+shift, container('config')->{hash_key});
}

1;
__END__

=head1 NAME

BloGro::Utils - Perl extention to do something

=head1 VERSION

This document describes BloGro::Util version 0.01.

=head1 SYNOPSIS

    use BloGro::Utils;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Kenta Sato. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
