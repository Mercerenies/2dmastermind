
USING: 2dmastermind.grid 2dmastermind.matching random kernel math.ranges
math sequences accessors fry arrays ;
IN: 2dmastermind.opponent

TUPLE: game-state
    { correct-grid grid }
    { guesses array } ;

TUPLE: guess
    { grid grid }
    { result matches } ;

: <game-state> ( grid -- state )
    { } \ game-state boa ;

: <guess> ( grid result -- guess )
    \ guess boa ;

: append-guess ( state guess -- state )
    [ clone ] dip '[ _ suffix ] change-guesses ;

: generate-grid ( n w h -- grid )
    [ * [0,b) [ drop dup [0,b) random ] map ] 2keep <grid> nip ;

: is-guess-correct ( grid matches -- ? )
    [ total-cells ] [ exact>> ] bi* = ;

: make-guess ( state grid -- state matches )
    [ over correct-grid>> find-matches ] keep
    swap [ <guess> append-guess ] keep ;
