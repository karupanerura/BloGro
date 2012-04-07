use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename ();
my $dir  = File::Basename::dirname(__FILE__);
my $conf = do(File::Spec->catfile($dir, 'secret.pl')) || +{};

+{
    db => +{
        main => +{
            dsn  => 'dbi:mysql:database=blo_gro;host=127.0.0.1;port=5522',
            user => 'msandbox',
            pass => 'msandbox',
            attr => +{
                RaiseError          => 1,
                PrintError          => 0,
                ShowErrorStatement  => 1,
                AutoInactiveDestroy => 1,
                mysql_enable_utf8   => 1,
            }
        },
    },
    groonga => +{
        protocol => 'http',
        host     => 'localhost',
        port     => '10041',
    },
    time_zone => 'Asia/Tokyo',
    %$conf,
};
