
USING: 2dmastermind.grid 2dmastermind.opponent combinators colors.constants ui
ui.gadgets ui.render accessors math math.functions
math.ranges math.constants math.vectors opengl
opengl.gl sequences kernel arrays locals
namespaces ;
IN: 2dmastermind.ui

<PRIVATE

: push-pair ( pair -- x y )
    [ first ] [ second ] bi ;

PRIVATE>

TUPLE: small-grid-gadget < gadget
    { grid grid } ;

: to-color ( n -- color )
    {
        { 0 [ COLOR: white ] }
        { 1 [ COLOR: red ] }
        { 2 [ COLOR: green ] }
        { 3 [ COLOR: blue ] }
        { 4 [ COLOR: yellow ] }
        { 5 [ COLOR: black ] }
    } case ;

CONSTANT: small-cell-size 16

CONSTANT: circle-steps 32

: unit-vector ( rads -- v )
    [ cos ] [ sin ] bi 2array ;

:: draw-circle ( point radius -- )
    GL_TRIANGLE_FAN glBegin
    circle-steps [0,b]
    point push-pair glVertex2f
    [
        circle-steps / 2 pi * * unit-vector radius v*n point v+
        push-pair glVertex2f
    ] each
    glEnd ;

M: small-grid-gadget pref-dim*
    grid>> [ width>> small-cell-size * ] [ height>> small-cell-size * ] bi 2array ;

M: small-grid-gadget draw-gadget*
    grid>> dup positions
    [
        [ push-pair pick grid-at to-color gl-color ] keep
        { 0.5 0.5 } v+ small-cell-size v*n origin get v+
        small-cell-size 2 /
        draw-circle
    ] each drop ;

: <small-grid-gadget> ( grid -- gadget )
    \ small-grid-gadget new swap >>grid ;

: show-ui ( -- )
    6 4 4 generate-grid <small-grid-gadget> "Test Window" open-window ;
