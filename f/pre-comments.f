
: here      here-pointer @ ;
: allot     here + here-pointer ! ;

: if        0branch, here 0 ,   ; immediate
: then      here swap !         ; immediate
