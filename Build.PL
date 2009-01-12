use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Tube8',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/WWW/Tube8.pm',
    requires => {
        'Test::More'      => 0,
        'Carp'            => 0,
        'LWP::UserAgent'  => 0,
        'Class::Accessor' => 0,
    },
    add_to_cleanup      => [ 'WWW-Tube8-*' ],
);

$builder->create_build_script();
