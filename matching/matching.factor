
USING: 2dmastermind.grid accessors math kernel sequences locals ;
IN: 2dmastermind.matching

TUPLE: matches
    { exact integer }
    { row-column integer }
    { color integer } ;

<PRIVATE

: push-pair ( pair -- x y )
    [ first ] [ second ] bi ;

PRIVATE>

: find-exact-matches ( used grid grid -- used n )
    [let :> ( lhs rhs )
     0 over positions
     [
         push-pair :> ( used n x y )
         x y used grid-at not
         x y lhs grid-at x y rhs grid-at =
         and
         [ t x y used grid-put n 1 + ] [ used n ] if
     ] each
    ] ;

: find-matches ( grid grid -- matches )
    f over bounds grid-of -rot
    [ find-exact-matches swap ] [ 2drop 0 swap ] [ 2drop 0 swap ] 2tri
    drop \ matches boa ;
