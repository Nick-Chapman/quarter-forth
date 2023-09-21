^q.^u.^a.^r.^t.^e.^r.^..^q.M

:'  ^^?> ^??> ;
:~  '^> '?> '>> ;
:`  ~^ ~\ ;
:h  ~H~@ ;

h `l`i`t`e`r`a`l 0\ E
:#  ~L'L,~>~, ;
:i  ~L ^B?, ~>~h 0# ~, ;
:t  ~D~h~W~-~W~! ;

h`(0\E
:(  ~^ ^)# ~= i ~X t '(#~J ;

( This file is in Quarter syntax. )
( The above squiggle gives us comments both in Quarter code )

h `s`= 0\ E         :q ( string equality )
~O~O~C~W~C~O~= i
0# ~= i ~P~P 01-# ~X
t ~1~+~W~1~+ 'q#~J
t ~P~P~P 0#
;

h `t`y`p`e 0\ E     :p ( string print )
~D~C~D
i ~.~1~+ 'p#~J
t ~P~P
;

:n                  ( is-non-white; > ascii 32 )
11+D*D*D+#~W~< ;

:k                  ( skip leading whitespace )
~^~D~n
i ~\~X
t ~P 'k#~J
;

:c ~^~D~n           ( collect while not whitespace )
i ~\ 'c#~J
t ~P~0~\~X
;

h `w`o`r`d`, 0\ E     :v ( collect word on heap )
~h~k~c
;

h `w`o`r`d 0\ E :w
~v~D~H~!
;

:g                          ( find-loop )
~D i ~D ~Y i ~G 'g#~J
t ~O~O~N~q i ~W~P~X
t ~G 'g#~J
t ~P~P~0
;

h `f`i`n`d 0\ E :u
~Z~g
;

h `f`i`n`d`! 0\ E :f
~D~u~D
i ~W~P~X
t ~P ~p ^?# ~.~M~*
;

h `' 0\ E       ( Forth level ' -- word find! )
~w~f
;

( Interpreter )

h `] 0\
h `[ 0\ E :[
# ~w~W~O~q i ~P~X t     ( get word; exit if ] )
~D~f~D i ~W~P~V '[#~J t ( lookup; execute if found )
~P~p ^?#~.~M~A '[#~J    ( otherwise report error )
;

( Compiler )

h `; 0\
:]
# ~w~W~O~q i ~P~;~X t
~D~f~D i ~W~P
~D~I i ~V ']#~J t ~> ']#~J t
~P~p ^?#~.~M~A ']#~J
;

h `: 0\ E
~v~E ']#~J
;

( Enter interpreter ) [
