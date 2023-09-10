.." Loading colon ( " latest

( Define reference implementation of ] and : )

( We make use of the previous  "]" whilst defining ths one )

here char ; , 0 , constant string; ( TODO: string lits are available now )

: compiling
word ( name ) dup

( s" ;" )               ( IF WE HAD STRINGS )
( lit [ string; , ] )   ( THE SAME AS THE NEXT LINE )
[ string; ] literal

s= if drop ret, ( OPTIMIZED ) exit

then ( name )

dup find dup if ( name xt )
swap drop ( xt )

dup immediate?
  if execute
  else compile,
  then tail compiling

then drop ( name )

number? if
['] lit compile, , tail compiling
then ( name )

( word not defined )
." ** Colon compiler: '" type ." ' ?" cr
crash-only-during-startup
tail compiling
;

: : word entry, compiling ;

hide compiling
hide string;
words-since char ) emit cr
