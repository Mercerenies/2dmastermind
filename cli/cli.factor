
USING: 2dmastermind.grid 2dmastermind.matching 2dmastermind.opponent kernel
accessors formatting io ;
IN: 2dmastermind.cli

: display-matches ( matches -- )
    [ exact>> "Exact: %s\n" printf ]
    [ row-column>> "Row / Column: %s\n" printf ]
    [ color>> "Color: %s\n" printf ]
    tri flush ;

: play-game ( n w h -- )
    generate-grid <game-state>
    [
        dup correct-grid>> bounds read-grid make-guess
        dup display-matches
        [ dup correct-grid>> ] dip is-guess-correct not
    ] loop drop ;

: play-game-default ( -- )
    6 4 4 play-game ;
