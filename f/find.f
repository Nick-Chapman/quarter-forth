
( Define "find" in Forth )

: find-loop ( s x -- x )
dup if ( s x )
dup hidden? if xt->next tail find-loop then
over over ( s x s x ) xt->name ( s x s s2 ) s= if ( s x ) nip exit
then xt->next tail find-loop
then ( s xt ) drop drop 0 ( xt might not be 0 in case word is hidden )
;

: find ( string -- xt|0 )
latest find-loop
;
