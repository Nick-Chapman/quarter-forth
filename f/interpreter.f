.." Loading interpeter" cr

: [
transient-word
dup s" ]" s= if drop exit then
dup find dup if swap drop execute tail [
then drop number? if tail [
then ." ** Interpreter: '" type ." ' ?" cr crash-only-during-startup tail [
; immediate

[
