
:: immediate latest immediate^ ;

:: qm        [char] ? ;
:: cr        13 emit ;
:: here      here-pointer @ ;
:: allot     here + here-pointer ! ;
:: if        0branch, here 0 ,     ; immediate
:: then      dup here swap - swap ! ; immediate
:: exit      r> drop ;
:: bl        32 ;
:: space     bl emit ;
:: >         swap < ;
:: nip       swap drop ;

:: (         key [char] ) = if exit then tail ( ; immediate

( Now we can write comments! Woo hoo! )

( Alternative comments, useful as they dont nest )
:: {         key [char] } = if exit then tail { ; immediate

( Define "[']" in Forth )

:: ['] ( comp: "name" ) ( run: -- xt )
0word 0find non-immediate-literal
; immediate

( Some strings to compare against )

here char [ , 0 , constant string[
here char ; , 0 , constant string;

:: find-or-crash ( "name" -- xt|0 )
dup 0find dup if nip exit then
drop type qm emit cr crash-only-during-startup
;

:: x-hide ( xt|0 -- )
dup if hidden^ exit then ( dont try to flip bit on a 0-xt )
;

:: hide ( "name" -- )
0word find-or-crash x-hide
;

( Need entry/call because of transient string buffer )

:: entry: 0word entry, ;
:: call: 0word find-or-crash compile, ;

( ----------------------------------------------------------------------
Setup level 0...
---------------------------------------------------------------------- )

( TODO : move implementation/entry of level-0 interpreter to asm )

:: 0interpreter ( word-find-execute-loop )
( [char] 0 emit [char] > emit )
0word dup 0find dup ( string xt|0 ) if
swap drop execute tail 0interpreter
then drop [char] 0 emit type [char] ? emit cr tail 0interpreter
;

char 0 emit cr
0interpreter

hide ::
