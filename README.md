
# 2dmastermind

Another small concatative project.

This is a variant of
[Mastermind](https://en.wikipedia.org/wiki/Mastermind_(board_game))
that I... think I came up with. At least, I haven't seen this
particular 2D variant of Mastermind anywhere else. In regular
Mastermind, you have a row of four pegs, and when you guess, you're
told two things: (1) The number of pegs in the correct place and (2)
the number of pegs of the correct color in the wrong place. Here, you
have a 4x4 grid of pegs. When you place a guess, you're given three
pieces of feedback.

1. The number of pegs in the correct place, just like in regular
   Mastermind.
2. The number of pegs in the wrong place but whose row or column is
   correct. You are not told whether it is the row or the column which
   is correct.
3. The number of pegs of the correct color but which are not in the
   correct row or column.

Note that this calculation is somewhat nontrivial. If you look in
`2dmastermind.matching`, you can see the backtracking algorithm used
to calculate (2) above. Basically, if there are multiple valid ways to
"place" the pegs in the rows and columns given, the score indicated
will always be the maximum of these.

## Entrypoints

The main entrypoints to the application are in the `2dmastermind` vocabulary.

* `play-game-cli` runs a command-line version of the game. The six
  "colors" are the numbers from 0 to 5. Input is taken as four lines
  of four digits each from stdin.
* `play-game-ui` runs a windowed version of the game. Change the guess
  by clicking on the pegs, then hit "Make Guess" to make the guess.
  Previous guesses are shown in the panel to the right.

In either case, if you're just messing with the script and not playing
for real, you can enable "cheater" mode by setting the dynamic
variable `cheater-mode` (defined in `2dmastermind.cheater`) to a
truthy value. In this mode, the correct answer will be printed as soon
as it's generated. It's useful for testing and the like. Even in UI
mode, the printed grid will use numbers. The number-to-color
correspondence is defined at the top of `2dmastermind.ui`.
