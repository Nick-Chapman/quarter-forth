
: my-entry latest-entry ; immediate
: not-yet entry->name todo print-string cr crash-only-during-startup ;

( Would it be possible to combine the 3-word sequence "my-entry literal not-yet" ? )

: one my-entry literal not-yet ;
: two my-entry literal not-yet ;
