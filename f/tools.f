.." Loading tools.f" cr

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
  3 + br dis
then
  dup c@ ( a c )
  dup is-ret if ( a c )
    drop drop
    [char] ; emit
    exit
  then
    .h ( a )
    1 + br dis
;

: x-see ( xt -- )
." : "
dup xt->name type
."    "
dis
;

: see
word find x-see ; immediate


( Show stack non destructively )

: .s-continue
2 -
dup 2 - sp > if ( the 2 is for the extra item while processing )
dup @ .
br .s-continue
then
drop
;

: .s
sp0 .s-continue
;


( List available words )

: another-entry? ( xt1 -- bool )
3 - @
;

: next-entry ( xt1 -- xt2 )
3 - @ 3 +
;

: words-continue ( xt -- )
dup xt->name type space
dup another-entry? if
next-entry br words-continue
then
;

: words
latest-entry words-continue cr
;


( Too much output! -- TODO: keyboard controlled pagination )

: see-all-continue
dup x-see cr
dup another-entry? if
next-entry br see-all-continue
then
;

: see-all   latest-entry see-all-continue ;
