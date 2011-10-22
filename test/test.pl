use strict;
use warnings;

use My::List;

sub test {
    my $list = new My::List();
    $list->append( "va" );
$list->append( "vvv" );
my $it1 = $list->iterator;
my $it2 = $list->iterator;
my $it3 = $list->iterator;
while( $it1->has_next ) {
    print $it1->next, "\n";
    print $it2->next, "\n";
    print $it3->next, "\n";
}
}

&test;
&test;
&test;


