.." Loading tools" cr

( Tools for exploring mem and defs )

: mem ( report bytes available )
himem here -
." Bytes available: "
. cr
;

( Not so useful.
  : memv ( report verbose memory usage info )
  ." Memory (hex)" cr
  here      ." here      = " as-num .hex4 cr
  sp        ." sp        = " as-num .hex4 cr
  sp0       ." sp0       = " as-num .hex4 cr
  sp here - ." Available = " .hex4 cr
  ;
)

( Dump colon definitions )

: is-call call-op-code = ;
: is-ret ret-op-code = ;

( Disassemble code at a given address )

: disassemble ( a -- )
dup c@ is-call if ( a )
  dup 1 + @call xt->name ( a name )
  type space ( a )
  3 + recurse
then
  dup c@ ( a c )
  dup is-ret if ( a c )
    drop drop
    [char] ; emit
    exit
  then
    .hex2
    ( a ) space
    1 + recurse
;

: x-see ( xt -- )
." : " dup xt->name type ."    "
dup disassemble
immediate? if ."  immediate" then
cr
;

: see ( "name" -- )
word find! dup if x-see then ;

( Show stack non destructively )

: .s-continue
2 -
dup 2 - sp > if ( the 2 is for the extra item while processing )
dup @ .
recurse
then
drop
;

: .s
sp0 .s-continue
;

: depth ( -- n )           ( depth of param stack )
sp sp0 swap - /2
;

: rdepth ( -- n )          ( depth of return stack )
rsp rsp0 swap - /2
;

: .?stack
depth if
." stack is not empty: < " .s [char] > emit cr
then
;

( "words": Print available words -- oldest first -- linear stack usage! )

: show-if-not-hidden ( xt -- )
dup hidden? if drop exit then xt->name type space
;

(
  : rev-words-continue ( xtEarlier xt -- xtEarlier xt )
  over over = if exit then
  dup -rot xt->next rev-words-continue rot
  dup show-if-not-hidden
  drop
  ;
  : words-since ( xtEarlier -- ) latest rev-words-continue drop drop ;
  : rev-words 0 words-since cr ;
)

( "words": Print available words -- newest first -- avoid linear stack usage )

: words-continue ( xt -- )
dup 0 = if drop cr exit then
dup show-if-not-hidden xt->next recurse
;

: words latest words-continue ;

( Repeated execution )

: times ( xt n -- ) ( call xt, n times )
dup if >r dup >r ( xt )
execute
r> r> ( xt n )
1 - recurse
then drop drop
;


( Pagination )

get-key constant old-key
: raw-key  old-key execute ;

: is-escape  27 = ;

: pag-continue ( xt a -- a' )
over execute
cr ." (press any key; escape to exit)" cr
raw-key is-escape if drop drop exit ( quit when escape key pressed )
then cr recurse ;

( Paginated dump )
: pag ( start-addr xt -- ) swap pag-continue ;


: is-printable? ( c -- bool ) dup 31 > swap 128 < and ;

: emit-printable-or-dot ( c -- )
dup is-printable? if emit exit then
drop [char] . emit ;


: drop-if-not-zero ( 0 -- | -- )
dup if drop then
;

: default-0 ( push a zero on the stack if it empty )
depth drop-if-not-zero
;

( Ascii char dump, paginated on 1k blocks )

screen-width 10 / 8 *
constant dump-width

: dc ( a -- a+1 ) dup c@ emit-printable-or-dot 1 + ;
: dump-line ( a -- a+64 ) dup .hex4 ." : " ['] dc dump-width times cr ;
: dump-page ( a -- a+1K ) ['] dump-line 16 times ;
: dump ( start-addr -- ) default-0 ['] dump-page pag ;

( xxd-style dump : hex-bytes + ascii to the side, paginated at 256 bytes )

dump-width 4 /
constant xxd-width

: emit-byte ( c -- ) .hex2 space ;
: db ( a -- a+1 ) dup c@ emit-byte 1 + ;
: xxd-line ( a -- a+16 )
dup .hex4 ." : " dup ['] db xxd-width times space drop ['] dc xxd-width times cr ;
: xxd-page ( a -- a+1K ) ['] xxd-line 16 times ;
: xxd ( start-addr -- ) default-0 ['] xxd-page pag ;

( See all defs, paginated in batches of 10 )

: see1 ( xt -- xt' )
dup if
dup x-see cr
xt->next
then
;

: see10 ( xt -- xt' ) ['] see1 10 times ;
: see-all
latest ['] see10 pag ( TODO: paginate )
;

hide .s-continue
hide db
hide dc
hide default-0
hide drop-if-not-zero
hide dump-line
hide dump-page
hide dump-width
hide emit-byte
hide emit-printable-or-dot
hide is-call
hide is-escape
hide is-printable?
hide is-ret
hide old-key
hide pag
hide pag-continue
hide raw-key
hide see1
hide see10
hide show-if-not-hidden
hide words-continue
hide xxd-line
hide xxd-page
hide xxd-width
