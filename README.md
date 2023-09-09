# nforth

A new Forth system, currently targeting bare metal x86, but which aims to minimize platform dependencies by being coded within Forth as much as possible. The [Kernel](kernel.asm) implements a handful of core primitive, and then starts just a bare _word-find-execute_ loop: with not even any support for numeric literals, and definitely no `:` compiler -- these are defined aferwards in [Forth](f), following a careful [bootstrapping](forth.list) process.

The [Makefile](Makefile) provided can build the system (`make`) and spin up within a _qemu_ emulator (`make run`). Project dependencies are currently just `nasm` and `qemu-system-x86`.

Plans are ideas are [here](notes/plan.txt).

### References useful to me:
- [Threaded Interpretive Languages, R. G. Loeliger, 1981](https://archive.org/details/R.G.LoeligerThreadedInterpretiveLanguagesTheirDesignAndImplementationByteBooks1981)
- [Starting Forth, Leo Brodie](https://www.forth.com/starting-forth)
- [Moving Forth, Brad Rodriguez](https://www.bradrodriguez.com/papers/moving1.htm)
- [Forth standard](https://forth-standard.org)
- [Jones Forth, Richard Jones](https://github.com/nornagon/jonesforth/blob/master/jonesforth.S)
- [Tumble Forth, Virgil Dupras](https://tumbleforth.hardcoded.net)

Particular thanks go to the _tumble forth_ tutorial, which guided my first steps.
