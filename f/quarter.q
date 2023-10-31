^q.^u.^a.^r.^t.^e.^r.^..^q.M

:' ^^?> ^??> ;
:~ ^^?> ^??> ^>?> ;
:# 'L ~L, ~> ~, ;
:i ~L ^B?, ~>~H~@ 0# ~, ;
:t ~D~H~@~W~-~W~! ;

H@^(`0`E :( ~^ ^)# ~= i ~X t '(#~J ;

( Now we have comments! Preceeding defs are:
tick, compile, literal, if, then, open-paren:start-comment )

:h ~H~@ ; (here)
:j ~' 'L#~>~, 'J#~> ; (jump)
:q ~O~O~C~W~C~O~= i 0# ~= i ~P~P 01-# ~X t ~1~+~W~1~+ jq t ~P~P~P 0# ; (s=)
:p ~D~C~D i ~.~1~+ jp t ~P~P ; (type)
:n 11+D+D+D+D+#~W~< ; (is-white)
:k ~^~D~n i ~` ~X t ~P jk ; (skip-leading-whitespace)
:c ~^~D~n i ~` jc t ~P~0~`~X ; (collect-while-not-whitespace)
:v ~h~k~c ; (word,)
:w ~v~D~H~! ; (word)
:g ~D i ~D ~Y i ~G jg t ~O~O~N~q i ~W~P~X t ~G jg t ~P~P~0 ; (find-loop)
:u ~Z~g ; (find)
:f ~D~u~D i ~W~P~X t ~P ~p ^?# ~.~M~A~0; (find!)

( interpreter and compiler )
h ^]`0` h^[`0`E :[# ~w~W~O~q i ~P  ~X t ~D~f~D i ~W~P        ~V j[         t ~P~p ^?#~.~M~A j[;
h ^;`0`         :]# ~w~W~O~q i ~P~;~X t ~D~f~D i ~W~P ~D~I i ~V j] t ~> j] t ~P~p ^?#~.~M~A j];
h ^:`0`E ~v~E j] ;

h ^'`0`E ~w~f ; ( tick )
