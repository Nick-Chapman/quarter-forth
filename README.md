# Quarter Forth

A new Forth system, currently targeting bare metal x86, but which aims to minimize platform dependencies by being coded within Forth as much as possible. The [Makefile](Makefile) provided can build the system with (`make`) and spin up within a _qemu_ emulator with (`make run`). Project dependencies are currently just `nasm` and `qemu-system-x86`.

### Bootstrapping

The [Kernel](kernel.asm) implements the core primitive, and then starts just a bare _key-dispatch-execute_ loop, to allow the [bootstrapping](forth.list) process to begin.
The [first stage](f/quarter.q) of the bootstrap process defines the `word` and `find` primitives necessary for a Forth system. Until these are available we are coding in a _not-quite_ Forth language; primitives are referenced by single character names, and accessed via a hard-coded dispatch table in the kernel. At the end of the first stage we have a basic _word-find-execute_ loop.
The [next stage](f/boot.f) builds a simple `:` compiler, with support for immediate words.
Bootstrapping continues until eventually we define support for parsing numbers, and thus become able to implement the standard [interpreter](f/interpreter.f) and [compiler](f/colon.f) which we expect from a Forth system.

### References useful to me:
- [Threaded Interpretive Languages, R. G. Loeliger, 1981](https://archive.org/details/R.G.LoeligerThreadedInterpretiveLanguagesTheirDesignAndImplementationByteBooks1981)
- [Starting Forth, Leo Brodie](https://www.forth.com/starting-forth)
- [Moving Forth, Brad Rodriguez](https://www.bradrodriguez.com/papers/moving1.htm)
- [Forth standard](https://forth-standard.org)
- [Jones Forth, Richard Jones](https://github.com/nornagon/jonesforth/blob/master/jonesforth.S)
- [Tumble Forth, Virgil Dupras](https://tumbleforth.hardcoded.net)

Particular thanks go to the _tumble forth_ tutorial, which guided my first steps.

Future plans are ideas are [here](notes/plan.txt).
