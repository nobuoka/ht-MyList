use strict;
use warnings;
use Carp;

use My::List::Iterator;

package My::List;

sub new {
    my $class = shift;
    my $begin_elem = {
        "next" => undef,
        "prev" => undef,
        "value" => undef,
    };
    bless {
        "b" => $begin_elem,
        "e" => $begin_elem,
        "length" => 0
    }, $class;
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
        print "DESTROY", "\n";
    } while( $e = $n )
}

sub append {
    my $self = shift;
    my $value = shift;
    my $elem = {
        "next" => undef,
        "prev" => $self->{"e"},
        "value" => $value,
    };
    $self->{"e"}{"next"} = $elem;
    $self->{"e"} = $elem;
    ++ $self->{"length"}; 
    return $value;
}

sub iterator {
    my $self = shift;
    return My::List::Iterator->new( $self, $self->{"b"} );
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

1;

