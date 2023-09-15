
: /   ( a b -- a )
/mod nip ;

: tick ( -- ) time 2drop ;

: time: ( "word" -- ) ( time & print how long a word takes to run )
' time nip >r execute time nip r> -
cr s" Time (1/16s): " type . cr
;
