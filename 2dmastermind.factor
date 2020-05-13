
USING: io 2dmastermind.cli 2dmastermind.ui ui ;
IN: 2dmastermind

: play-game-cli ( -- )
    play-game-default ;

: play-game-ui ( -- )
    [ show-ui ] with-ui ;
