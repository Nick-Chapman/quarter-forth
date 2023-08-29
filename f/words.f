
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
