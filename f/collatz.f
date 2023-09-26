: collatz.bf  s"

collatz; stops when reaches 1

>>

setup initial number 27 (447 is another good choice)
+> +++++++>
+> ++>

<<[<<]>> rewind

<+> set mark to enter loop

<[-> main loop; clear mark


    print:
    [>>]<<          starting with most significant digit on right
    >>+ [- << >[>>]< ] <<   drop leading zeros; rather tricksy
    [
    >++++++++++++++++++++++++++++++++++++++++++++++++ . add 48 for print
     ------------------------------------------------<
    <<
    ] ++++++++++.[-]        newline
    >>


    are we odd?
    <[-]>           assume even; clear mark
    ->              zero bar for temp
    [- <<+>> <+> [- <<->> <+>   toggle mark on/off
    [- <<+>> <+> [- <<->> <+>
    [- <<+>> <+> [- <<->> <+>
    [- <<+>> <+> [- <<->> <+>
    [- <<+>> <+> [- <<->> <+>
    ]]]]]]]]]]
    <[->+<]+            restore; reset bar

    <[-> we are odd; so do 3*n plus 1

    triple every digit; paying no attention to carrying
    [
        ->          zero bar for temp
        [-<+++>]        triple digit into bar
        <[->+<]     collect
        +>>         reset bar; next
    ]
    <<[<<]>>        rewind

    increment
    >+<

    normalize digits; carrying upto twice
    [
        ->          zero bar for temp
        [-<+> [-<+>     
        [-<+> [-<+>
        [-<+> [-<+>
        [-<+> [-<+>
        [-<+> [-<+>
        >>+<<       reached 10 so carry
        <[-]>       splat 10
        >[-]+<      ensure bar set on the carry digit
        [-<+> [-<+>
        [-<+> [-<+>
        [-<+> [-<+>
        [-<+> [-<+>
        [-<+> [-<+>
        >>+<<       reached 10 so carry
        <[-]>       splat 10
        [-<+>]      save remaining
        ]]]]]]]]]]]]]]]]]]]]
        <[->+<]     collect %10
        +>>         reset bar; next
    ]
        <<[<<]>>        rewind


    print:
    [>>]<<          starting with most significant digit on right
    >>+ [- << >[>>]< ] <<   drop leading zeros; rather tricksy
    [
        >++++++++++++++++++++++++++++++++++++++++++++++++ . add 48 for print
         ------------------------------------------------<
        <<
    ] ++++++++++.[-]    newline
    >>

    <]> end of odd case; it wont be odd now

    divide by 2:
    [
    ->          zero bar for temp
    [- <<+++++>> [- <<----->> <+>
    [- <<+++++>> [- <<----->> <+>
    [- <<+++++>> [- <<----->> <+>
    [- <<+++++>> [- <<----->> <+>
    [- <<+++++>> [- <<----->> <+>
    ]]]]]]]]]]
    <[->+<]         collect div2 result
    +>>         reset bar; next
    ]
    <<[<<]>>            rewind


    have we reached 1?
    <[-]+>      0: assume not 1;  set mark
    ->          zero bar for temp
    [- <+> <<->>    1: it might be 1; unset mark
    [- <+> <<+>>    2: its not 1;     set mark again
    [- <+>      3 or more; save rest of number
    ]]]
    <[->+<]+>>      restore; reset bar; next
    [-<<<[-]+>>>]+<<    more than 1 digit; set mark


<]> end of main loop


print the final 1 and newline
++++++++++++++++++++++++++++++++++++++++++++++++.[-]
++++++++++. newline

" ;

: fast collatz.bf fast-run-bf ;
: slow collatz.bf run-bf ;
