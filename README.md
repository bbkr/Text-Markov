# Markov chain based text generator for [Raku](https://www.raku.org) language

![test](https://github.com/bbkr/text_markov/workflows/test/badge.svg)

## SYNOPSIS

```raku
    use Text::Markov;
    
    my $mc = Text::Markov.new;
    
    $mc.feed( qw{Easy things should be easy and hard things should be possible.} );
    $mc.feed( qw{People who live in glass houses should not throw stones.} );
    $mc.feed( qw{Live and let live.} );
    
    say $mc.read( );
    # People who live in glass houses should be easy and let live.
```

## METHODS

Markov chain is a mathematical system.

To understand terminology used below read [OPERATING PRINCIPLE](#operating-principle) paragraph first.

### new( order => 2 )

Order (optional, default ```1```) controls how many past states determine possibe future states.

### feed( "foo", "bar", "baz" )

Add transitions of states.

State can be represented by any object that can be stringified to a nonempty string.

### read( 128 )

Generate chain of states up to requested length (optional, default ```1024```).

## OPERATING PRINCIPLE

Let's put abstract hat on and imagine that ___each word represents state___.

Therefore sentence made of words can be represented as ___transitions between states___.


For example sentence ```I like what I see``` is expressed by the following graph:


```
                            4     +------+
                     +------------| what |<----+
                     |            +------+     |
                     |                         |
                     v                         | 3
+-------+    1     +---+    2     +------+     |
| START |--------->| I |--------->| like |-----+
+-------+          +---+          +------+
                     |
                     |
                     |      5     +-----+    6     +-----+
                     +----------->| see |--------->| END |
                                  +-----+          +-----+
```

It may be surprising but transition number is not important for [feed](#feed-foo-bar-baz-) and can be discarded.

Instead of that transitions counters are stored (in this example each transition occured only once):


```
                           1x     +------+
                     +------------| what |<----+
                     |            +------+     |
                     |                         |
                     v                         | 1x
+-------+    1x    +---+    1x    +------+     |
| START |--------->| I |--------->| like |-----+
+-------+          +---+          +------+
                     |
                     |
                     |     1x     +-----+    1x    +-----+
                     +----------->| see |--------->| END |
                                  +-----+          +-----+
```

Next sentence```Now I see you like cookies``` when passed to [feed](#feed-foo-bar-baz-)
will simply add new transitions or increase counters of already existing ones in the same graph:


```
                           1x     +------+
                     +------------| what |<----+
                     |            +------+     |
                     |                         |
                     v                         | 1x
+-------+    1x    +---+    1x    +------+     |
| START |--------->| I |--------->| like |-----+
+-------+          +---+          +------+
    |               ^ |            ^    |
    |               | |         1x |    |
 1x |            1x | |            |    | 1x
    |   +-----+     | |        +-----+  |        +---------+
    +-->| Now |-----+ |        | you |  +------->| cookies |
        +-----+       |        +-----+           +---------+
                      |            ^                  |
                      |            | 1x               | 1x
                      |            |                  v
                      |    2x     +-----+    1x    +-----+
                      +---------->| see |--------->| END |
                                  +-----+          +-----+

```

[Markov chain](http://en.wikipedia.org/wiki/Markov_chain) is generated
by making transitions from the current state to one of the next possible future states
with respecting probability assigned to each transition.
The higher the counter the more probable transition is.


Let's generate:

* From ```START``` transition can be made to ```I``` [50% chance] or ```Now``` [50% chance] - ```I``` is rolled.
* From ```I``` transition can be made to ```like``` [33.(3)% chance] or ```see``` [66.(6)% chance] - ```like``` is rolled.
* From ```like``` transition can be made to ```what``` [50% chance] or ```cookies``` [50% chance] - ```cookies``` is rolled.
* From ```cookies``` transition can be made only to ```END``` [100% chance].

New sentence ```I like cookies``` is generated!


Note that it is not subpart of any sentence that was used by [feed](#feed-foo-bar-baz-) to create graph,
yet it has correct grammar and makes sense.

### Improving output quality

Default setup will produce a lot of nonsense. From sentences...

* ```I was tired.```
* ```It was snowing.```
* ```Today I was going to do something useful.```

...new sentence ```I was snowing.``` may be generated.


It happens because single ```was``` word does not give enough context to make rational transitions only.
Param ```order => 2``` in constructor restricts possible transitions to those which appears after two past states.
So from ```I was``` only two transitions are possible and more reasonable ```Today I was tired.``` sentence may be generated.

This is called [Markov chain of order m](http://en.wikipedia.org/wiki/Markov_chain#Variations).


The higher the order the more sensible output but more feed is also required. You have to experiment :)
