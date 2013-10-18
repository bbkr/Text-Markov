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

[Markov chain](http://en.wikipedia.org/wiki/Markov_chain) is generated
by making transitions from the current state [word] to one of the next possible future states [words]
with respecting probability assigned to each transition.

Let's feed following transitions of states [sentences made of subsequent words]:

```
    foo qux
    foo bar
    foo bar baz
    bar foo baz bar
```
And run algorithm:

1. Output chain can start in ```foo``` state (75% chance) or ```bar``` state (25% chance). Let's assume ```foo``` was chosen.
2. From ```foo``` state it can make transition to ```bar``` state (50% chance) or ```baz``` state (25% chance) or ```qux``` state (25% chance). Let's assume ```bar``` was chosen.
3. From ```bar``` state it can make transition to ```foo``` state (25% chance) or ```baz``` state (25% chance) or it can terminate (50% chance). Let's assume ```foo``` was chosen.
4. From ```foo``` state possible transitions were already explained in 2. Let's assume ```baz``` was chosen this time.
5. From ```baz``` state it can make transition to ```bar``` state (50% chance) or it can terminate (50% chance). Let's assume it terminates.

The output chain of states [words that create new sentence]:

```
foo bar foo baz
```

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
