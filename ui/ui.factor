
USING: 2dmastermind.grid 2dmastermind.opponent 2dmastermind.matching combinators
colors.constants ui ui.gadgets ui.gadgets.packs ui.gadgets.labels
ui.gadgets.buttons ui.gadgets.viewports ui.gadgets.scrollers ui.render
ui.gestures accessors math math.functions math.ranges math.constants
math.vectors math.order opengl opengl.gl sequences kernel arrays
locals fry namespaces hashtables models formatting ;
QUALIFIED-WITH: ui.gadgets.grids grids
IN: 2dmastermind.ui

<PRIVATE

: push-pair ( pair -- x y )
    [ first ] [ second ] bi ;

PRIVATE>

TUPLE: grid-gadget < gadget
    { grid grid } ;

TUPLE: small-grid-gadget < grid-gadget ;

TUPLE: interactive-grid-gadget < grid-gadget
    { maximum integer } ;

TUPLE: history-gadget < pack ;

TUPLE: main-frame-gadget < pack
    { correct-grid grid }
    { history history-gadget }
    { interactive-grid interactive-grid-gadget } ;

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

CONSTANT: large-cell-size 64

CONSTANT: circle-steps 32

: unit-vector ( rads -- v )
    [ cos ] [ sin ] bi 2array ;

: min-coord ( v -- x )
    [ first ] [ second ] bi min ;

:: draw-circle ( point radius -- )
    GL_TRIANGLE_FAN glBegin
    circle-steps [0,b]
    point push-pair glVertex2f
    [
        circle-steps / 2 pi * * unit-vector radius v*n point v+
        push-pair glVertex2f
    ] each
    glEnd ;

: next-color ( n max -- n )
    [ 1 + ] dip mod ;

: gadget-to-cell-coord ( gadget -- pair )
    [ grid>> ] [ hand-rel push-pair ] [ dim>> push-pair ] tri
    swapd [ / ] 2bi@
    pick bounds swapd [ * floor ] 2bi@ 2array nip ;

: on-click ( gadget -- )
    {
        [ maximum>> ]
        [ gadget-to-cell-coord ]
        [ -rot '[ [ [ _ next-color ] _ push-pair ] dip grid-modify ] change-grid ]
        [ relayout-1 ]
    } cleave drop ;

M: small-grid-gadget pref-dim*
    grid>> [ width>> small-cell-size * ] [ height>> small-cell-size * ] bi 2array ;

M: interactive-grid-gadget pref-dim*
    grid>> [ width>> large-cell-size * ] [ height>> large-cell-size * ] bi 2array ;

M: grid-gadget draw-gadget*
    [let [ grid>> ] [ dim>> ] bi :> ( grid dim )
     dim grid bounds 2array v/ :> circle-dim
     grid positions
     [
         [ push-pair grid grid-at to-color gl-color ] keep
         { 0.5 0.5 } v+ circle-dim v*
         circle-dim min-coord 2 /
         draw-circle
     ] each
    ] ;

M: history-gadget model-changed
    relayout-1 drop ;

\ interactive-grid-gadget H{
    { T{ button-down f f 1 } [ on-click ] }
} set-gestures

: <small-grid-gadget> ( grid -- gadget )
    \ small-grid-gadget new swap >>grid ;

: <interactive-grid-gadget> ( grid max -- gadget )
    \ interactive-grid-gadget new swap >>maximum swap >>grid ;

: <history-gadget> ( -- gadget )
    \ history-gadget new vertical >>orientation
    { } <model> [ add-connection ] [ >>model ] 2bi ;

: <main-frame-gadget> ( -- gadget )
    \ main-frame-gadget new horizontal >>orientation ;

: <matches-label> ( matches -- gadget )
    [ exact>> ] [ row-column>> ] [ color>> ] tri
    "Exact: %d\nRow / Column: %d\nColor: %d\n" sprintf <label> ;

: <single-guess-gadget> ( guess -- gadget )
    [ <shelf> ] dip
    [ grid>> <small-grid-gadget> add-gadget ]
    [ result>> <matches-label> add-gadget ]
    bi ;

: modify-control-value ( ..a control quot: ( ..a x -- ..b x ) -- ..b )
    swap [ control-value swap call ] [ set-control-value ] bi ; inline

: get-history ( gadget -- arr )
    control-value ;

: add-to-history ( gadget guess -- )
    {
        [ swap [ swap suffix ] modify-control-value ]
        [ <single-guess-gadget> add-gadget drop ]
        [ drop relayout-1 ]
    } 2cleave ;

: get-main-frame ( gadget -- frame )
    [ main-frame-gadget? ] find-parent ;

: acquire-state ( frame -- state )
    [ correct-grid>> <game-state> ] [ history>> get-history >>guesses ] bi ;

: acquire-guess ( frame -- grid )
    interactive-grid>> grid>> ;

: replace-state ( state frame -- )
    [ [ correct-grid>> ] dip correct-grid<< ] [ [ guesses>> last ] [ history>> ] bi* swap add-to-history ] 2bi ;

: make-guess-on-click ( button -- )
    get-main-frame [ acquire-state ] [ acquire-guess ] [ [ make-guess drop ] dip replace-state ] tri ;

: make-main-panel ( grid max -- gadget )
    {
        [ <interactive-grid-gadget> ]
        [ 2drop "Make Guess" <label> [ make-guess-on-click ] <border-button> ]
    } 2cleave 2array
    <pile> swap add-gadgets ;

: make-history-panel ( -- gadget )
    <history-gadget> <scroller> ;

:: attach-ui ( correct-grid panel history -- frame )
    <main-frame-gadget> :> frame
    frame panel history 2array 1array grids:<grid> add-gadget
    0 panel nth-gadget >>interactive-grid
    history viewport>> 0 swap nth-gadget >>history
    correct-grid >>correct-grid ;

: make-ui ( correct-grid grid max -- gadget )
    {
        [ make-main-panel ]
        [ 2drop make-history-panel ]
    } 2cleave
    attach-ui ;

: show-ui ( -- )
    6 4 4 generate-grid 6 4 4 generate-grid 6 make-ui "Test Window" open-window ;
