unit class Text::Markov;

has Int:D $.order = 1;
has %!graph;

method feeder ( Seq:D $states ) returns Bool {

    my @predecessors;

    for $states.List -> $successor {

        # get successors location,
        # this will also pad Array if shorter than chain order
        my $successors := self!successors( @predecessors );

        # successors BagHash may not be created yet
        $successors //= BagHash.new;

        # increase occurrence weight for current successor
        $successors{ $successor.Str }++;

        # newest successor pushes out oldest predecessor
        @predecessors.shift;
        @predecessors.push( $successor );

    }

    return True;
}

multi method feed ( *@states ) returns Bool {

    return self.feeder( @states.Seq );
}

method reader ( *@predecessors is copy where { .elems <= $!order } ) returns Seq {

    return lazy gather loop {

        # take provided predecessors to include them in sequence
        FIRST .take for @predecessors;

        # get successors location,
        # this will also pad Array if shorter than chain order
        my $successors := self!successors( @predecessors );

        # no successors are available
        last unless $successors ~~ BagHash;

        # choose successor based on occurrence weights
        my $successor = $successors.roll( );

        # add successor to sequence
        take $successor;

        # newest successor pushes out oldest predecessor
        @predecessors.shift;
        @predecessors.push( $successor );

    }

}

method read ( Int:D $length where { $length >= 1 } = 1024 ) returns List {

    return self.reader[ ^$length ]:v;
}

method !successors ( @predecessors ) {

    # left pad predecessors Array with empty strings
    # if provided amount is lesser than chain order
    @predecessors.unshift( '' ) while @predecessors.elems < $!order;

    # pointer starts at the beginning of predecessors Hash
    # and will eventually reach successors expected BagHash location
    my $p := %!graph;

    for ^$!order -> $i {

        # move pointer to next Hash level
        $p := $p{ @predecessors[ $i ].Str };
    }

    # return successors location, may be not initialized yet
    return-rw $p;
}
