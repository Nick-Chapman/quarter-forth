
( Play around with BF compilation for factorization example )

: go factor.bf fast-irun-bf ;
: test-bf-factor

time nip
." Testing compiled bf factorization..." cr

( The bf factorization program expects the input to be terminated by NL )
( s" 1
" go
s" 12
" go )
s" 123
" go
s" 1234
" go
s" 12345
" go
s" 123456
" go
( s" 1234567
" go )

." DONE" cr
time nip
." #Ticks (1/18s) = " swap - . cr

." Any key to quit" cr crash

;
test-bf-factor
