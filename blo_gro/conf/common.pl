use strict;
use warnings;
use utf8;

+{
    db => +{
        main => +{
            dsn  => 'dbi:mysql:database=bro_gro;host=localhost;port=5522',
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
};
