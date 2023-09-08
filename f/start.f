.." Loading start" cr

cr
.." Welcome to nforth. A 16-bit Forth system running on x86." cr
cr
mem cr
.?stack
startup-is-complete
hide startup-is-complete
hide crash-only-during-startup

{
: test
s" 54321" dup my-number?
.s
;

.." Testing..." cr
test
}

echo-on
