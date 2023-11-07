
: banner s" Welcome to Quarter Forth. A 16-bit Forth system running on x86." ;

8 constant backspace-code
80 constant screen-width
: himem sp ;

14 16 * 8 + ( e8 )
constant call-op-code

12 16 * 3 + ( c3 )
constant ret-op-code

: @call
dup @ + 2 + ( @rel->abs )
;
