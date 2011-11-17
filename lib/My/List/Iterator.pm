use strict;
use warnings;
use Carp;

package My::List::Iterator;

=head1 NAME

My::List::Iterator -- My::List のためのイテレータ実装

=head1 SYNOPSIS

  use My::List;
  my $list = My::List->new();
  $list->append( $_ ) for 1..10;
  
  my $it = $list.iterator();
  while( $it->has_next ) {
      my $val = $it->next();
  }
  
  # 値の挿入や削除も出来る
  my $removed_val = $it->remove_prev();
  $it->insert_prev( 100 );

=head1 DESCRIPTION

このクラスは, 結合リスト My::List のためのイテレータの実装です. 
イテレーションしてリスト中の値を順に参照する以外に, リスト中の値を削除したり, 
新たに値を挿入することもできます. 

イテレータは, リスト中の位置 (値と値の境界, 最初の値の前, 最後の値の後ろ) を保持します. 
値そのものを指しているわけではないことに注意してください. 

=head2 How to construct

My::List::Iterator のインスタンスを得るには, My::List#iterator メソッドか 
My::List#iterator_at メソッドを使用してください. 

=cut

# ---- public instance methods ----

=head2 Public instance methods

=item $it->has_next

現在の位置の後ろに値が存在するかどうかを表します. 
後ろに値が存在する場合は真として評価される値を, そうでない場合は偽として評価される値を返します. 

=item $it->next()

イテレータが指す位置を, 次の位置に移します. 
位置を移動する際に飛び越した値を返り値として返します. 

後ろに値が存在しない場合は例外を発生させます. 

=item $it->has_prev

現在の位置の前に値が存在するかどうかを表します. 
前に値が存在する場合は真として評価される値を, そうでない場合は偽として評価される値を返します. 

=item $it->prev()

イテレータが指す位置を, 前の位置に移します. 
位置を移動する際に飛び越した値を返り値として返します. 

前に値が存在しない場合は例外を発生させます. 

=item $it->insert_prev( $value )

イテレータが指す位置の直前に新しい値 $value を挿入します. 
イテレータが指す位置は変わりません. 

=item $it->insert_next( $value )

イテレータが指す位置の直後に新しい値 $value を挿入します. 
イテレータが指す位置は変わりません. 

=item $it->remove_prev()

イテレータが指す位置の直前に存在する値をリストから削除し, 削除した値を返します. 
イテレータが指す位置は変わりません. 
(削除した値の直前の位置を指しているイテレータが存在していた場合, 
このメソッドを実行した後に自身が指す位置とそのイテレータが指す位置は同じになります.)

削除すべき値が存在しないような状況でこのメソッドを呼ぶと例外が発生します. 

=item $it->remove_next()

イテレータが指す位置の直後に存在する値をリストから削除し, 削除した値を返します. 
イテレータが指す位置は変わりません. 
(削除した値の直後の位置を指しているイテレータが存在していた場合, 
このメソッドを実行した後に自身が指す位置とそのイテレータが指す位置は同じになります.)

削除すべき値が存在しないような状況でこのメソッドを呼ぶと例外が発生します.
 
=item 

=cut

sub has_next {
    my $self = shift;
    return $self->{"list"}->_has_next( $self->{"pos"} );
}

sub next {
    my $self = shift;
    my ( $next_val, $next_pos ) = eval{ $self->{"list"}->_next( $self->{"pos"} ); };
    Carp::croak $@ if $@;
    $self->{"pos"} = $next_pos;
    return $next_val;
}

sub has_prev {
    my $self = shift;
    return $self->{"list"}->_has_prev( $self->{"pos"} );
}

sub prev {
    my $self = shift;
    my ( $prev_val, $prev_pos ) = eval{ $self->{"list"}->_prev( $self->{"pos"} ); };
    Carp::croak $@ if $@;
    $self->{"pos"} = $prev_pos;
    return $prev_val;
}

sub insert_prev {
    my $self = shift;
    $self->{"list"}->_insert_before( $self->{"pos"}, $_[0] );
}

sub insert_next {
    my $self = shift;
    $self->{"list"}->_insert_after( $self->{"pos"}, $_[0] );
}

sub remove_prev {
    my $self = shift;
    $self->{"list"}->_remove_before( $self->{"pos"} );
}

sub remove_next {
    my $self = shift;
    $self->{"list"}->_remove_after( $self->{"pos"} );
}

# ---- library private class emthods ----

sub _new {
    my $class = shift;
    my $list  = shift;
    my $pos   = shift;
    my $self = bless {
        # Iterator が存在するのに List が存在しないという状況を回避
        "list" => $list,
        "pos"  => $pos, 
    }, $class;
    return $self;
}

# ---- library private instance methods ----

sub _position {
    $_[0]->{"pos"};
}

1;
