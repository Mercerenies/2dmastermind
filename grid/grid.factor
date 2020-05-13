
USING: arrays sequences kernel math accessors locals
math.ranges fry io ;
IN: 2dmastermind.grid

TUPLE: grid
    { contents array }
    { width integer }
    { height integer } ;

ERROR: bad-array-length n ;

<PRIVATE

: check-length ( seq w h -- )
    * swap length [ = ] keep swap
    [ drop ] [ bad-array-length ] if ;

: pos>index ( x y grid -- idx )
    width>> * + ;

PRIVATE>

: <grid> ( seq w h -- grid )
    [ check-length ] 3keep
    [ >array ] 2dip
    \ grid boa ;

: grid-of ( value w h -- grid )
    [ * swap '[ _ ] replicate ] 2keep <grid> ;

: bounds ( grid -- w h )
    [ width>> ] [ height>> ] bi ;

: total-cells ( grid -- n )
    bounds * ;

: in-bounds ( x y grid -- ? )
    bounds
    [| x y w h | x 0 >= x w < y 0 >= y h < 4array [ ] all? ] call ;

: grid-at ( x y grid -- value/f )
    3dup in-bounds
    [ [ pos>index ] keep contents>> ?nth ] [ 3drop f ] if ;

: grid-put ( value x y grid -- grid )
    3dup in-bounds
    [ clone [ pos>index ] keep [ clone [ set-nth ] keep ] change-contents ] [ 3nip ] if ;

: grid-modify ( quot: ( z -- z ) x y grid -- grid )
    [ grid-at swap call ] [ grid-put ] 3bi ; inline

: positions ( grid -- seq )
    bounds [ [0,b) ] bi@ cartesian-product concat ;

: show-grid ( grid -- str )
    dup height>> [0,b)
    [
        swap dup width>> [0,b)
        [
            -rot [ grid-at CHAR: 0 + ] 2keep rot
        ] "" map-as nipd
    ] map "\n" join nip ;

: print-grid ( grid -- )
    show-grid print ;

: read-grid ( w h -- grid )
    dup [0,b) [ drop readln ] map concat [ CHAR: 0 - ] { } map-as -rot <grid> ;
