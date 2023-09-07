.." Loading tools.f ( " latest


: false     ( -- b )        0 ;
: true      ( -- b )        65535 ;
: invert    ( b -- b )      if false exit then true ;   ( bool negation )
: rot   >r swap r> swap ;
: -rot  swap >r swap r> ;

: bl        32 ;
: space     bl emit ;
: >         swap < ;


( Expect... )

: x
over = if drop exit then
." Expect failed, got: " . cr crash ( -only-during-startup )
;


( Tools for exploring mem and defs )

: mem ( report bytes available )
sp here -
." Bytes available: "
. cr
;

( Dump colon definitions )

: e8 14 16 * 8 + ;
: c3 12 16 * 3 + ;
: is-call e8 = ;
: is-ret c3 = ;

: @rel->abs
dup @ + 2 +
;

: dis ( a -- )
dup c@ is-call if ( a )
  dup 1 + @rel->abs xt->name ( a name )
  type space ( a )
  3 + tail dis
then
  dup c@ ( a c )
  dup is-ret if ( a c )
    drop drop
    [char] ; emit
    exit
  then
    .h ( a ) space
    1 + tail dis
;

: x-see ( xt -- )
." : "
dup xt->name type
."    "
dis
;

: see
word find x-see cr ; immediate


( Show stack non destructively )

: .s-continue
2 -
dup 2 - sp > if ( the 2 is for the extra item while processing )
dup @ .
tail .s-continue
then
drop
;

: .s
sp0 .s-continue
;

: depth ( -- n )           ( depth of param stack )
sp sp0 swap - /2
;

: .?stack
depth if
." stack is not empty: < " .s [char] > emit cr
then
;


: show-if-not-hidden ( xt -- )
dup hidden? if drop exit then xt->name type space
;

( Print available words -- newest first )
: words-continue ( xtEarlier xt -- xtEarlier xt )
over over = if exit then
dup show-if-not-hidden
xt->next words-continue
;

( Print available words -- oldest first )
: words-continue ( xtEarlier xt -- xtEarlier xt )
over over = if exit then
dup -rot xt->next words-continue rot
dup show-if-not-hidden
drop
;

( Order the above two defs to pick printing order for "words". later def wins )

: words-between ( xtEarlier xtLater )
words-continue drop drop
;

: words-since ( xtEarlier -- )
latest words-between
;

: words
0 words-since cr
;


( Repeated execution )

: times ( xt n -- ) ( call xt, n times )
dup if >r dup >r ( xt )
execute
r> r> ( xt n )
1 - tail times
then drop drop
;


( Pagination )

: is-escape  27 = ;

: pag-continue ( xt a -- a' )
over execute
cr ." (waiting...)" cr
key is-escape if drop drop exit ( quit when escape key pressed )
then cr tail pag-continue ;

( Paginated dump )
: pag ( start-addr xt -- ) swap pag-continue ;


: @.hh ( a -- ) dup c@ .h 1 - c@ .h ;
: .hh ( a ) sp 1 + @.hh drop ; ( THIS IS SUCH A HACK )

: and if exit then drop 0 ;
: is-printable? ( c -- bool ) dup 31 > swap 128 < and ;

: emit-printable-or-dot ( c -- )
dup is-printable? if emit exit then
drop [char] . emit ;

( Ascii char dump, paginated on 1k blocks )

: dc ( a -- a+1 ) dup c@ emit-printable-or-dot 1 + ;
: dc64 ( a -- a+64 ) dup .hh ." : " ['] dc 64 times cr ;
: dc-oneK ( a -- a+1K ) ['] dc64 16 times ;
: dump ( start-addr -- ) ['] dc-oneK pag ;

( xxd-style dump : hex-bytes + ascii to the side, paginated at 256 bytes )

: emit-byte ( c -- ) .h space ;
: db ( a -- a+1 ) dup c@ emit-byte 1 + ;
: xxd-line ( a -- a+16 )
dup .hh ." : " dup ['] db 16 times space drop ['] dc 16 times cr ;
: xxd-page ( a -- a+1K ) ['] xxd-line 16 times ;
: xxd ( start-addr -- ) ['] xxd-page pag ;


( See all defs, paginated in batches of 10 )

: see1 ( xt -- xt' )
dup if
dup x-see cr
xt->next
then
;

: see10 ( xt -- xt' ) ['] see1 10 times ;
: see-all
latest ['] see10 pag
;

: x-hide ( xt|0 -- )
dup if hidden^ exit then ( dont try to flip bit on a 0-xt )
;

: hide ( "name" -- )
word find! x-hide
;


hide -rot
hide .s-continue
hide >
hide @.hh
hide @rel->abs
hide and
hide bl
hide c3
hide db
hide dc
hide dc-oneK
hide dc64
hide depth
hide dis
hide e8
hide emit-byte
hide emit-printable-or-dot
hide false
hide invert
hide is-call
hide is-escape
hide is-printable?
hide is-ret
hide pag
hide pag-continue
hide rot
hide see-all
hide see1
hide see10
hide show-if-not-hidden
hide space
hide times
hide true
hide words-between
hide words-continue
hide words-continue
hide x-hide
hide x-see
hide xxd-line
hide xxd-page
words-since char ) emit cr
