.." Loading snake" cr

( x86 BIOS terminal control )

: set-block-cursor  7 set-cursor-shape ;
: set-underline-cursor  [ 6 256 * 7 + ] literal set-cursor-shape ;
: hide-cursor [ 32 256 * ] literal set-cursor-shape ;

: at-xy ( x y -- ) 256 * swap + set-cursor-position ;

: xy-read-char-col ( x y -- char col )
at-xy read-char-col
;

: xy-read-char ( x y -- char )
xy-read-char-col drop
;

: xy-read-col ( x y -- col )
xy-read-char-col nip
;

variable fg
variable bg

: colour 16 bg @ * fg @ + ;

: xy-emit ( x y char -- ) ( using fg; dont move cursor )
-rot at-xy colour write-char-col
;

 0 constant black
 1 constant blue
 2 constant green
 3 constant cyan
 4 constant red
 5 constant magenta
 6 constant brown
 7 constant light-grey
 8 constant dark-grey
 9 constant light-blue
10 constant light-green
11 constant light-cyan
12 constant light-red
13 constant light-magenta
14 constant yellow
15 constant white

white fg !
black bg !

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

hide -1
hide app-loop
hide at-xy
hide black
hide block
hide block-down
hide block-right
hide blue
hide border
hide brown
hide clear-tail
hide collide?
hide colour
hide control
hide cyan
hide dark-grey
hide do-pause
hide down
hide draw-head
hide green
hide head-to-tail
hide head-to-tail-loop
hide hide-cursor
hide is-escape
hide is-return
hide isH
hide isV
hide left
hide light-blue
hide light-cyan
hide light-green
hide light-grey
hide light-magenta
hide light-red
hide magenta
hide maybe-grow
hide nop
hide pause1
hide red
hide right
hide set-block-cursor
hide set-dir
hide set-start-state
hide set-underline-cursor
hide setH
hide setV
hide shift-x
hide shift-xy
hide shift-y
hide snake-char
hide speed-up
hide tick
hide tick2
hide up
hide white
hide xpos
hide xta
hide xy-emit
hide xy-read-char
hide xy-read-char-col
hide xy-read-col
hide yellow
hide ypos
hide yta
