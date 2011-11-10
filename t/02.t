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

sub test_of_iterators_insertion_and_removal : Tests {
    my $self = shift;
    my $list = $self->create_list( 11, 12, 13, 14, 15 );
    my $it1 = $list->iterator_at( 2 );
    my $it2 = $list->iterator_at( 2 );
    # 0 [11] 1 [12] 2 (it1,it2) [13] 3 [14] 4 [15] 5
    $it1->insert_next( 16 );
    # 0 [11] 1 [12] 2 (it1,it2) [16] 3 [13] 4 [14] 5 [15] 6
    is( $it2->next, 16 );
    is( $it2->next, 13 );
    is( $it2->remove_prev(), 13 );
    is( $it1->remove_next(), 16 );
    # 0 [11] 1 [12] 2 (it1,it2) 3 [14] 4 [15] 5
    is( $it1->prev, 12 );
    is( $it2->prev, 12 );
    is( $it2->remove_prev, 11 );
    ok( ! $it1->has_prev );
    ok( ! $it2->has_prev );
    # 0 (it1,it2) [12] 1 [14] 2 [15] 3
    $it1->insert_prev( 17 );
#print join( ",", @{$list->to_array_ref()} ), "\n";
    is( $it2->prev, 17 );
    my $it3 = $list->iterator;
    ok( ! $it3->has_prev );
    is( $it3->next, 17 );
}


sub create_list {
    my $self = shift;
    my $list = My::List->new();
    $list->append( $_ ) for @_;
    return $list;
}



__PACKAGE__->runtests();

1;

