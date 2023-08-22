
commit
strict find

here-pointer as here
latest (expose/rename dictionary)
immediate^
immediate (set immediate on latest)

if (forth) -- makeit work

comments

----------------------------------------------------------------------

immediate
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
