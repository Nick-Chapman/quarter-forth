.." Loading dict ( " latest

: space     bl emit ;
: rot       >r swap r> swap ;
: -rot      swap >r swap r> ;

( hide )

: x-hide ( xt|0 -- )
dup if hidden^ exit then ( dont try to flip bit on a 0-xt )
;

: hide ( "name" -- ) word find! x-hide ;
hide x-hide

( hide some internals from boot.f and string.f )

hide '?'
hide ')'
hide string[
hide string;
hide ]]
hide almost:
hide compile-or-execute
hide 1compiling
hide start]
hide [']
hide collect-string


( words )

: show-if-not-hidden ( xt -- )
dup hidden? if drop exit then xt->name type space
;

( Print available words -- newest first )
: words-continue ( xtEarlier xt -- xtEarlier xt )
over over = if exit then
dup show-if-not-hidden
xt->next words-continue
;
hide words-continue

( Print available words -- oldest first )
: words-continue ( xtEarlier xt -- xtEarlier xt )
over over = if exit then
dup -rot xt->next words-continue rot
dup show-if-not-hidden
drop
;
hide show-if-not-hidden

( Order the above two defs to pick printing order for "words". later def wins )

: words-since ( xtEarlier -- ) latest words-continue drop drop ;
: words 0 words-since cr ;

( debug: See the ASM builtin words; needs "latest" dropped on stack when boot starts )
( drop cr cr 0 swap words-continue drop drop cr cr crash )

hide space
hide rot
hide -rot
hide words-continue
words-since char ) emit cr
