# Markov chain based text generator

## SYNOPSIS

```perl
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

For example sentence ```I like what I see``` is expressed by following graph:

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

It may be surprising but transition number is not important and can be discarded.
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

Next sentence ```Now I see you like cookies``` in the same graph
will simply add new transitions or increase counters of already existing ones:

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

* From ```START``` transition can be made to ```I``` [50% chance] or ```Now``` [50% chance]. ```I``` is rolled.
* From ```I``` transition can be made to ```like``` [33.(3)% chance] or ```see``` [66.(6)% chance]. ```like``` is rolled.
* From ```like``` transition can be made to ```what``` [50% chance] or ```cookies``` [50% chance]. ```cookies``` is rolled.
* From ```cookies``` transition can be made only to ```END``` [100% chance].

New sentence ```I like cookies``` is generated!


### Improving output quality



Default setup will produce a lot of nonsense. From sentences ```I was tired.```, ```It was snowing.``` and ```Today I was going to do something useful.``` new sentence ```I was snowing.``` may be generated. It happens because single ```was``` word does not give enough context to make rational transitions only (to understand transitions check [OPERATING PRINCIPLE](#operating-principle) paragraph).

Param ```order => 2``` in constructor restricts possible transitions to those which appears after two past words.
so now future state depends on the past m states
So from ```I was``` only two jumps are possible and more reasonable ```Today I was tired.``` sentence may be generated.

***So:*** How many dimensions is enough?

Unfortunately there is no universal answer.
It all depends on language used because some languages carry more context in a single word than the others.

Let's take a look at two sentences:
```
    I read         a book.
    Przeczytałem   książkę.
```

In polish language informations - 'first person', 'past time', 'type of action' - are packed into one word ```Przeczytałem```,
which also enforces [accusative case](http://en.wikipedia.org/wiki/Accusative_case) on word ```książka``` transforming it into ```książkę```.
While in english four words total (including ```a```) are used and despite that there is still time ambiguity.

So english is more prone to successor nonsenses and requires higher ```dimension``` value and more feeds than polish.

You have to experiment :)

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## CONTACT

You can find me (and many awesome people who helped me to develop this module)
on irc.freenode.net #perl6 channel as **bbkr**.
