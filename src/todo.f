
\ comment
( comments )

----------------------------------------------------------------------

parse-word
find-word

: create    parse-word ,dictionary-header ;
: '         parse-word lookup-word ;

literal (need immediate)

, (as non prim)
constant (as non prim)
if/then (as non prim)

number?

state
[
]

colon compiler in forth

[']
