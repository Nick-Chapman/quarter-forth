( Start the Forth Interpreter which was defined in quarter.q )
[

( Set the immediate bit on some words defined in quarter )

' [ immediate^
' ( immediate^

: immediate
latest immediate^ ;

: here  here-pointer @ ;

: literal ( comp: x -- ) ( run: -- x ) ( repeats ":#" in quarter )
[ ' lit ] lit [ , ] compile, , ; immediate


: [compile] ( "name" -- )
[ ' ' compile, ' compile, compile, ] ; immediate

: ['] ( comp: "name" ) ( run: -- xt )
' [compile] literal ; immediate


( compile is like postpone, but only for non-immediate words )
: compile ( "word" -- )
' ['] lit compile, , ['] compile, compile, ; immediate


: tail ( "name" -- )
' [compile] literal lit [ ' jump , ] compile, ; immediate

( Branch to beginning of current definition )
: recurse ( "word" -- )
( compile lit latest , compile jump ) ( OLD VERSION )
compile branch latest here - ,
; immediate


( We defined "if" and "then" as :i and :t in quarter )
( But we'll define them again here, and also "else" )

: ahead> ( -- a ) here 0 , ;
: <patch ( a -- ) dup here swap - swap ! ;

: if     ['] 0branch compile, ahead> ; immediate
: then   <patch                      ; immediate
: else   ['] branch compile, ahead> swap <patch ; immediate

: begin here ; immediate
: again ['] branch compile, here - , ; immediate

( Word )

: bl [ 1 1 + dup * dup * dup + ] literal ;

: is-white ( c -- flag ) bl swap < 0 1 - xor ; ( <= 32 )

: skip-leading-whitespace
key dup is-white if ( c )
drop recurse ( keep skipping... )
then c, ( collect first char ) ;

: collect-while-not-whitespace
key dup is-white if ( c )
drop 0 c, exit ( add null-terminator )
then c, recurse ( colect & keep collecting... ) ;

: word, ( "name" -- str )
here skip-leading-whitespace collect-while-not-whitespace ;

: word ( "name" -- str )
word, dup here-pointer ! ;

: char ( "c" -- c )
word c@ ;

: [char] ( comp: "name" -- ) ( run: -- c )
char [compile] literal ; immediate


( Nested comments )

( We defined basic comments in quarter.q -- now we define comments which properly nest. )

( TypeChecker not happy when recurse uses branch instead of jump )
: skip-to-close ( level -- )
key dup
[char] ( = if drop 1 + recurse then
[char] ) = if dup 0 = if drop exit then 1 - then
recurse ;

: (
0 skip-to-close ; immediate

( Now(we(have)nested)comments -- hurrah!)

( fi ( fo ) fum )


( Defining words )

: 2 [ 1 1 + ] literal ;
: 3 [ 2 1 + ] literal ;

( TypeChecker not happy with create/does>
: create
word, entry,
compile lit     ( 3 )
here 0 ,        ( 2 )
compile branch  ( 3 )
2 ,             ( 2 )
ret,
here swap !
;

: does> latest [ 3 2 3 + + ] literal + dup r> swap - swap !
;

: variable  create 0 , ;
: constant  create , does> @ ;
)

  ( Versions of constant/variable which avoid create/does> )
  : constant ( x "name" -- ) word, entry, compile lit , ret, ;
  : variable ( "name" -- ) here 0 , constant ;

( Emit a string -- repeats ":p" in quarter )
: type ( a -- )
dup c@ ( a c ) dup if ( a c ) emit ( a ) 1 + recurse
then drop drop ;


( Strings Literals... )

: collect-string
key dup [char] " = if exit
then c, recurse
;

( Compile code for a literal string, leaving address on stack )

: s" ( ..." -- string )
( make a branch slot )          ['] branch compile, ahead>
( note where string starts )    here swap
( collect the string chars )    collect-string drop ( the closing " )
( add a null )                  0 c,
( fill in the branch slot )     <patch
( push string at runtime )      ['] lit compile, ,
; immediate

( Compile code to emit a literal string )

: ." ( ..." )
['] s" execute
['] type compile,
; immediate

( Crash with string message )

: abort" ( ..." )
['] s" execute
['] type compile,
['] cr compile,
['] crash compile,
; immediate

( Print literal string while interpreting )

: .."
here
['] ." execute
ret,
(
dup execute
here-pointer ! ( TypeChecker not happy )
)
execute
;

( Now we can print a banner for this file )
.." forth.f" cr

: space     bl emit ;
: rot       >r swap r> swap ;
: -rot      swap >r swap r> ;

( hide )

: x-hide ( xt|0 -- )
dup if hidden^ exit then drop ( dont try to flip bit on a 0-xt )
;

: hide ( "name" -- ) ' x-hide ;

( Standard Forth words )

: allot     here swap + here-pointer ! ; ( appease TypeChecker with swap )

( This is a 16bit Forth; cell size is 2. Chars have size 1 )

: cell    ( -- n )          1 1 + ;     ( cell size )
: cells   ( n -- n )        cell * ;    ( multiply by cell size )
: cell+   ( n -- n )        cell + ;    ( increment by cell size +2 )
: char+   ( n -- n )        1 + ;       ( increment by char size +1 )
: chars   ( n -- n )        ;           ( multiply by char size *1, nop! )

( Output )

: space     [ bl ] literal emit ;
: spaces    dup if space 1 - recurse then drop ;

( Bools )

: false     ( -- b )        0 ;
: true      ( -- b )        [ 0 1 - ] literal ;
: or        ( b1 b2 -- b )  if drop true then ;         ( bool disjunction )
: and       ( b1 b2 -- b )  if exit then drop false ;   ( bool conjunction )
: invert    ( b -- b )      true xor ;                  ( bool negation )

( Stack manipulation )

( TypeChecker not happy with branch-dependent stack heights )
(
: ?dup  ( x -- 0 | x x )    dup if dup then ;   ( duplicate x if non-zero )
)
: nip   ( a b -- b )        swap drop ;         ( drop item under stack top. )

: 2dup  over over ;
: 2drop drop drop ;

( Numbers )

: >         swap < ;
: <=        > invert ;
: >=        < invert ;

: 0<      ( n -- flag )     0 < ;                       ( n is less than zero )
: 0=      ( n -- flag )     0 = ;                       ( n is zero )
: 1+      ( n1 -- n2 )      1 + ;                       ( increment )
: 1-      ( n1 -- n2 )      1 - ;                       ( decrement )

: negate  ( n1 -- n2 )      0 swap - ;                  ( arithmetic negation )
: abs     ( n -- u )        dup 0< if negate then ;     ( absolute value )

: min       over over > if swap then drop ;
: max       over over < if swap then drop ;

: mod ( n n -- n ) /mod drop ;

: /  ( a b -- a ) /mod nip ;

( Misc )

: +! ( n a ) swap over @ + swap ! ;

( Make the numbers we need )

1 1 +
constant 2

2 1 + dup * 1 +
constant 10

2 dup * dup *
constant 16

16 dup *
constant 256

( Non-blocking key check )

: akey?   key? 256 mod ;
: ekey?   key? 256 / ;


( Loops -- do..i..loop )

: do
compile >r
compile >r
here
; immediate

: i
compile r>
compile r>
compile dup
compile >r
compile swap
compile >r
; immediate

: loop
compile r>
compile r>
compile 1
compile +
compile 2dup
compile >r
compile >r
compile <
compile 0branch
here - ,
compile r>
compile r>
compile 2drop
; immediate

: erase ( a n -- )
dup 0= if 2drop exit then over 0 swap c! swap 1+ swap 1- recurse ;

( Support for numbers... )

( Behaviour of . and number? is modal  )

variable hex-mode

: hex       true  hex-mode ! ;
: decimal   false hex-mode ! ;

( Parse an unsigned hex or decimal number )

: decimal-digit? ( c -- flag ) dup [char] 0 >= swap [char] 9 <= and ;

: extended-digit? ( c -- flag ) dup [char] a >= swap [char] f <= and ;

: hex-digit? ( c -- flag )
dup decimal-digit? swap extended-digit? or ;

: digit? ( c -- flag )
hex-mode @ if hex-digit? else decimal-digit? then ;

: convert-digit
dup extended-digit?
if [char] a - 10 +
else [char] 0 -
then
;

: base ( -- n )
hex-mode @ if 16 else 10 then ;

: number-loop ( acc str -- u flag )
dup c@ dup 0 = if 2drop ( acc ) 1 exit
then ( acc str c ) dup digit? ( acc str c flag )
dup 0 = if 2drop drop 0 exit
then drop convert-digit rot base * + swap char+ ( acc' str' )
recurse
;

: number? ( str -- u flag )
0 swap number-loop ( s u 1 | s acc 0 )
;

( Print as unsigned decimal )

: print-digit ( 0-9 -- )
[char] 0 + emit
;

( expect TypeChecker difficulty here: recursive call at different stack height )
( i.e. polymorphic recursion; Mycroft recursion)
: dot-loop ( u -- )
dup 0= if drop exit ( stop; don't print leading zeros ) then
10 /mod ( u%10 u/10 -- ) dot-loop print-digit
;

: .decimal ( n -- ) ( output a value in decimal )
dup 0= if print-digit exit then ( special case for single "0" )
dot-loop
;

: .hex1 ( nibble -- ) ( output nibble as a length-1 hex string )
dup 10 < if print-digit exit then 10 - [char] a + emit ;

: .hex2 ( byte -- ) ( output byte as a length-2 hex string )
16 /mod .hex1 .hex1 ;

: .hex4 ( n -- ) ( output 16-bit cell-value as a length-4 hex string )
256 /mod .hex2 .hex2 ;

: .hex ( n -- ) ( output a value in hex )
.hex4 ;

: . ( u -- ) ( output value in hex/decimal, with trailing space )
hex-mode @ if .hex else .decimal then space ;

: ? ( addr -- ) @ . ;


( String equality -- repeats ":q" in quarter )

: s= ( a1 a2 -- flag )
over over c@ swap c@ over ( a1 a2 c2 c1 c2 ) = if
[ 0 ] literal = if drop drop [ 0 1 - ] literal exit then
1 + swap 1 + recurse
then drop drop drop [ 0 ] literal ;

( Find )

: find-loop ( s x -- x )
dup if ( s x )
dup hidden? if xt->next recurse then
over over ( s x s x ) xt->name ( s x s s2 ) s= if ( s x ) swap drop exit
then xt->next recurse
then ( s xt ) drop drop 0 ( xt might not be 0 in case word is hidden ) ;

: find ( string -- xt|0 ) latest find-loop ;
: find! ( "name" -- xt|0 )
dup find dup if swap drop exit then
swap type [char] ? emit cr crash-only-during-startup ;

( Tick )

: ' ( "word" -- xt )
word find! ;

( Colon compier: ":" )

: compiling
word
dup s" ;" s= if drop ret, exit then
dup find dup if swap drop dup immediate? if execute else compile, then recurse
then drop dup number? if nip ['] lit compile, , recurse
then drop ." ** Colon compiler: '" type ." ' ?" cr crash-only-during-startup recurse
;

: : word, entry, compiling ;

( Interpreter: "[" )

: [
word
dup s" ]" s= if drop exit then
dup find dup if swap drop execute recurse
then drop dup number? if nip recurse
then drop ." ** Interpreter: '" type ." ' ?" cr crash-only-during-startup recurse
; immediate

( And enter! ) [

hide .hex1
hide 10
hide 16
hide 2
hide 256
hide <patch
hide ahead>
hide base
hide collect-string
hide collect-while-not-whitespace
hide compiling
hide convert-digit
hide decimal-digit?
hide digit?
hide dot-loop
hide extended-digit?
hide find-loop
hide hex-digit?
hide hex-mode
hide is-white
hide number-loop
hide print-digit
hide skip-leading-whitespace
hide space


( Expect... )

: x
over = if drop exit then
." Expect failed, got: " . cr crash-only-during-startup
;
