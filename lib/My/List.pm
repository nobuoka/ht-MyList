use strict;
use warnings;

package My::List;

sub new {
    my $class = shift;
    bless {
        "b" => undef,
        "e" => undef,
        "length" => 0
    }, $class;
}

sub append {
    my $self = shift;
    my $value = shift;
    my $elem = {
        "next" => undef,
        "prev" => $self->{"e"},
        "value" => $value
    };
    $self->{"e"}{"next"} = $elem if $self->{"e"};
    $self->{"e"} = $elem;
    $self->{"b"} = $elem unless $self->{"b"};
    ++ $self->{"length"}; 
}

sub iterator {
    my $self = shift;
    My::List::Iterator->new( $self );
}

package My::List::Iterator;

sub new {
    my $class = shift;
    my $list  = shift;
    bless {
        "next_elem" => $list->{"b"}
    }, $class;
}

sub has_next {
    my $self = shift;
    return !!( $self->{"next_elem"} );
}

sub next {
    my $self = shift;
    my $next_elem = $self->{"next_elem"};
    $self->{"next_elem"} = $next_elem->{"next"};
    return $next_elem->{"value"};
}

1;
