use strict;
use warnings;
use Carp;

package My::List::Iterator;

# ---- public instance methods ----

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
