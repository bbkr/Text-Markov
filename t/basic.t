BEGIN @*INC.unshift( 'lib' );

use Test;
use Text::Markov;

plan( 1 );

my $mc;

lives_ok { $mc = Text::Markov.new }, 'simple consructor';

is $mc.feed( ), Nil, 'empty feed';
is $mc.read( ), Nil, 'empty read';

# my $mc = Text::Markov.new( dimensions=>3);
# $mc.feed( <easy things should be easy and hard things should be possible>);
# say $mc.read( 7);