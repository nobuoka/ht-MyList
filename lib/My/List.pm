use strict;
use warnings;

use My::List::Iterator;

package My::List;

sub new {
    my $class = shift;
    my $begin_elem = {
        "next" => undef,
        "prev" => undef,
        "value" => undef,
        "it" => undef,
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
        my @keys = keys %$e;
        foreach( @keys ) {
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
        "it" => undef,
    };
    $self->{"e"}{"next"} = $elem;
    $self->{"e"} = $elem;
    ++ $self->{"length"}; 
    return $value;
}

sub iterator {
    my $self = shift;
    return My::List::Iterator->new( $self );
}

1;

