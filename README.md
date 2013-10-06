# Markov chain based text generator

## SYNOPSIS

```perl
    use Text::Markov;
    
    my $mc = Text::Markov.new;
    
    $mc.feed( qw{Easy things should be easy and hard things should be possible.} );
    $mc.feed( qw{People who live in glass houses should not throw stones.} );
    $mc.feed( qw{You can not have your cake and eat it too.} );
    
    say $mc.read( 1024 );
    # People who live in glass houses should be easy and eat it too.
    
```

## METHODS

### new( dimensions => 2 )

Dimensions (optional, default ```1```) controls how many predecessors in a row should determine successor weights.

### feed( "foo", "bar", "baz" )

Add sequence of objects to Markov graph.

### read( 128 )

Generate chain of objects up to requested length (optional, default ```1024```).

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## CONTACT

You can find me (and many awesome people who helped me to develop this module)
on irc.freenode.net #perl6 channel as **bbkr**.
