use strict;
use warnings;
use utf8;

use My::List;

package test::Test01;
use base qw( Test::Class );
use Test::More tests => 11;

sub test1 : Test(11) {
    my $list = new My::List();
    my $vals = [ "va", "vvv", "test", "good luck", "日本語" ];
    $list->append( $_ ) for @$vals;
    my $it1 = $list->iterator;
    foreach( @$vals ) {
        ok( $it1->has_next );
        is( $it1->next, $_ );
    }
    ok( ! $it1->has_next );
}

__PACKAGE__->runtests();

1;

