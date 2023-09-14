
:'  ^^?> ^??> ;
:~  '^> '?> '>> ;
:`  ~^ ~\ ;
:h  ~H~@ ;
:i  ~l ^B?, ~>~h 0L ~, ;
:t  ~D~h~W~-~W~! ;

:(  ~^ ^)L ~= i ~X t ~l^(?,~J ;

( This file is in Quarter syntax. )
( The above squiggle gives us comments both in Quarter code )

h `s`= 0\ E         :q ( string equality )
~O~O~C~W~C~O~= i
0L ~= i ~P~P 01-L ~X
t ~1~+~W~1~+ ~l^q?,~J
t ~P~P~P 0L
;

h `t`y`p`e 0\ E     :p ( string print )
~D~C~D
i ~.~1~+ ~l^p?,~J
t ~P~P
;

:w                  ( is-white )
~b~W~< 01-L ~x ;

:k                  ( skip leading whitespace )
~^~D~w
i ~P ~l^k?,~J
t ~\
;

:c ~^~D~w           ( collect while not whitespace )
i ~P~0~\~X
t ~\ ~l^c?,~J
;

h `w`o`r`d 0\ E :a ~h~k~c
;

h `t`r`a`n`s`i`e`n`t`-`w`o`r`d 0\ E :j  ~a~D~H~!
;

:g                          ( find-loop )
~D i ~D ~Y i ~G ~l^g?,~J
t ~O~O~N~q i ~W~P~X
t ~G ~l^g?,~J
t ~P~P~0
;

h `f`i`n`d 0\ E :u
~Z~g
;

^?
:f
~p L ~.~M~*
;

h `f`i`n`d`! 0\ E :y
~D~u~D
i ~W~P~X
t ~P~f
;

:[              ( word-find-execute loop )
(^$L~.)
~j~y ~D
i ~V ~l^[?,~J
t ~P ~l^[?,~J
;

h `' 0\ E
~j~y  ( TODO: better names for the important defs )
;

( enter the WFX-loop )
[
