
:'  ^^?> ^??> ;
:~  '^> '?> '>> ;
:`  ~^ ~\ ;
:h  ~H~@ ;

:#  ~L'L,~>~, ;

:i  ~L ^B?, ~>~h 0# ~, ;
:t  ~D~h~W~-~W~! ;

:(  ~^ ^)# ~= i ~X t ~L^(?,~J ;

( This file is in Quarter syntax. )
( The above squiggle gives us comments both in Quarter code )

h `s`= 0\ E         :q ( string equality )
~O~O~C~W~C~O~= i
0# ~= i ~P~P 01-# ~X
t ~1~+~W~1~+ ~L^q?,~J
t ~P~P~P 0#
;

h `t`y`p`e 0\ E     :p ( string print )
~D~C~D
i ~.~1~+ ~L^p?,~J
t ~P~P
;

:n                  ( is-non-white; > ascii 32 )
11+D*D*D+#~W~< ;

:k                  ( skip leading whitespace )
~^~D~n
i ~\~X
t ~P ~L^k?,~J
;

:c ~^~D~n           ( collect while not whitespace )
i ~\ ~L^c?,~J
t ~P~0~\~X
;

h `w`o`r`d 0\ E :a ~h~k~c
;

h `t`r`a`n`s`i`e`n`t`-`w`o`r`d 0\ E :j  ~a~D~H~!
;

:g                          ( find-loop )
~D i ~D ~Y i ~G ~L^g?,~J
t ~O~O~N~q i ~W~P~X
t ~G ~L^g?,~J
t ~P~P~0
;

h `f`i`n`d 0\ E :u
~Z~g
;

^?
:f
~p # ~.~M~*
;

h `f`i`n`d`! 0\ E :y
~D~u~D
i ~W~P~X
t ~P~f
;

:[              ( word-find-execute loop )
(^$#~.)
~j~y ~D
i ~V ~L^[?,~J
t ~P ~L^[?,~J
;

h `' 0\ E
~j~y  ( TODO: better names for the important defs )
;

( enter the WFX-loop )
[
