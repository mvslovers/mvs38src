# cc370 #410 — `--json`, the object-side half of the repair contract

Gated twice and merged as **`a828439`**. It does **not** close `cc370#385`: three
of the five fields that issue specifies are listing facts with no machine-readable
export, and the shape decision — build the `as370` export first, or ship the
object side now — is still open.

## Controls

| | first head `20640f8` | second head `a532e9f` |
|---|---|---|
| null control against `main` | 745 of 745 byte-identical | **745 of 745** |
| the 832 with `--json`, parse | 832 of 832 | **832 of 832** |
| JSON against the text report | 0 mismatches on any subtotal | **0** |
| merged build against the gated one | — | **BYTE-IDENTICAL** `c98d30a4…` |

```
findings 120,163   const 109,257   consequences 382,378
insert 2,579   delete 6,423   data 1,904   unchanged 43,486   edits 392,790
```

Every figure identical to this session's own text-report run of the same 832 from
earlier the same day, on a separate build. **The emitter agrees with the report it
is derived from, module for module and subtotal for subtotal.**

⚠️ **The null control is 745 runs and not the 868 of every earlier gate**, because
`reachgate.corpus("nosource")` now resolves through `LMDXRF` and the no-source
population went from 772 to 649. The denominator moved **down** and the control is
the same control.

## The one change asked for between the two heads

`source_absent_because` — a 265-character sentence carrying the `DS 0F` / `DS CL1`
measurement — was repeated on **every one of the 120,163 findings**, about 32 MB of
77.5. It is identical in every record and it is a property of the build rather than
of the finding. Hoisted beside `note`:

```
77.5 MB -> 47.3 MB     39 % smaller, every count unchanged
```

What stays per finding is `"source": null, "source_absent": "no-statement-export"`
— nine characters, because a consumer can hold a single finding in its hand and
should still see which absence it is.

## `from: "disassembly"` — the field marks a boundary, and the crossing is ours

Every statement in the document carries `"from": "disassembly"`. The cc370 session
read that as marking something missing on their side. It is not: the **`cand` side
is our deck**, assembled from our source, so a card does exist for it and
`deck offset → source statement` is the crossing. **That is `macroattr.py`'s
`owner()`, and its known defect** — the nearest emitting statement at or below an
address, so padding attaches to whatever precedes it, the same defect already fixed
once in `alignfill.py`.

So the field is correct as it stands and the work it points at is on this side.
