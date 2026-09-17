# cc370 #408 (`#396`) — `--labels sequential`, gated 2026-09-17

Built here from `git archive 665bbb6` and merged as **`b338904`**.

A label minted from a displacement **assembles and is still false**: it is a
well-formed name, the object it produces is correct, and it claims an address it
need not occupy. Every instrument either side has — the round trip, `cmplmd370`,
`reachgate.py`, `--align-diff` — reports success on it. That is why the acceptance
cannot be a gate of ours and has to ask **`as370`'s own symbol table** where each
label landed.

## Controls

| | |
|---|---|
| **A** default output against `main` over control + stage1a + nosource | **868 of 868 BYTE-IDENTICAL** |
| **B** both label forms assembled, object compared | **6 of 6 identical**, 84 to 3,370 bytes |
| **C** the lie constructed here, not taken on report | see below |
| merged build against the gated one | **BYTE-IDENTICAL** `ed37df72…` |
| CI | green, clang and gcc |

## C — the lie, constructed independently

`BLSCAMER`'s own disassembly, one `LR 0,0` injected immediately after the `CSECT`
card — two bytes, the smallest edit a repair could make — then assembled and the
listing's symbol addresses compared against what each name claims:

```
displacement   26 of 26 generated labels name an address they do not occupy
                  L000000 actually at 0x000002
                  L0001E2 actually at 0x0001E4
                  L0001EE actually at 0x0001F0
sequential      0 of 26 -- a sequential name makes no address claim at all
```

The cc370 session's own acceptance reports **4 of 4** on a fixture; this is 26 of
26 on a real module, and it is the same statement from the other side.

**The names change and the object does not.** That is the whole property: the
repair is free, and every disassembly produced before it lands carries names that
become false the first time anything is edited.
