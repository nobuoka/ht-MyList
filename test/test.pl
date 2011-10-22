use strict;
use warnings;

use My::List;

my $list = new My::List();
$list->append( "va" );
$list->append( "vvv" );
my $iterator = $list->iterator;
while( $iterator->has_next ) {
    print $iterator->next, "\n";
}

