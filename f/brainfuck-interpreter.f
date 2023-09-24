.." Loading bf" cr

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
dup [char] , = if drop key over c! crash else
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

hide forward
hide backward
hide run-bf-given-pc-and-mem-pointer
