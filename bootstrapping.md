
### Reducing the bootstrap dependencies.

At the heart of every Forth system are the interpreter and colon compiler. The definition for these is often found in Forth itself, but we need _something_ in the kernel which allows these definitions to be interpreter/compiled.

In an earlier version of this Forth implementation, the kernel started a minimal _word-find-execute_ loop. This had no support for numerics, and no colon compiler. These were defined in Forth. This was nice. Having the full interpreter and compiler defined in Forth meant they were available for any re-targetting of the system. However, even the simplest _word-find-execute_ loop is rather complicated. Coded in Asm. And _would_ have to be re-coded for each re-targetting.

There are three sub-components to consider: `word` `find`, and `execute`. Execute is simple and bound tightly with the threading model, so will remain as a core primitive of the system. But "word" and "find" are each non-trivial bits of code:
- "word" tokenizes a blank separated word from the input stream.
- "find" looks up in the dictionary the execution token associated with a word.

Wouldn't it be nice if we could avoid defining these in Asm. The idea behind Quarter Forth is to have the kernel expose an even lower level interface in which the definitions for `word` and `find` can be made. The idea is that initial bootstrap code is written in a _not-quite_ Forth language, known as _quarter_, where primitives are referenced by single character names, and accessed via a fixed dispatch table in the kernel.

The kernel starts up running a _key-dispatch-execute_ loop: We can think of `key` as standing in for `word`, and `dispatch` for `find`. The primitive `key` is necessary anyway in a Forth system, being the primary means to access input from the keyboard. But `dispatch` is novel.

The kernel will expose via a simple dispatch table whatever primitives are needed to implement `word` and `find` in the `quarter` bootstrap code. This is in addition to exposing all primitives in the initial dictionary. The dispatch table has 128 entries, and is indexed by the 7-bit ascii value of the character. All that remains is to see what primitives are [needed](kernel.asm#L58), and decide how to name them so the [quarter bootstrap code](f/quarter.q) retains as much readability as possible!

At the conclusion of the bootstrap code we have again the basic _word-find-execute_ loop.

This is not the first Forth system to explore the limits of boot-strapability -- buzzard.2 and Sector forth go before me -- but I think this approach is slightly different. The driving force here is not just an academic exercise, but as a practical technique to reduce the effort when re-targetting. I have real plans to retarget this Forth for the 6502 processor, both for my BBC Micro, and also my home-brew 6502 computer (based on Ben Eaters design). On the BBC, I hope to pick up my stalled Meteors clone. Asm is hard to write; the less I have to write, the better!
