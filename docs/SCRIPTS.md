# Actor scripts

Up to 8 actors ("slots") are animated by byte-code scripts (`src/data/scripts.c`, DGROUP 020A-125F).
`g_scriptTable[]` (DGROUP 1262) holds one far pointer per script. `g_1332`, `g_1336`, `g_13E2`, `g_13E6`, `g_13EA`,
`g_1452` and `g_145A` are fixed entry points. Slot 7 is Donald, and the other slots are the letters of the current group.

Slot state is a struct of parallel arrays (the original layout, so it cannot become a C `struct`):
`slot_x`/`slot_y` (pixels), `slot_w`/`slot_h` (cells), `slot_frame` (animation frame), `slot_shown` (frame drawn,
-1 = hidden), `slot_pc` (script pointer), `slot_delay`/`slot_timer` (ticks per step), `slot_flag` (facing left).

`run_script(i)` (0304:11AA) runs once per tick for slot `i`. If `slot_timer` is still non-zero it only counts down
(twice as fast on Tandy). Otherwise it reloads the timer from `slot_delay` and executes bytes until one yields a
frame:
- A byte `00..7F` is a frame number. It is returned (the slot shows that frame) and the step ends.
- A byte `80..FF` (`-n` as a signed char) is an opcode. Operands follow inline. `x`/`y` are in 8-pixel cells.

| op | hex | operands | effect |
|---|---|---|---|
| -1 | FF | tx lo hi | walk toward column `tx` by one cell, cycling `slot_frame` through `lo..hi`; at `tx` skip the operands |
| -2 | FE | | end: jump to the idle script `g_1332`, stop |
| -3 | FD | x y | set position |
| -4 | FC | n | set delay (and timer) |
| -5 | FB | | pick the next letter: the level is complete (`g_13E2`); idle too long (`g_13E6`); or a random unfinished letter of the group (or the key typed) starts its script |
| -6 | FA | x | wait until Donald is at column `x` |
| -7 | F9 | j x d | if `x < slot_x[j]` jump back `d`, else continue |
| -8 | F8 | j x d | if slot `j` is not at column `x` jump back `d` |
| -9 / -10 | F7 / F6 | | `slot_h` +1 / -1 |
| -11 | F5 | n ... | jump to script `table[roll(1..n)]` |
| -12 | F4 | | face left |
| -13 | F3 | d | 50%: skip forward `d` |
| -14 | F2 | d | 75%: continue, else jump back `d` |
| -15 | F1 | | `next_level()` |
| -16 | F0 | y | wait until Donald is at row `y` |
| -17 | EF | dx | wait until Donald is at own column + `dx` |
| -18 | EE | d | letter already found? then skip `d` and score it |
| -19 | ED | dx | set the bubble column (`g_38D6[3]`) to own column + `dx` |
| -20 | EC | | Donald's jump/catch sequence (`aim`, `step`, sounds 11/10) |
| -21 | EB | d | skip forward `d` |
| -22 | EA | | `init_slots()` |
| -23 | E9 | | slot 0 starts the group's intro script (`g_1461[g_group]`) |
| -24 | E8 | g d | if `g_group == g` skip `d` |
| -25 | E7 | j s | start script `s` on slot `j` now |
| -26..-33 | E6..DF | | move one cell: E, S, W, N, SE, NE, SW, NW |
| -34..-41 | DE..D7 | | the same moves, and also end the step showing `slot_frame` |
| -42 | D6 | | reset the speech bubble and the current letter |
| -43 | D5 | | if a key was accepted, `setup_level(g_145E)`, else continue |
| -44 | D4 | | place 16 px right of Donald, y = 96 |
| -45 | D3 | | clear the current letter (`g_145E = -1`) |
| -46 | D2 | n | `play_sound(n)` |
| -47 / -48 | D1 / D0 | | set / clear `g_38B2` |

The jump distances are relative to the operand byte. The exact semantics are in `run_script` (matched C).
