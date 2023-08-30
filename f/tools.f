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
