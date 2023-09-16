
### Minimizing the bootstrap dependency further

Interpreter and colon compiler normally heart of Forth system.
Nice if that logic can be extracted into Forth so it doesn't have to be repeated for each port.
That is what I have done in Quarter Forth.
The kernel just starts a minimal  _word-find-execute_ loop [link]
But even this is quite a piece of complicated logic which must be coded in Asm, and so repeated for each re-targetting.
It needs 3 sub components (words) -- word find execute
execute is simple and bound with the threading model, so makes sense in Asm.
But "word" and "find" are each non-trivial bits of code.
Here are my forth definitions [link] but these are repeated in Asm. [link]
Wouldn't it be nice to avoid the Asm definitions!
But how can we write Forth code without them?
- "word" gets a blank separated word from input
- "find" looks up the execution token for this word in the dictionary.
Both elements are pretty fundamental.

But what it we could avoid both by starting at an even simpler level.
Where a few words are named by a single char,
And accessed via a trivial dispatch on the char code.
We will only need this for a handful of words; just what we need to implement word and find.
And then the kernel needs only to start running a _key-dispatch-execute_ loop. Even simpler.
The existing _word-find-execute_ loop will be coded on top of this.
Using this weird abbreviated primordial Forth-like language
And this is how we can minimize the bootstrap process.

Still some details to work out.
Figure out what are the few builtins we need to expose via dispatch.
And what to call them, so the primordial worth retains some semblance of readability.
And I need to code the actual implementation!

I really think this will be a useful goal to achieve, and not just an academic exercise in minimal bootstrapping. Asm is hard to write; the less we have to write, the better. Making any future system re-targeting a simpler process.
And I do have plans to re-target my forth to 6502. For both my BBC Micro. And also my home-brew 6502 based on Ben Eaters design. On the BBC, I hope to pick up again my stalled Meteors clone. Did I mention Asm is hard.


### Language choices:

- case sensitive; lowercase
- null terminated strings
- my interpreter "[" and colon compiler ":" are separate words -- looking for markers, respectively "]" and ";" -- instead of being a single state aware word.
- numbers are always unsigned, and currently always parsed and printed by `.` in decimal. But I will support `hex` / `decimal` state soon.
- no support for floats or double arithmetic
- We do have return stack operators
- Recursion is possible/allowed. Enabled by words becoming visible in the dictionary from the moment the dictionary header is linked.
- Recursion is the preferred means of coding iteration. Currently there is no support for the standard Forth looping words. They are not hard, but just not been done yet, and not really a priority for me. When you have recursion, who needs loops?
- Tail recursion is supported (via `tail`) and seems to nicely complement the standard word `exit`. It allows easy coding of iterative processes which don't consume the return stack. You can do just about everything you want with if/then/exit/tail (I don't even have else yet!).

### Implementation choices:

- 16 bit. cell = 2bytes
- threading model: subroutine threaded
- x86. call instructions are 3 bytes. A 1 byte op-code + 2 bytes relative address.
- Dictionary header format: (null-terminated) string, link-cell, length/flag-byte, followed directly by the executable code. The address of the executable code is used as the representation for execution tokens. The link cell is 0 or points to the previous XT.
