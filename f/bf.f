.." Loading bf" cr

( Allow the input stream to be redirected )
variable v-key  ' key v-key !
: bf-key v-key @ execute ;

( Brainfuck Interpreter... )

: forward ( pc n -- pc' )
over c@ [char] ] = if 1- dup 0= if drop exit then then
over c@ [char] [ = if 1+ then
swap 1+ swap recurse
;

: backward ( pc n -- pc' )
over c@ [char] [ = if 1- dup 0= if drop exit then then
over c@ [char] ] = if 1+ then
swap 1- swap recurse
;

: comma ( mp -- ) bf-key over c! ;
: dot ( mp -- ) dup c@ emit ;
: plus ( mp n -- ) swap dup c@ rot + 256 mod over c! ;
: minus ( mp n -- ) swap dup c@ rot - 256 mod over c! ;
: non-zero? ( mp -- ) dup c@ ;

: run-bf-given-pc-and-mem-pointer ( pc mp )
over c@
dup 0= if drop 2drop exit then
dup [char] . = if drop dot else
dup [char] , = if drop comma else
dup [char] > = if drop 1+ else
dup [char] < = if drop 1- else
dup [char] + = if drop 1 plus else
dup [char] - = if drop 1 minus else
dup [char] [ = if drop non-zero? 0= if swap 0 forward swap then else
dup [char] ] = if drop non-zero? if swap 0 backward swap then else
drop
then then then then then then then then
swap 1+ swap
recurse
;

: run-bf ( prog-string -- )
here dup 1024 erase ( get a chunk of free blank memory )
run-bf-given-pc-and-mem-pointer
;

( Brainfuck Compiler... )

: c-lsq
here swap
compile non-zero?
compile 0branch
here 0 ,
-rot ;

: c-rsq
swap compile branch here - ,
swap dup here swap - swap ! ;

: collect-left  ( s n -- s' n' ) over c@ [char] < = if swap 1+ swap 1+ recurse then ;
: collect-right ( s n -- s' n' ) over c@ [char] > = if swap 1+ swap 1+ recurse then ;
: collect-plus  ( s n -- s' n' ) over c@ [char] + = if swap 1+ swap 1+ recurse then ;
: collect-minus ( s n -- s' n' ) over c@ [char] - = if swap 1+ swap 1+ recurse then ;

: c-left  ( s -- s' ) 1 collect-left  compile lit , compile - ;
: c-right ( s -- s' ) 1 collect-right compile lit , compile + ;
: c-plus  ( s -- s' ) 1 collect-plus  compile lit , compile plus ;
: c-minus ( s -- s' ) 1 collect-minus compile lit , compile minus ;

: compile-bf ( s -- )
dup 1+ swap c@ ( s c ) dup 0= if 2drop exit then
dup [char] , = if drop compile comma else
dup [char] . = if drop compile dot else
dup [char] + = if drop c-plus else
dup [char] - = if drop c-minus else
dup [char] < = if drop c-left else
dup [char] > = if drop c-right else
dup [char] [ = if drop c-lsq else
dup [char] ] = if drop c-rsq else
drop
then then then then then then then then
recurse
;

( Compile and run... )

: run-bf-xt ( bf-xt -- )
here 1024 erase           ( space for the memory tape )
here swap execute drop    ( run the compiled program )
;

: fast-run-bf ( str -- )
here swap compile-bf ret, ( compile the program )
dup run-bf-xt
here-pointer !            ( reset to loose the compiled program )
;

variable input-p
: ikey ( -- c ) ( Next the next char from the input string )
input-p @ c@ dup if 1 input-p +! else crash then ;

: irun-bf-xt ( input-str bf-xt -- )
v-key @ -rot                      ( save existing key routine... )
swap input-p !  ['] ikey v-key !  ( read from input-str instead )
here 1024 erase                   ( space for the memory tape )
here swap execute drop            ( run the compiled program )
v-key !                           ( ... restore )
;

: fast-irun-bf ( input-str prog-str -- )
here swap compile-bf ret, ( compile the program )
dup -rot irun-bf-xt
here-pointer !            ( reset to loose the compiled program )
;

hide backward
hide bf-key
hide c-left
hide c-lsq
hide c-minus
hide c-plus
hide c-right
hide c-rsq
hide collect-left
hide collect-minus
hide collect-plus
hide collect-right
hide comma
hide compile-bf
hide dot
hide forward
hide ikey
hide input-p
hide irun-bf-xt
hide minus
hide non-zero?
hide plus
hide run-bf-given-pc-and-mem-pointer
hide run-bf-xt
hide v-key
