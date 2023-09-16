.." Loading snake" cr

( Make a snake game... )

: block ( x y -- ) bl xy-emit ;
: block-right ( row col -- row col ) 2dup block swap 1+ swap ;
: block-down ( row col -- row col ) 2dup block 1+ ;

: border
red bg !
1 1 ['] block-right 78 times 2drop
1 2 ['] block-down 21 times 2drop
78 2 ['] block-down 21 times 2drop
1 23 ['] block-right 78 times 2drop
black bg !
;

( x/y pos of segment n )

: max-len 100 ;

here max-len 1 + cells allot constant xta
here max-len 1 + cells allot constant yta

: xpos ( n -- ) cells xta + ;
: ypos ( n -- ) cells yta + ;

variable direction
variable going-vertical
variable escaped
variable slowness ( 1.. )

variable len ( tail length -- full snake is 1 longer)

( These direction words change the position of segment 0, the snake head )

: -1   0 1 - ;

: left    0 xpos @ -1 + 0 xpos ! ;
: right   0 xpos @  1 + 0 xpos ! ;
: up      0 ypos @ -1 + 0 ypos ! ;
: down    0 ypos @  1 + 0 ypos ! ;
: nop ;

: set-start-state
25 0 xpos !
10 0 ypos !
['] right direction !
false going-vertical !
false escaped !
1 slowness !
0 len !
;

: move-head   direction @ execute ;
: set-dir ( xpos -- ) direction ! ;

: isH going-vertical @ 0= ;
: isV going-vertical @ ;
: setH false going-vertical ! ;
: setV true going-vertical ! ;

: shift-x ( n -- ) dup 1 - xpos @ swap xpos ! ;
: shift-y ( n -- ) dup 1 - ypos @ swap ypos ! ;
: shift-xy dup shift-x shift-y ;

: head-to-tail-loop ( n -- n' )
dup 0= if exit then
dup shift-xy 1 - recurse ;

: head-to-tail   len @ head-to-tail-loop ;

: clear-tail  len @ dup xpos @ swap ypos @ at-xy space ;

( Until I have food, lets increase the length every so many ticks )

: maybe-grow ( n -- )
10 mod 0 = if 1 len +!
67 0 at-xy ." Length = " len @ .
len @ shift-xy
then ;

: tick ( -- ) time dup maybe-grow 2drop ;
: tick2   tick tick ;

: pause1  going-vertical @ if tick then tick ; ( half speed when going vertical )
: do-pause   ['] pause1 slowness @ times ;

: speed-up slowness @ 1 - dup if slowness ! then ;

: is-escape  27 = ;
: is-return  13 = ;

: control ( ascii scan-code -- )
dup 72 = if isH if ['] up    set-dir setV then then
dup 80 = if isH if ['] down  set-dir setV then then
dup 75 = if isV if ['] left  set-dir setH then then
dup 77 = if isV if ['] right set-dir setH then then
over is-escape if true escaped ! then
over is-return if speed-up then
2drop
;

char @ constant snake-char

: draw-head   yellow fg ! 0 xpos @ 0 ypos @ snake-char xy-emit ;

: collide? ( -- flag )
0 xpos @ 0 ypos @ xy-read-char-col
16 / red = if drop true exit then
snake-char =
;

: app-loop
do-pause
key? 256 /mod control
escaped @ if cls 0 0 at-xy ." Escape!" cr false exit then
clear-tail head-to-tail move-head
collide? if 1 0 at-xy ." CRASH" true exit then
draw-head
len @ max-len = if 1 0 at-xy ." YOU WIN            " KEY KEY true exit then
recurse
;

: snake
cls hide-cursor border
1 0 at-xy ." Target length: " max-len .
set-start-state
draw-head
app-loop ( again? )
if
."  (press any key to try again)" cr KEY
snake
then
set-underline-cursor
;
