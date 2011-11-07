use strict;
use warnings;

use My::List;

package test::Test01;
use base qw( Test::Class );
use Test::More;

# 複数の値をリストに追加し, イテレートすることができるかのテスト
sub can_append_and_iterate_values : Tests {
    my $self = shift;
    my $list = new My::List();
    my $vals = [ "va", "good luck", "日本語" ];
    $list->append( $_ ) for @$vals;
    # イテレーションを 2 回繰り返す
    for( my $i = 0; $i < 2; ++ $i ) {
        my $it1 = $list->iterator;
        foreach( @$vals ) {
            ok( $it1->has_next );
            is( $it1->next, $_ );
        }
        ok( ! $it1->has_next );
    }
}

# push と pop を使ってスタックのように使える
sub can_be_used_as_a_stack_by_using_push_and_pop_methods : Tests {
    my $self = shift;
    my $list = new My::List();
    my $vals = [ "va", "good luck", "日本語" ];
    foreach( 0..$#$vals ) {
        $list->push( $$vals[$_] );
        is( $list->size, $_ + 1, "list size" );
    }
    while( $list->size != 0 ) {
        is( $list->pop(), pop( @$vals ), "value" );
    }
    is( $list->size, 0 );
}

# unshift と shift を使ってスタックのように使える
sub can_be_used_as_a_stack_by_using_shift_and_unshift_methods : Tests {
    my $self = shift;
    my $list = My::List->new();
    my $vals = [ "va", "good luck", "日本語" ];
    foreach( 0..$#$vals ) {
        $list->unshift( $$vals[$_] );
        is( $list->size, $_ + 1, "list size" );
    }
    foreach( 0..$#$vals ) {
        is( $list->shift(), $$vals[$#$vals-$_], "value" );
    }
    is( $list->size, 0 );
}

# リストを配列に変換する
sub can_be_converted_to_array : Tests {
    my $self = shift;
    my $list = My::List->new();
    is_deeply( $list->to_array_ref(), [] );
    my $vals = [ "va", "good luck", "日本語" ];
    $list->append( $_ ) for @$vals;
    is_deeply( $list->to_array_ref(), $vals );
}

# インデックスを指定してリストに追加したり削除したりする
sub test_of_insert_and_remove : Tests {
    my $self = shift;
    my $list = My::List->new();
    my $vals = [ 1, 4, 234, 5634, 32 ];
    foreach( @$vals ) {
        $list->insert( 0, $_ );
    }
    my $aref = $list->to_array_ref(); 
    is_deeply( $aref, [ reverse @$vals ] );
    $list->remove( 2 );
    is_deeply( $list->to_array_ref(), [ 32, 5634, 4, 1 ] );
    $list->remove( 0 );
    is_deeply( $list->to_array_ref(), [ 5634, 4, 1 ] );
    $list->remove( 2 );
    is_deeply( $list->to_array_ref(), [ 5634, 4 ] );
    $list->remove( 1 );
    is_deeply( $list->to_array_ref(), [ 5634 ] );
    is( $list->remove( 0 ), 5634 );
    is_deeply( $list->to_array_ref(), [ ] );
    eval { $list->remove( 0 ) };
    like( $@, qr/Invalid index/, "invalid index error" );
    # 新しいリスト
    $list = My::List->new();
    foreach( 0..$#$vals ) {
        $list->insert( $_, $$vals[$_] );
    }
    $aref = $list->to_array_ref(); 
    is_deeply( $aref, $vals );
}

__PACKAGE__->runtests();

1;

