# The gate on cc370's open-code branch

2026-09-07. `fix/as370-open-code-setc`, seven commits, measured against the whole
of Dave Kreiss' tree and against the object code MVS/CE ships.

cc370 measured the branch on return codes and on decks and asked the one question
its own corpus cannot answer: **when a deck moves, does it move towards IBM?**
Only 103 local pairs exist there; here 5,046 of the 5,528 modules have a
distribution-library member of the same name.

## The answer

| | main `3b8b0b8` | branch `76e01ae` |
|---|---:|---:|
| **byte-identical to IBM's object** | **844** | **874** |
| only `DS` holes differ | 443 | 445 |
| identities lost | — | **0** |
| holes-only cases lost | — | **0** |

**Thirty modules gained byte-identity and none lost it.** Sixteen of them came
out of the *length* bucket — the bucket that was supposed to be waiting on the
provenance of our 319 mirror macros.

The complete list is
[`../work/measurements/opencode-gained.txt`](../work/measurements/opencode-gained.txt);
per-module return codes and deck hashes at every commit are in
[`opencode-gate.tsv`](../work/measurements/opencode-gate.tsv).

## Which commit did it

The branch was gated one commit at a time, not just end to end. That is where
the reconciliation with cc370's own figures lives.

| commit | | rc 0 | identical | decks moved | gained |
|---|---|---:|---:|---:|---:|
| `3b8b0b8` | main, before the branch | 4,533 | 844 | — | — |
| `90ac3ce` | msub destination bounded | 4,533 | 844 | 0 | 0 |
| `6d235db` | `'&&'` folding put in the DC scanner | 4,534 | **873** | **70** | **29** |
| `810e566` | open-code substitution (#141) | 4,154 | 874 | 33 | 1 |
| `76e01ae` | docs only | 4,154 | 874 | 0 | 0 |

**The yield is in the `&&` commit, not in #141.** Twenty-nine of the thirty
identities come from moving `&&` folding out of the substituter and into the `DC`
scanner; #141 itself contributes one, `HMBLKXRF`. cc370 said the two defects
cancelled and that a fix to either half alone would have broken the macro path
silently — this is what the other half was worth in bytes.

## Every claim cc370 staked, checked

Their return-code signature reproduces here almost exactly.

| their claim | measured here |
|---|---|
| 413 modules go rc 0 → 8, all `IEDHJN` on an empty `&SYSPARM` | **413** ✓ |
| 32 modules go rc 8 → 0 | **33** — one more |
| 7 modules go rc 4 → 8, all `IED*` | **7** ✓ (`IEDAYC`, `IEDAYL`, `IEDAYN`, `IEDAYS`, `IEDQAY`, `IEDQBS`, `IEDQFSC`) |
| `IGARPT01` goes 8 → 12 | ✓ — its deck moves, verdict `unpaired` both sides |
| one module goes 12 → 0 | ✓ `IKJEBEFC`, which has no DLIB member |
| the 413 decks do not change | ✓ **all 413 byte-identical across the branch** |
| 33 decks moved | ✓ **for `810e566` alone**, and the same 33, `BLSR3270` included |
| 0 decks moved while both sides assembled cleanly | ✓ **for `810e566` alone** |

Both of the last two hold for **#141's own commit**. Over the whole branch 102
decks move, 63 of them with rc 0 on both sides — every one of those from the
`&&` commit, which was gated on the C corpus, and the C corpus carries no
open-code emit-path reference at all.

Nothing falsified: no deck moved in a module whose return code stayed the same
*without* a commit that explains it, and nothing byte-identical to IBM lost that
identity.

## The 413 are not a regression

`as370` keeps writing the deck at rc 8, so the gate here keeps it too and
compares it. Earlier tree runs deleted the deck on any non-zero return code,
which is why the headline "4,533 modules assemble" falls to 4,154 while the
comparison against IBM only improves. Reported both ways above: **`rc 0` is a
diagnostic count, `identical` is the recovery count**, and #141 makes the first
one stricter without touching the second.

Two consequences worth keeping:

- Seven modules produce a deck **byte-identical to IBM's object while returning
  non-zero** (844 identical against 837 on the rc-0 basis). A gate that throws
  away the deck of a module it calls failed cannot see them.
- What `&SYSPARM` the real TCAM assemblies passed is now a source question, not
  a tool question. `as370` grew `--sysparm=`; the gate deliberately does not use
  it, because IFOX's default is null and that is what is being reproduced.

## Reproducing

```sh
tools/gate.sh <as370-binary> <label>     # rc + deck hash for all 5,528, decks kept
tools/hashdecks.sh obj_<label>           # hashes with the END card excluded
```

Two traps, both silent, both cost a wrong finding here first:

- **`as370` stamps `&SYSDATE`/`&SYSTIME` into 381 decks.** Two runs on different
  days differ in every one of them. Pin `ASMDATE`/`ASMTIME` in the environment,
  or a clock tick reads as a moved deck.
- **The `END` card carries the assembly date too**, in every deck. Hash the deck
  without its last card.

The comparator must also be the current one: a stale `cmplmd370` without the
`X'10'` scatter record silently mis-scored twelve `ICK*` modules and `IECTSVC` — thirteen in all.

---

# The #141 candidate list, and why it did not reconcile

cc370 asked for the selection rule behind "52 modules use it, 13 assembling".
**There is no such list.** It was never written to disk: the count survives only
in the commit message of `61e0bce`, and the `TODO.md` entry linked
`opencond2.txt`, which is the `AIF`/`AGO` list from the same afternoon. The rule
is not recoverable, so it has been rebuilt from scratch rather than guessed at.

[`tools/opencode_scan.py`](../tools/opencode_scan.py) walks all 5,528 modules,
tracks `MACRO`/`MEND` depth, joins continuations at column 72, and offers three
rules:

| rule | what it flags at depth 0 | modules | of them rc 0 |
|---|---|---:|---:|
| `--mode set` | the operation is `SETA`/`SETB`/`SETC` | 171 | |
| `--mode emit` | a variable symbol in the name, operation or operand of a statement that emits | **258** | **148 (57 %)** |
| `--mode cond` | `AIF`/`AGO`/`ACTR`/`ANOP`/`MEXIT` | 1,838 | |

`emit` is the rule that matches what #141 actually fixes, and it is the one to
compare against cc370's 67–68. **It does not reproduce 52, and it should not be
tuned until it does** — that would manufacture an agreement the PR is trying not
to fake. The reconstruction is now the citable rule; the old number is not.

The assembly rate confirms what both counts saw: **57 % against 82 % tree-wide.**
A module using conditional assembly in open code is a harder module.

## The lists do not predict the movers, and that is the finding

Of the 102 decks the branch moves, **40 carry no open-code variable-symbol
reference at all**. Thirty-nine of them carry `&&` in open code — they are the
`&&` commit's work, and no scan built for #141 was ever going to see them. The
fortieth is **`BLSR3270`, which contains no ampersand anywhere in its source**
and still moves, under `810e566`, the substitution commit itself.

So the miss cc370 attributed to continuation handling is not that: this scan
does handle continuations and still does not flag `BLSR3270`. Its deck changes
in an ESD section length. That one is open.

`opencond2.txt` is left as it is and the `TODO` link corrected. The three lists
above are `work/measurements/opencode-{set,emit,cond}.txt`.

---

# What cc370#151 is exposed to here

cc370 traced `BLSR3270` to a third defect: `as370` clips a `SETC` value at 95
characters where IFOX00 holds 255, so a 128-character translation table indexed
near its end returns null. They asked the one question that is ours rather than
theirs — **are the exposed macro members among the mirror members whose
provenance is still open?**

[`tools/setc95.py`](../tools/setc95.py) counts the value the way IFOX does:
literal content, `''` folded to `'` and `&&` to `&`, concatenated operands
summed, continuations joined at column 72 first.

| library | members with a `SETC` value over 95 | provenance |
|---|---:|---|
| `AMACLIB` | 10 | IBM, from the MVS/CE 2.1.4 DLIBs |
| `AMODGEN` | 2 | IBM |
| `AGENLIB` | 2 | IBM |
| `ATCAMMAC` | 1 | IBM |
| **`mirror`** | **2** | **web mirror, maintenance level unestablished** |

**Fifteen of the seventeen are IBM's own material**, so #151's exposure does not
rest on anything we doubt. The full list is
[`../work/measurements/setc-over-95.txt`](../work/measurements/setc-over-95.txt).

## The witness, though, is entirely mirror material

The two in `mirror/` are `BLSCAMMM` (104) and **`BLSR327M` (128) — the macro
holding `&TR3270`**, the table in cc370's own reduction. The two macros that
index it, `BLSRCVTA` and `BLSRSF`, are mirror-only as well. All four arrived in
the web-mirror import of 2026-09-05 and exist nowhere else on this machine, and
all four appear in the tape's `++MAC` inventory — Dave Kreiss' build expects
them; the tape does not deliver them.

So the length of `&TR3270` is not an established fact. **Keep #151 and drop
`BLSR3270` as its witness:** the defect is proved by cc370's own reduced case in
`as370`'s test corpus, which owes nothing to a mirror.

## Two counts that do not reconcile, and one of them is a scanner artifact

cc370 measured 46 macro members and 5 MVSBLD modules. This rule gives **17 and
zero**. The zero is not a near miss: **the longest `SETC` literal in any of the
5,528 modules is 48 characters** (`ICBVMG00`).

A looser rule — operand *text* over 95 characters rather than value — gives 28
and 1, and that one module is `IGARPT01`, whose statements look like

```
&IGADDR  SETC  'X''00'''  THE OFFSET TO THE ADDRESS OF THE MODULE …
```

a three-character value with a long remark. **The loose rule is measuring the
remarks field**, which is cc370#149 wearing different clothes — an attribute or
quote state that runs past the operand. Any count of "long `SETC`" built without
splitting the remarks off will inherit it.
