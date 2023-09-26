.." Loading bf" cr

( Allow the input stream to be redirected )
variable v-key  ' key v-key !
: bf-key v-key @ execute ;

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

: run-bf-given-pc-and-mem-pointer ( pc mp )
over c@
dup 0= if drop 2drop exit then
dup [char] . = if drop dup c@ emit else
dup [char] , = if drop bf-key over c! else
dup [char] > = if drop 1+ else
dup [char] < = if drop 1- else
dup [char] + = if drop dup c@ 1 + 256 mod over c! else
dup [char] - = if drop dup c@ 1 - 256 mod over c! else
dup [char] [ = if drop dup c@ 0= if swap 0 forward swap then else
dup [char] ] = if drop dup c@ if swap 0 backward swap then else
drop
then then then then then then then then
swap 1+ swap
recurse
;

: run-bf ( prog-string -- )
here dup 1024 erase ( get a chunk of free blank memory )
run-bf-given-pc-and-mem-pointer
;

: comma ( mp -- ) bf-key over c! ;
: dot ( mp -- ) dup c@ emit ;
: plus ( mp -- ) dup c@ 1 + 256 mod over c! ;
: minus ( mp -- ) dup c@ 1 - 256 mod over c! ;
: test-mp ( mp -- ) dup c@ ;

: c-comma  [ ' comma ] literal compile, ;
: c-dot  [ ' dot ] literal compile, ;
: c-plus  [ ' plus ] literal compile, ;
: c-minus  [ ' minus ] literal compile, ;
: c-left  [ ' 1- ] literal compile, ;
: c-right  [ ' 1+ ] literal compile, ;

: c-lsq
here swap
['] test-mp compile,
['] 0branch compile,
here 0 ,
-rot ;

: c-rsq
swap ['] branch compile, here - ,
swap dup here swap - swap ! ;

: compile-bf ( s -- )
dup c@ ( s c ) dup 0= if 2drop exit then
dup [char] , = if drop c-comma else
dup [char] . = if drop c-dot else
dup [char] + = if drop c-plus else
dup [char] - = if drop c-minus else
dup [char] < = if drop c-left else
dup [char] > = if drop c-right else
dup [char] [ = if drop c-lsq else
dup [char] ] = if drop c-rsq else
drop
then then then then then then then then
1+ recurse
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
hide c-dot
hide c-left
hide c-lsq
hide c-minus
hide c-plus
hide c-right
hide c-rsq
hide dot
hide forward
hide minus
hide plus
hide run-bf-given-pc-and-mem-pointer
hide test-mp
