
: cr 13 emit ;

: warn-missing ( string -- )
s" ** No such word: " type type cr
crash-only-during-startup
;
