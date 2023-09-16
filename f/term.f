.." term" cr

( x86 BIOS terminal control )

: set-block-cursor  7 set-cursor-shape ;
: set-underline-cursor  [ 6 256 * 7 + ] literal set-cursor-shape ;
: hide-cursor [ 7 256 * 6 + ] literal set-cursor-shape ;

: at-xy ( x y -- ) 256 * swap + set-cursor-position ;

: xy-read-char ( x y -- char )
at-xy read-char-col drop
;

: xy-read-col ( x y -- col )
at-xy read-char-col nip
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
