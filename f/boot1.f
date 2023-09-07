
char b emit char o dup emit emit char t emit char 1 emit char . emit char f emit cr

( ----------------------------------------------------------------------
Using level 0 to define a level 1 compiler...
---------------------------------------------------------------------- )

(
This compiler supports immediateness
Compiling words until ";" marker
BUt it can't take advantage of immediateness in it's own definition
)

almost: compile-or-execute
dup immediate? [ if ]]
execute exit
[ then ]] compile,
[ ret,


(
NOPE-number? [ if ]] [ tick: lit ]] [ literal ]] compile, , 1compiling exit [ then ]]
)


almost: 1compiling

word
dup
string;

s= [ if ]] drop ret, exit
[ then ]]
dup find dup [ if ]]
swap drop compile-or-execute 1compiling exit
[ then ]] drop

'B' emit type '?' emit cr
crash 1compiling exit
[ ret,


almost: start]
1compiling [ ret,


( This is out first definition of a working colon compiler )

almost: :
word entry, start]
[ ret,
