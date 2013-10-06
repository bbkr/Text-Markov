BEGIN @*INC.unshift( 'lib' );

use Test;
use Text::Markov;

plan( 18 );

# WARNING: Some tests are not deterministic!
# They check if expected chain _eventually_ appear
# so there is no guarantee that they will take finite time.

my ( $mc, %stats );

{
    lives_ok { $mc = Text::Markov.new }, 'simple constructor';

    # lack of objects should generate 0-length chain
    ok $mc.feed( ), 'empty feed';
    is $mc.read( ), Nil, 'empty read';

    # single object should be always picked as first chain element
    ok $mc.feed( 'foo' ), '"foo" feed';
    is_deeply $mc.read( ), [ 'foo' ], '"foo" read';

    # increase weights of the same object
    # it should still be picked as first chain element
    ok $mc.feed( 'foo' ), '"foo" feed again';
    is_deeply $mc.read( ), [ 'foo' ], '"foo"" read again';

    # feed another element
    # which may start chain in 1/3 of cases
    ok $mc.feed( 'bar' ), '"bar"" feed';
    loop {
        FIRST %stats = ( );
        %stats{ $mc.read( )[ 0 ] }++;
        last if %stats{ 'foo' } and %stats{ 'bar' };
    }
    pass '"foo" and "bar" eventually read';
}

{
    lives_ok { $mc = Text::Markov.new }, 'simple constructor';

    # ability to generate endless chain
    ok $mc.feed( 'foo', 'foo' ), '"foo" "foo" feed';
    is_deeply $mc.read( 8 ), [ 'foo', 'foo', 'foo', 'foo', 'foo', 'foo', 'foo', 'foo' ], '"foo" endless chain';
}

{
    lives_ok { $mc = Text::Markov.new( dimensions => 3 ) }, 'three dimensions constructor';

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
    lives_ok { $mc = Text::Markov.new( dimensions => 8 ) }, 'eight dimensions constructor';

    # feed shorter than amount of dimensions
    ok $mc.feed( 'foo', 'bar', 'baz' ), '"foo" "bar" "baz" feed';
    is_deeply $mc.read( ), [ 'foo', 'bar', 'baz' ], '"foo" "bar" "baz" read'; 
}
