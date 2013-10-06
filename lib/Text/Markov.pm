class Text::Markov;

has %!graph;
has Int $.dimensions is rw = 1;

method feed ( *@o ) {

    # convert Array of objects into multidimensional Hash of predecessors
    # that ends with KeyBag containing successors with occurrence weights
    for ^@o.elems -> $i {
        
        # pointer starts at the beginning of predecessors Hash
        # and will eventually reach successors KeyBag
        my $p := %!graph;
        
        # create Hash dimensions of predecessors
        for ( ^$.dimensions ).reverse -> $j {
            
            # move pointer to next Hash dimension,
            # use empty string if predecessor is not available
            $p := $p{ ( $i - $j < 1 )  ?? '' !! @o[ $i - $j - 1 ] };
        }
        
        # successors KeyBag may not be created yet
        $p //= KeyBag.new;
        
        # increase occurrence weight for current successor
        $p{ @o[ $i ] }++;
    }
    
    return True;
}

method read ( Int $l? ) {

    # output Array of objects
    my @o;
    
    # find successors KeyBag in Hash
    loop {
        
        # pointer starts at the beginning of predecessors Hash
        # and will eventually reach successors KeyBag
        my $p := %!graph;
        
        # move through Hash dimensions using predecessors from output
        for ( ^$.dimensions ).reverse -> $i {
            
            # move pointer to next Hash dimension,
            # use empty string if predecessor is not available
            $p := $p{ ( @o.elems - $i > 0 ) ?? @o[ * - $i - 1 ] !! '' };
        }
        
        # no successors are available
        last unless $p ~~ KeyBag;
        
        # choose successor based on occurrence weights
        @o.push: $p.roll( );
        
        # finish if desired length is reached
        last if defined $l and @o.elems ~~ $l;
    }
    
    return @o;
}
