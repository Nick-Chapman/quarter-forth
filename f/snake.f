.." snake" cr

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

: x-width 80 ;
: y-width 24 ;

{ : modX  x-width mod ;
: modY  y-width mod ; }

: -1   0 1 - ;
{ : -x [ x-width -1 + ] literal ;
: -y [ y-width -1 + ] literal ; }

variable head-x
variable head-y
variable direction
variable going-vertical
variable escaped

: left    head-x @ -1 + head-x ! ;
: right   head-x @  1 + head-x ! ;
: up      head-y @ -1 + head-y ! ;
: down    head-y @  1 + head-y ! ;
: nop ;

: set-start-state
25 head-x !
10 head-y !
['] right direction !
false going-vertical !
false escaped !
;

: move-head   direction @ execute ;
: set-dir ( xt -- ) direction ! ;

: tick ( -- ) time 2drop ;
: tick2   tick tick ;

: isH going-vertical @ 0= ;
: isV going-vertical @ ;
: setH false going-vertical ! ;
: setV true going-vertical ! ;

: do-pause  going-vertical @ if tick then tick ; ( extra tick when vertical )

: is-escape  27 = ;
: control ( ascii scan-code -- )
over is-escape if true escaped ! then
dup 72 = if isH if ['] up    set-dir setV then then
dup 80 = if isH if ['] down  set-dir setV then then
dup 75 = if isV if ['] left  set-dir setH then then
dup 77 = if isV if ['] right set-dir setH then then
2drop
;

variable tail-1-x
variable tail-1-y

variable tail-2-x
variable tail-2-y

: head-to-tail
tail-1-x @ tail-2-x !
tail-1-y @ tail-2-y !
head-x @ tail-1-x !
head-y @ tail-1-y !
;

: clear-tail  tail-2-x @ tail-2-y @ at-xy space ;

: draw-head   head-x @ head-y @ [char] @ xy-emit ;

: move-snake
clear-tail head-to-tail move-head
;

: init-draw-snake
draw-head
head-to-tail move-head draw-head
head-to-tail move-head draw-head
;

: collide? ( -- flag )
head-x @ head-y @ xy-read-col 16 / red = ;

: return-to-console
0 0 at-xy set-underline-cursor
;

: app-loop
do-pause key? 256 /mod control
escaped @ if 0 0 at-xy ." Escape!" exit then
move-snake
( head-x @ head-y @ xy-read-col 0 0 at-xy .hex )
collide? if 0 0 at-xy ." CRASH!" exit then
draw-head
recurse
;

: go
cls hide-cursor border
set-start-state
yellow fg ! ( for snake )
init-draw-snake
app-loop
KEY drop return-to-console
;
