BEGIN @*INC.unshift( 'lib' );

use Test;
use Text::Markov;

plan( 1 );

my $mc = Text::Markov.new( dimensions=>1);
$mc.feed( 'Ala', 'ma', 'kota', '.', 'Kot', 'ma', 'Alę', '.');