
USING: 2dmastermind.grid 2dmastermind.util accessors math kernel
sequences locals math.ranges arrays monads fry prettyprint sets hashtables
assocs math.order ;
IN: 2dmastermind.matching

TUPLE: matches
    { exact integer }
    { row-column integer }
    { color integer } ;

<PRIVATE

TUPLE: row-column-state
    { used grid }
    { count integer } ;

: push-pair ( pair -- x y )
    [ first ] [ second ] bi ;

: all-placements ( state pair -- pairs )
    [ used>> bounds ] [ push-pair ] bi*
    [let :> ( w h x y )
     w [0,b) [ y 2array ] map
     h [0,b) [ x swap 2array ] map
     append ] ;

: distinct-values ( grid -- arr )
    dup positions
    [ push-pair pick grid-at ] map
    nip members ;

: succ-at ( key assoc -- )
    [ 1 ] 2dip at+ ;

: values-with-count ( grid -- assoc )
    10 <hashtable>
    over positions
    [ pick [ push-pair ] dip grid-at over succ-at ] each
    nip ;

:: possible-placements ( state value lhs rhs pair -- states )
    pair push-pair rhs grid-at :> peg
    value peg = not
    [
        state 1array
    ] [
        state pair all-placements
        [
            [ push-pair lhs grid-at peg = ]
            [ push-pair state used>> grid-at not ]
            bi and
        ] filter
        [
            t swap push-pair
            state clone
            [ grid-put ] change-used
            [ 1 + ] change-count
        ] map
        state suffix
    ] if ;

: total-matches-for ( used value grid grid -- used n )
    [let :> ( value lhs rhs )
      0 \ row-column-state boa 1array
      rhs positions
      [
          '[ value lhs rhs _ possible-placements ] bind
      ] each
      [ count>> ] maximum-by
      [ used>> ] [ count>> ] bi
    ] ;

PRIVATE>

! I implicitly exploit a lot of properties of the 2-dimensional
! playing field here. This game's rules *can* be extended in a
! well-defined way to higher dimensions, but to do so we'd have to
! rewrite this algorithm to use backtracking (the array monad, as used
! in total-matches-for) across the entire computation. I'm pretty sure
! that doing so in general makes this solutions intractible for
! dimensions >= 3, due to the sheer amount of branching necessary.
! There may be optimizations I'm missing, but the naive approach, I
! think, fails.

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

: find-row-column-matches ( used grid grid -- used n )
    [let :> ( lhs rhs )
     0 swap rhs distinct-values
     [ lhs rhs total-matches-for swap [ + ] dip 2dup . . ] each
     swap
    ] ;

: find-color-matches ( used grid grid -- n )
    [ values-with-count ] bi@ [ min ] assoc-intersect-with values sum swap
    dup positions [ push-pair pick grid-at ] count nip - ;

: find-matches ( grid grid -- matches )
    f over bounds grid-of -rot
    [ find-exact-matches swap ] [ find-row-column-matches swap ] [ find-color-matches ] 2tri
    \ matches boa ;
