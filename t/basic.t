BEGIN @*INC.unshift( 'lib' );

use Test;
use Text::Markov;

plan( 21 );

# WARNING: Some tests are not deterministic!
# They check if expected chain _eventually_ appear
# so there is no guarantee that they will take finite time.

my ( $mc, %stats );

{
    lives-ok { $mc = Text::Markov.new }, 'constructor with default order';

    # lack of objects should generate 0-length chain
    ok $mc.feed( ), 'empty feed';
    is-deeply $mc.read( ), [ ], 'empty read';

    # single object should be always picked as first chain element
    ok $mc.feed( 'foo' ), '"foo" feed';
    is-deeply $mc.read( ), [ 'foo' ], '"foo" read';

    # increase weights of the same object
    # it should still be picked as first chain element
    ok $mc.feed( 'foo' ), '"foo" feed again';
    is-deeply $mc.read( ), [ 'foo' ], '"foo" read again';

    # feed another element
    # which may start chain in 1/3 of cases
    ok $mc.feed( 'bar' ), '"bar" feed';
    loop {
        FIRST %stats = ( );
        %stats{ $mc.read( )[ 0 ] }++;
        last if %stats{ 'foo' } and %stats{ 'bar' };
    }
    pass '"foo" and "bar" eventually read';
}

{
    lives-ok { $mc = Text::Markov.new }, 'constructor with default order';

    # ability to generate endless chain
    ok $mc.feed( 'foo', 'foo' ), '"foo" "foo" feed';
    is-deeply $mc.read( 8 ), [ 'foo', 'foo', 'foo', 'foo', 'foo', 'foo', 'foo', 'foo' ], '"foo" endless chain';
}

{
    lives-ok { $mc = Text::Markov.new( order => 3 ) }, 'constructor for order of 3';

    ok $mc.feed( qw{easy things should be easy and hard things should be possible} ), 'Larry quote feed';
    loop {
        FIRST %stats = ( );
        %stats{ $mc.read( ).join( ' ' ) }++;
        last if %stats{ 'easy things should be possible' }
            and %stats{ 'easy things should be easy and hard things should be possible' }
            and %stats{ 'easy things should be easy and hard things should be easy and hard things should be possible' };
    }
    pass 'Larry quote eventually read in three ways'
}

{
    lives-ok { $mc = Text::Markov.new( order => 8 ) }, 'constructor for order of 8';

    # feed shorter than order
    ok $mc.feed( 'foo', 'bar', 'baz' ), '"foo" "bar" "baz" feed';
    is-deeply $mc.read( ), [ 'foo', 'bar', 'baz' ], '"foo" "bar" "baz" read'; 
}

{
    dies-ok { Text::Markov.new( order => -1 ) }, 'constructor with invalid order';

    $mc = Text::Markov.new;

    dies-ok { $mc.feed( '' ) }, 'feed with invalid empty string';
    dies-ok { $mc.read( -1 ) }, 'read with invalid length';
}
