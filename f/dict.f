.." Loading dict ( " latest

: space     bl emit ;
: rot       >r swap r> swap ;
: -rot      swap >r swap r> ;

( "words": Print available words -- oldest first )

: show-if-not-hidden ( xt -- )
dup hidden? if drop exit then xt->name type space
;

: words-continue ( xtEarlier xt -- xtEarlier xt )
over over = if exit then
dup -rot xt->next words-continue rot
dup show-if-not-hidden
drop
;

: words-since ( xtEarlier -- ) latest words-continue drop drop ;
: words 0 words-since cr ;

( hide )

: x-hide ( xt|0 -- )
dup if hidden^ exit then ( dont try to flip bit on a 0-xt )
;

: hide ( "name" -- ) word find! x-hide ;
hide x-hide

( hide some words defined by kernel, boot.f and string.f and this file )

hide call:
hide entry:

hide {{
hide compile-or-execute
hide compiling

hide ~
hide collect-string

hide -rot
hide rot
hide show-if-not-hidden
hide space
hide words-continue
words-since char ) emit cr

