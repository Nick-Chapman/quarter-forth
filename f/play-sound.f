
( play with sound on the BBC )

: -15  0 15 - ;

: half-second 10 ;
: max-volume -15 ;

: loud1-sound ( duration pitch -- )
max-volume 1 sound
;

: pitched ( pitch -- )
half-second swap loud1-sound
;

: c 100 pitched ;
: d 108 pitched ;
: e 116 pitched ;
: f 120 pitched ;
: g 128 pitched ;

: tune c d e f g f e d c ;
