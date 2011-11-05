use strict;
use warnings;
use Carp;

use My::List::Iterator;

package My::List;

sub new {
    my $class = shift;
    my $self  = bless { "b" => undef, "e" => undef, "length" => -1 }, $class;
    $self->__create_posobj_and_insert_before( undef, undef );
    return $self;
}

# DESTROY 時には Iterator は存在しない
sub DESTROY {
    my $self = shift;
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

sub insert {
    my $self = shift;
    my ( $pos, $val ) = @_;
    #if( ref $pos ) {
    #    $pos->isa( "My::List::Iterator" ) or Carp::croak "unexpected position value";
    #    $pos = $pos->_position;
    #} else {
    $pos = $self->__idx_to_pos( $pos );
    #}
    $self->__create_posobj_and_insert_before( $pos->{"next"}, $val, 1 );
    return $val;
}

sub remove {
    my $self = shift;
    my ( $idx ) = @_;
    if( $idx < 0 or $self->{"length"} <= $idx ) {
        Carp::croak "Invalid index (" . $idx . ")";
    }
    my $pos = $self->__idx_to_pos( $idx );
    $self->__remove_posobj_and_return_prev_value( $pos->{"next"} );
}

sub append {
    my $self = shift;
    my $value = shift;
    my $elem = $self->__create_posobj_and_insert_before( undef, $value );
    return $value;
}
sub push {
    goto &append;
}

sub pop {
    my $self = shift;
    $self->{"e"} != $self->{"b"} or Carp::croak "No item exists";
    return $self->__remove_posobj_and_return_prev_value( $self->{"e"} );
}

sub size {
    my $self = shift;
    $self->{"length"};
}

sub iterator {
    my $self = shift;
    return My::List::Iterator->new( $self, $self->{"b"} );
}

sub to_array_ref {
    my $self = shift;
    my $e = $self->{"b"}{"next"};
    my $aref = [];
    while( $e ) {
        CORE::push @$aref, $e->{"value"};
#print "e ", $e, "\n";
#sleep 1;
        $e = $e->{"next"};
    }
    return $aref;
}

# ---- library private methods ----

sub _has_next {
    my $self = shift;
    my $pos = shift;
    $pos = $self->__normalize_pos( $pos );
    return ! ! $pos->{"next"};
}

sub _next {
    my $self = shift;
    my $pos = shift;
    $pos = $self->__normalize_pos( $pos );
    $pos = $pos->{"next"} or die "next element doesn't exist";
    return ( $pos->{"value"}, $pos );
}

# ---- private methods ----

# リストの位置 (およびその位置の前の値) を保持する連想配列を作り, 指定された位置に挿入する.
# 作った連想配列を返す
sub __create_posobj_and_insert_before {
    my $self = shift;
    my ( $next, $val, $not_exchange ) = @_;
#if( $next ) { print "next ", $next, $next->{"prev"} ? ", next->prev " . $next->{"prev"} : "", 
#$next->{"next"} ? ", next->next " . $next->{"next"} : "", "\n"; }
    my $prev = ( $next ? $next->{"prev"} : $self->{"e"} );
#if( $prev ) { print "prev ", $prev, $prev->{"prev"} ? ", prev->prev " . $prev->{"prev"} : "", 
#$prev->{"next"} ? ", prev->next " . $prev->{"next"} : "", "\n"; }
    my $pos = { "next" => $next, "prev" => $prev, "value" => $val };
    if( $next ) { $next->{"prev"} = $pos; }
    if( $prev ) { $prev->{"next"} = $pos; }
    if( ( ! $self->{"b"} ) or ( $next and $next == $self->{"b"} ) ) { $self->{"b"} = $pos; }
    if( ( ! $self->{"e"} ) or ( $prev and $prev == $self->{"e"} ) ) { $self->{"e"} = $pos; }
    if( $next and ! $not_exchange ) {
        ( $pos->{"value"}, $next->{"value"} ) = ( $next->{"value"}, $pos->{"value"} );
    }
    ++ $self->{"length"}; 
    return $pos;
}

sub __remove_posobj_and_return_prev_value {
    my $self = shift;
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
    my $self = shift;
    my $num = shift;
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
    my $self = shift;
    my $pos = shift;
    while( $pos->{"npos"} ) {
        $pos = $pos->{"npos"};
    }
    return $pos;
}

1;

