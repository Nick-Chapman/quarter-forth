
:: immediate latest immediate^ ;

:: here      here-pointer @ ;
:: if        0branch, here 0 ,     ; immediate
:: then      dup here swap - swap ! ; immediate
:: exit      r> drop ;

:: (         key [char] ) = if exit then tail ( ; immediate

( Now we can write comments! Woo hoo! )
