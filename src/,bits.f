
: ff over over > if dup fact . 1 + ff then ;
: count dup . 1 + br count then ;

: foo 42 . ;
: thrice dup dup execute execute execute ;
( ' foo thrice )

: test-exit if 111 exit then 222 ;
0 test-exit 222 expect
1 test-exit 111 expect

: [']

: constant create ['] lit compile, , ;

42 constant life

: constant
    create
    ' lit compile,
    ,
    ' exit compile,
    ;

33 constant foo

create constant
` create ` ` ` lit ` , ` ` ` exit ` exit

: ` ' compile, ;

create life ` lit 42 , ` exit

life .
life life + .

341 constant pi

pi pi + .

: create ['] ' ' ,compile
immediate! [']

: if        ['] 0branch compile, here-pointer @ 0 , ;
immediate! if

immediate! '

: xif        ' 0branch compile, here 0 , ;
immediate! if
immediate! xif

: postpone  lit ' , compile, ; immediate

: if        postpone 0branch here @ 0 , ;   immediate


( bracket compile )
( should be immediate )
create [compile] ' ' compile, ' compile, compile, ' exit compile,

: [compile] ' compile, ;

create *2 [compile] dup [compile] + [compile] exit
create *4 [compile] *2 [compile] *2 [compile] exit

5 *4 20 expect


: skip parse-word drop ;
: skip create ;
: )
: ( skip br ( ;
( ignore me please ) hello


( myinterpret wip )
: execute_if_not_zero dup if execute exit then drop ;
create interpret ! ' ! execute_if_not_zero ! interpret




11 x-create life literal ' exit compile,
life life + 22 x

12 constant life
life life + 24 x

10 3 + constant lucky
lucky lucky + 26 x

;; defword "x-create" ; "x" because this definition is bogus
;; _x_create:
;;     call t_word
;;     POP di
;;     call internal_create_entry
;;     ret


( : constant  x-create lit x['] lit compile, , lit x['] exit compile, ; )
( : variable  here 0 , constant ; )
