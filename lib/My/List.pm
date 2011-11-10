use strict;
use warnings;
use Carp;

use My::List::Iterator;

package My::List;

# ---- destructor ----

# DESTROY 時には Iterator は存在しない
sub DESTROY {
    my $self = CORE::shift;
    my $e = $self->{"b"};
    my $n;
    do {
        $n = $e->{"next"};
        foreach( keys %$e ) {
            undef $e->{$_}; 
        }
        #print "DESTROY", "\n";
    } while( $e = $n )
}

# ---- public class methods ----

sub new {
    my $class = CORE::shift;
    my $self  = bless {}, $class;
    $self->__initialize();
    return $self;
}

# ---- public instance methods ----

sub insert {
    my $self = CORE::shift;
    my ( $pos, $val ) = @_;
    $pos = $self->__idx_to_pos( $pos );
    $self->_insert_after( $pos, $val );
    return $val;
}

sub remove {
    my $self = CORE::shift;
    my ( $idx ) = @_;
    if( $idx < 0 or $self->{"length"} <= $idx ) {
        Carp::croak "Invalid index (" . $idx . ")";
    }
    my $pos = $self->__idx_to_pos( $idx );
    $self->_remove_after( $pos );
}

sub append {
    my $self = CORE::shift;
    my $value = CORE::shift;
    my $elem = $self->_insert_after( $self->{"e"}, $value );
    return $value;
}
sub push {
    goto &append;
}

sub pop {
    my $self = CORE::shift;
    $self->{"e"} != $self->{"b"} or Carp::croak "No item exists";
    return $self->_remove_before( $self->{"e"} );
}

sub unshift {
    my $self = CORE::shift;
    my $value = CORE::shift;
    my $elem = $self->_insert_before( $self->{"b"}, $value );
    return $value;
}

sub shift {
    my $self = CORE::shift;
    $self->{"e"} != $self->{"b"} or Carp::croak "No item exists";
    return $self->_remove_after( $self->{"b"} );
}

sub size {
    my $self = CORE::shift;
    $self->{"length"};
}

sub iterator {
    my $self = CORE::shift;
    return My::List::Iterator->_new( $self, $self->{"b"} );
}

# 指定した位置を開始位置とするイテレータを生成
sub iterator_at {
    my $self = CORE::shift;
    my $pos  = CORE::shift;
    $pos = $self->__idx_to_pos( $pos );
    return My::List::Iterator->_new( $self, $pos );
}

sub to_array_ref {
    my $self = CORE::shift;
    my $e = $self->{"b"}{"next"};
    my $aref = [];
    while( $e ) {
        CORE::push @$aref, $e->{"value"};
        $e = $e->{"next"};
    }
    return $aref;
}

# ---- library private instance methods ----

sub _has_next {
    my $self = CORE::shift;
    my $pos  = CORE::shift;
    $pos = $self->__normalize_pos( $pos );
    return ! ! $pos->{"next"};
}

sub _next {
    my $self = CORE::shift;
    my $pos  = CORE::shift;
    $pos = $self->__normalize_pos( $pos );
    $pos = $pos->{"next"} or die "next element doesn't exist";
    return ( $pos->{"value"}, $pos );
}

sub _has_prev {
    my $self = CORE::shift;
    my $pos  = CORE::shift;
    $pos = $self->__normalize_pos( $pos );
    return ! ! $pos->{"prev"};
}

sub _prev {
    my $self = CORE::shift;
    my $pos  = CORE::shift;
    $pos = $self->__normalize_pos( $pos );
    my $val = $pos->{"value"};
    $pos = $pos->{"prev"} or die "next element doesn't exist";
    return ( $val, $pos );
}

sub _insert_after {
    my $self = CORE::shift;
    my ( $pos, $val ) = @_;
    $pos = $self->__normalize_pos( $pos );
    my $elem = $self->__create_posobj_and_insert_before( $pos->{"next"}, $val, 1 );
}

sub _insert_before {
    my $self = CORE::shift;
    my ( $pos, $val ) = @_;
    $pos = $self->__normalize_pos( $pos );
    my $elem = $self->__create_posobj_and_insert_before( $pos, $val );
}

sub _remove_after {
    my $self = CORE::shift;
    my $pos  = CORE::shift;
    $pos = $self->__normalize_pos( $pos );
    $self->__remove_posobj_and_return_prev_value( $pos->{"next"} );
}

sub _remove_before {
    my $self = CORE::shift;
    my $pos  = CORE::shift;
    $pos = $self->__normalize_pos( $pos );
    $self->__remove_posobj_and_return_prev_value( $pos );
}

# ---- private methods ----

# リストの位置 (およびその位置の前の値) を保持する連想配列を作り, 指定された位置に挿入する.
# 作った連想配列を返す
# 
# param $next : どの posobj の前に挿入するかを表す. リストの最後に加える際は undef を指定する.
# param $val  : 新たに挿入した posobj が保持する値. (新たな posobj が表す位置の前に存在する値として扱われる)
# param $not_exchange : 挿入した posobj と第 1 引数の posobj が持っている値を交換するかどうかを表す真偽値. 
#           (イテレータの指す位置を考慮すると必要)
# return : 新たに生成された posobj (ただの連想配列)
sub __create_posobj_and_insert_before {
    my $self = CORE::shift;
    my ( $next, $val, $not_exchange ) = @_;
    my $prev = ( $next ? $next->{"prev"} : $self->{"e"} );
    my $pos = { "next" => $next, "prev" => $prev, "value" => $val };
    if( $next ) { $next->{"prev"} = $pos; }
    if( $prev ) { $prev->{"next"} = $pos; }
    if( $next and $next == $self->{"b"} ) { $self->{"b"} = $pos; }
    if( $prev and $prev == $self->{"e"} ) { $self->{"e"} = $pos; }
    if( $next and ! $not_exchange ) {
        ( $pos->{"value"}, $next->{"value"} ) = ( $next->{"value"}, $pos->{"value"} );
    }
    ++ $self->{"length"}; 
    return $pos;
}

sub __remove_posobj_and_return_prev_value {
    my $self = CORE::shift;
    my ( $pos ) = @_;
    my ( $next, $prev ) = ( $pos->{"next"}, $pos->{"prev"} );
    if( ! $pos ) { die; }
    if( $self->{"b"} == $pos ) { die "Cant remove the first position"; }
    if( $prev->{"npos"} ) {
        die "This position is already removed";
    }
    $prev->{"next"} = $next;
    if( $next ) { $next->{"prev"} = $prev; }
    if( $self->{"e"} == $pos ) { $self->{"e"} = $prev; }
    my $val = $pos->{"value"};
    $pos->{"npos"} = $pos->{"prev"};
    undef $pos->{"value"};
    undef $pos->{"prev"};
    undef $pos->{"next"};
    -- $self->{"length"};
    return $val;
}

sub __idx_to_pos {
    my $self = CORE::shift;
    my $num = CORE::shift;
    if( $num < 0 or $self->{"length"} < $num ) {
        die "invalid index (" . $num . ")";
    }
    my $pos = $self->{"b"};
    for( my $i = 0; $i < $num; ++ $i ) {
        $pos = $pos->{"next"};
    }
    return $pos;
}

sub __normalize_pos {
    my $self = CORE::shift;
    my $pos = CORE::shift;
    while( $pos->{"npos"} ) {
        $pos = $pos->{"npos"};
    }
    return $pos;
}

sub __initialize {
    my $self = CORE::shift;
    ( ( ! defined $self->{"b"} ) and ( ! defined $self->{"length"} ) and ( ! defined $self->{"e"} ) ) or
        die "already initialied";
    $self->{"e"} = $self->{"b"} = { "next" => undef, "prev" => undef, "value" => undef };
    $self->{"length"} = 0;
}

1;

