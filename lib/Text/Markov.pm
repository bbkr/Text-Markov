class Text::Markov;

has %!graph;
has Int $.dimensions is rw = 1;


method feed( *@t ) {

    for ^@t.elems -> $i {
        
        # pointer starts at first Hash dimension
        # and will eventually reach terminal KeyBag
        my $p := %!graph;
        
        # create Hash dimensions
        for (^$.dimensions).reverse -> $j {
            
            # move pointer to next Hash dimension,
            # use empty string if precedessor is not available
            $p := $p{ ( $i - $j < 1 )  ?? '' !! @t[ $i - $j - 1 ] };
        }
        
        # terminal KeyBag may not be created yet
        $p //= KeyBag.new;
        
        # increase weight for current item
        $p{ @t[$i] }++;
    }
    %!graph.perl.say;
}