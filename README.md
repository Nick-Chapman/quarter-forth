# Quarter Forth

A new Forth system, currently targeting bare metal x86, but which aims to minimize platform dependencies by being coded within Forth as much as possible. The [Makefile](Makefile) provided can build the system with (`make`) and spin up within a _qemu_ emulator with (`make run`). Project dependencies are currently just `nasm` and `qemu-system-x86`.

Quarter Forth is named for the _not-quite_ Forth language (_quarter_) used while [bootstrapping](bootstrapping.md).

I've blogged about Forth and Quarter [here](https://nick-chapman.github.io/blog/)

### Bootstrapping

The [Kernel](kernel.asm) provides the core primitive, and starts a bare _key-dispatch-execute_ loop, so the [bootstrapping](forth.list) process can begin.

The [first stage](f/forth.q) of the bootstrap defines the `word` and `find` primitives
necessary for a basic Forth interpreter and compiler. At this point, we are coding in _quarter_ where primitives are referenced by single character names, and accessed via a hard-coded dispatch table in the kernel. By the end of the first stage we have definitions for `[` and `:`. We enter the interpreter now and transition to Forth.

Bootstrapping continues in [Forth](f/system.f), defining all the standard Forth words, and providing us support for numerics, resulting in implementations for `[` and `:` with the standard behaviour expected from a Forth system.

### Language choices

- Case sensitive; lowercase preferred.
- Null terminated strings.
- Interpreter "[" and colon compiler ":" are separate words -- looking for markers, respectively "]" and ";" -- instead of being a single state aware word.
- Numbers are unsigned. the `number?` parser and `.` printer are base state aware, controlled by `hex` / `decimal`.
- No support for floats or double arithmetic.
- We do have return stack operators.
- Recursion is possible/allowed. Enabled by words becoming visible in the dictionary from the moment the dictionary header is linked.
- Recursion is the preferred means of coding iteration, although there is now support for standard Forth loops using `do`..`i`..`loop`. But when you have recursion, who needs loops?
- Tail recursion is supported via `tail` or`recurse` which seems to nicely complement the standard word `exit`. It allows easy coding of iterative processes which don't consume the return stack. You can do just about everything you want with if/then/exit/tail.

### x86 Implementation choices

- 16 bit. cell = 2bytes
- Threading model: subroutine threaded
- x86. call instructions are 3 bytes. A 1 byte op-code + 2 bytes relative address.
- Dictionary header format: (null-terminated) string, link-cell, length/flag-byte, followed directly by the executable code. The address of the executable code is used as the representation for execution tokens. The link cell is 0 or points to the previous XT.


### References useful to me:
- [Threaded Interpretive Languages, R. G. Loeliger, 1981](https://archive.org/details/R.G.LoeligerThreadedInterpretiveLanguagesTheirDesignAndImplementationByteBooks1981)
- [Starting Forth, Leo Brodie](https://www.forth.com/starting-forth)
- [Moving Forth, Brad Rodriguez](https://www.bradrodriguez.com/papers/moving1.htm)
- [buzzard.2 (1992 IOCCC entry), Sean Barrett](http://ftp.funet.fi/pub/doc/IOCCC/1992/buzzard.2.design)
- [Forth standard](https://forth-standard.org)
- [Jones Forth, Richard Jones](https://github.com/nornagon/jonesforth/blob/master/jonesforth.S)
- [Sector Forth, Cesar Blum](https://github.com/cesarblum/sectorforth)
- [Tumble Forth, Virgil Dupras](https://tumbleforth.hardcoded.net)

Particular thanks go to the _tumble forth_ tutorial, which guided my first steps.
