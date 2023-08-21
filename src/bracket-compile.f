
( should be immediate )
create [compile] ' ' compile, ' compile, compile, ' exit compile,

: [compile] ' compile, ;

create *2 [compile] dup [compile] + [compile] exit
create *4 [compile] *2 [compile] *2 [compile] exit

5 *4 20 expect
