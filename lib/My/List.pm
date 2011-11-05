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

sub insert_before {
    my $self = shift;
    my ( $val, $pos ) = @_;
    if( ref $pos ) {
        $pos->isa( "My::List::Iterator" ) or Carp::croak "unexpected position value";
        $pos = $pos->_position;
    } else {
        $pos = $self->__num_to_pos( $pos );
    }
    $self->__create_posobj_and_insert_before( $pos, $val );
    return $val;
}
sub insert_after {
    my $self = shift;
    my ( $val, $pos ) = @_;
}
sub remove_before {
    my $self = shift;
    my ( $pos ) = @_;
}
sub remove_after {
    my $self = shift;
    my ( $pos ) = @_;
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

# ---- library private functions ----

sub _has_next {
    my $pos = shift;
    while( 1 ) {
        if( ! $pos->{"next"} ) { return 0; }
        if( $pos->{"next"}->{"prev"} == $pos ) { return 1; }
        $pos = $pos->{"next"};
    }
}

sub _next {
    my $pos = shift;
    while( 1 ) {
        $pos->{"next"} or die "Next element doesn't exist!";
        if( $pos->{"next"}->{"prev"} == $pos ) {
            $pos = $pos->{"next"};
            last;
        }
        $pos = $pos->{"next"};
    }
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
    if( $self->{"b"} == $pos ) { die "Cant remove the first position"; }
    if( ! $prev->{"next"} or $prev->{"next"} != $pos ) {
        die "This position is already removed";
    }
    $prev->{"next"} = $next;
    if( $next ) { $next->{"prev"} = $prev; }
    if( $self->{"e"} == $pos ) { $self->{"e"} = $prev; }
    -- $self->{"length"};
    return $pos->{"value"};
}

sub __num_to_pos {
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

1;

