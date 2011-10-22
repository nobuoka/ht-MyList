use strict;
use warnings;

use My::List;

package My::List::Iterator;

sub new {
    my $class = shift;
    my $list  = shift;
    my $self = bless {
        # Iterator が存在するのに List が存在しないという状況を回避
        "list" => $list,
        # 循環参照により Iterator が破棄されない状況を回避
        "impl" => {
            "prev_elem" => undef, 
            "next_it" => undef,
            "prev_it" => undef,
        }
    }, $class;
    _register( $self->{"impl"}, $list->{"b"} );
    return $self;
}

sub DESTROY {
    my $self = shift;
    _unregister( $self->{"impl"} );
}

sub has_next {
    my $self = shift;
    return ! ! ( $self->{"impl"}{"prev_elem"}{"next"} );
}

sub next {
    my $self = shift;
    my $next_elem = $self->{"impl"}{"prev_elem"}{"next"};
    #$self->{"impl"}{"prev_elem"} = $next_elem;
    _unregister( $self->{"impl"} );
    _register( $self->{"impl"}, $next_elem );
    return $next_elem->{"value"};
}

# ---- library private functions ----

sub _register {
    my ( $it_impl, $elem ) = @_;
    $it_impl->{"prev_elem"} = $elem;
    if( $elem->{"it"} ) { # 同じ位置を指す Iterator が存在する場合
        if( $elem->{"it"}{"next_it"} ) { # 同じ位置を指す Iterator が既に 2 個以上存在
            my ( $n, $p ) = ( $elem->{"it"}{"next_it"}, $elem->{"it"} );
            $it_impl->{"next_it"} = $n;
            $it_impl->{"prev_it"} = $p;
            $n->{"prev_it"} = $it_impl;
            $p->{"next_it"} = $it_impl;
        } else { # 同じ位置を指す Iterator が元々 1 個
            $elem->{"it"}{"next_it"} = $elem->{"it"}{"prev_it"} = $it_impl;
            $it_impl->{"next_it"} = $it_impl->{"prev_it"} = $elem->{"it"};
        }
    } else { # 同じ位置を指す Iterator が元々存在しない
        $elem->{"it"} = $it_impl;
    }
}

sub _unregister {
    my ( $it_impl ) = @_;
    my $elem = $it_impl->{"prev_elem"};
    $elem->{"it"} = $it_impl->{"next_it"} if( $elem->{"it"} == $it_impl );
    if( $it_impl->{"next_it"} ) { # 同じ位置を指す Iterator が他に存在する場合
        if( $it_impl->{"next_it"} == $it_impl->{"prev_it"} ) {
            my $a = $it_impl->{"next_it"};
            $a->{"next_it"} = $a->{"prev_it"} = undef;
        } else {
            my ( $n, $p ) = ( $it_impl->{"next_it"}, $it_impl->{"prev_it"} );
            $n->{"prev_it"} = $p;
            $p->{"next_it"} = $n;
        }
        $it_impl->{"next_it"} = $it_impl->{"prev_it"} = undef;
    } # else { # 同じ位置を指す Iterator が他に存在しない場合
    $it_impl->{"prev_elem"} = undef;
    #}
}

1;
