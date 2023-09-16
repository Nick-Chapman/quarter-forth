
( Make a snake game... )

: set-block-cursor  7 set-cursor-shape ;
: set-underline-cursor  [ 6 256 * 7 + ] literal set-cursor-shape ;
: hide-cursor [ 7 256 * 6 + ] literal set-cursor-shape ;

: at-xy ( x y -- ) 256 * swap + set-cursor-position ;

variable x
variable y

: x-width 80 ;
: y-width 24 ;

: modX  x-width mod ;
: modY  y-width mod ;

: -1   0 1 - ;
: -x [ x-width -1 + ] literal ;
: -y [ y-width -1 + ] literal ;

: left    x @ -x + modX x ! ;
: right   x @  1 + modX x ! ;
: up      y @ -y + modY y ! ;
: down    y @  1 + modY y ! ;
: nop ;

variable direction
: move   direction @ execute ;
: set-dir ( xt -- ) direction ! ;
' right set-dir

: tick ( -- ) time 2drop ;
: tick2   tick tick ;
variable pause  '  tick  pause !
: setH         ['] tick  pause ! ;
: setV         ['] tick2 pause ! ; ( half speed when vertical )
: do-pause  pause @ execute ;


: is-escape  27 = ;

variable escaped

: control ( ascii scan-code -- )
over is-escape if true escaped ! then
dup 72 = if ['] up    set-dir setV then
dup 75 = if ['] left  set-dir setH then
dup 77 = if ['] right set-dir setH then
dup 80 = if ['] down  set-dir setV then
2drop
;

: draw   x @ y @ at-xy [char] @ emit ;
: clear  x @ y @ at-xy space ;

: app-loop
draw do-pause key? 256 /mod control
escaped @ if exit then
clear move recurse
;

: set-start-pos 25 x ! 10 y ! ;
set-start-pos

: star [char] * emit ;
: star-at-down ( row col -- row col ) 2dup at-xy star 1+ ;

: border
1 1 at-xy ['] star 78 times
1 2 ['] star-at-down 21 times 2drop
78 2 ['] star-at-down 21 times 2drop
1 23 at-xy ['] star 78 times
;


: snake
false escaped !
app-loop
0 0 at-xy set-underline-cursor
." Escaped " cr
;

: go
cls
hide-cursor
border
( 0 0 at-xy set-underline-cursor )
snake
;
