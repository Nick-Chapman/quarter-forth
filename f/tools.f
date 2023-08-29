
( Tools for exploring mem and defs )

: mem ( report bytes available )
sp here -
s" Bytes available: " type
. cr
;

( Dump colon definitions )

: e8 14 16 * 8 + ;
: is-call e8 = ;

: @rel->abs
dup @ + 2 +
;

: dis ( a -- )
dup c@ is-call invert if

dup ( a a )
c@ .h
1 + br dis

then dup ( a a )
1 + @rel->abs xt->name ( a name )
dup ( a name name )
type space ( a name )
s" exit" s= invert if ( NOT RIGHT - may stop too early )
3 + br dis

then
cr
;

: x-see ( xt -- )
s" : " type
dup xt->name type
s"    " type
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
sp0 .s-continue cr
;
