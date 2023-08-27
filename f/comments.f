
: [']
word safe-find non-immediate-literal
; immediate

: here      here-pointer @ ;

: if        ['] 0branch compile, here 0 ,   ; immediate
: then      here swap !                     ; immediate

: (
key [char] ) = if exit
then br (
; immediate

(
Now we can write comments!
)
