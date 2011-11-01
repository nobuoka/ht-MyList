use strict;
use warnings;
use Carp;

use My::List;

package My::List::Iterator;

sub new {
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

sub has_next {
    my $self = shift;
    return My::List::_has_next( $self->{"pos"} );
}

sub next {
    my $self = shift;
    my ( $next_val, $next_pos ) = eval{ My::List::_next( $self->{"pos"} ); };
    Carp::croak $@ if $@;
    $self->{"pos"} = $next_pos;
    return $next_val;
}

1;
