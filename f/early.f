.." Loading early.f" cr

: warn-missing ( string -- )
." ** No such word: " type cr
crash-only-during-startup
;
