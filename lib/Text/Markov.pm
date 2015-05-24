unit class Text::Markov;

has %!graph;
has Int $!order;

submethod BUILD ( Int :$order where { $order.defined.not or $order >= 1 } ) {
    $!order = $order // 1;
}

method feed ( *@states where { [&&]( @states>>.chars ) } ) returns Bool {

    # convert Array of objects into multidimensional Hash of predecessors
    # that ends with BagHash containing successors with occurrence weights
    for ^@states.elems -> $i {
        
        # pointer starts at the beginning of predecessors Hash
        # and will eventually reach successors BagHash
        my $p := %!graph;
        
        # create Hash path of predecessors
        # its length is equal to the order param
        for ( ^$!order ).reverse -> $j {
            
            # move pointer to next Hash level
            # use empty string if predecessor is not available
            $p := $p{ ( $i - $j < 1 )  ?? '' !! @states[ $i - $j - 1 ] };
        }
        
        # successors BagHash may not be created yet
        $p //= BagHash.new;
        
        # increase occurrence weight for current successor
        $p{ @states[ $i ] }++;
    }
    
    return True;
}

method read ( Int $length where { $length >= 1 } = 1024 ) returns Array {

    # output Array of objects
    my @o;
    
    # find successors BagHash in Hash
    loop {
        
        # pointer starts at the beginning of predecessors Hash
        # and will eventually reach successors BagHash
        my $p := %!graph;
        
        # for amount equals to the order param
        # of objects at the end of the output 
        # move through Hash path of predecessors
        for ( ^$!order ).reverse -> $i {
            
            # move pointer to next Hash level
            # use empty string if predecessor is not available
            $p := $p{ ( @o.elems - $i > 0 ) ?? @o[ * - $i - 1 ] !! '' };
        }
        
        # no successors are available
        last unless $p ~~ BagHash;
        
        # choose successor based on occurrence weights
        @o.push: $p.roll( );
        
        # finish if desired length is reached
        last if @o.elems ~~ $length;
    }
    
    return @o;
}
