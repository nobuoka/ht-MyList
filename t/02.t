use strict;
use warnings;

use My::List;

package test::Test02;
use base qw( Test::Class );
use Test::More;

# 正順でイテレートできるかどうか
sub can_iterate_by_normal_order : Tests {
    my $self = shift;
    my $list = My::List->new();
    $list->append( $_ ) for 4..10;
    # イテレーションを 2 回繰り返す
    for( my $i = 0; $i < 2; ++ $i ) {
        my $it1 = $list->iterator;
        foreach( 4..10 ) {
            ok( $it1->has_next );
            is( $it1->next, $_ );
        }
        ok( ! $it1->has_next );
    }
}

# 逆順でイテレートできるかどうか
sub can_iterate_by_reverse_order : Tests {
    my $self = shift;
    my $list = My::List->new();
    $list->append( $_ ) for 4..10;
    # イテレーションを 2 回繰り返す
    for( my $i = 0; $i < 2; ++ $i ) {
        my $it = $list->iterator_at( $list->size );
        ok( ! $it->has_next, "position is ok (reverse order)" );
        for( my $j = 10; 4 <= $j; -- $j ) {
            ok( $it->has_prev );
            is( $it->prev, $j );
        }
        ok( ! $it->has_prev );
    }
}
__PACKAGE__->runtests();

1;

