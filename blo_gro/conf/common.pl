use strict;
use warnings;
use utf8;

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
};
