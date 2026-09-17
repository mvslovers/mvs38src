# Handover — written 2026-09-17, end of a long session

**Read this, then `TODO.md`'s *Start here tomorrow*, then `CLAUDE.md`.** This file
says where the work stands and what to do next; the other two say why and how.

---

## Where the numbers are

| | |
|---|---:|
| `recovered` — `cmplmd370` exits 0 | **1,629 of 5,353** |
| `explained` — every differing byte in a named class | **1,723** |
| `src/` | **317**, `srccheck.py` green |
| no-source CSECT population | **649** (not 772 — see below) |

`tools/scoreboard.py --check` validates the README scoreboard **and** the two
figures in `TODO.md`'s *"Where it stands"* table. Run it before and after anything.

## Instruments, pinned

`work/src-states/bin/` — `as370-main`, `cmplmd370`, and `PROVENANCE.txt` which
pins them by sha256 with the commit each came from. `cmplmd370` is pinned on cc370
`210ec3a`. **`dasm370` is NOT pinned here**; build it per gate from a
`git archive <sha> | tar -x` into the scratchpad, never out of cc370's working
tree.

Decks: `obj_sysparm1` is `CURRENT` (`tools/decks.py` says so, and says why a stale
deck directory answers every question about yesterday).

---

## What was merged into cc370 today, and what each gate proved

Nine PRs, all gated here on a tree-wide or corpus run, all merged with
`gh pr merge --squash --match-head-commit <full 40-char sha>` on a green head.

| PR | what it is | the gate that mattered |
|---|---|---|
| **#404** `210ec3a` | `cmplmd370`/`dasm370` read a bound member's RLD info 4 bytes late | parent build **byte-identical to the pin**; `recovered` 1,626 → 1,628; **0 modules moved `identical → differs`** |
| **#405** `01ee607` | `--align-diff` — both sides disassembled, shifts as consequences | refactor half **868 of 868 runs byte-identical**; 832-module run reproduced to the unit |
| **#406** `3054c8a` | `--reach-report` — the #383 traversal as a measurement | `--reach` exits 16 and names the measurement rather than vanishing |
| **#407** `4eaacc8` | names which denominator the reach percentages use | "docs only" **verified by hash**, not accepted |
| **#408** `b338904` | `--labels sequential` | the lie constructed here: **26 of 26** generated labels name an address they do not occupy after a 2-byte injection; 0 for sequential |
| **#409** `d650ae6` | a refusal that names what it DID find | ends a whole class of exchange at the first run |
| **#410** `a828439` | `--json`, the object-side repair contract | 832/832 parse, **0 mismatches on any subtotal**; held one round for a schema ask |
| **#412** `f567bca` | an `F_S0`'s tail is not a field | **exactly 1 module moved and it was the broken one**; round trip 649/649 |
| **#413** `98da84b` | `as370 --stmts`, one record per generated statement | **0 of 5,538 decks differ**; `reserves` landed inside the object-side bracket |

---

## 🔴 The immediate next task — and it is the consumer's obligation

**Verify what `org` reports for a card that arrives through `COPY`.**

`as370 --stmts` exports `org`, the input-file line, which locates **61,202 of
61,252** open-code cards. A listing statement number locates **0.8 %** — see
`work/measurements/repair-contract/STMT-IS-NOT-A-LINE.md`. But as370's own code
comment says a `COPY`'d block keeps the **`COPY` statement's** origin, which would
point a repair at the `COPY` card instead of the copied one — an edit that
succeeds, assembles, and is wrong.

```
exposure   348 of 5,538 module sources use COPY
           24 of the 832 (--align-diff population)
            0 of the 30 control CSECTs     <- the judgeable corpus cannot test it
```

So it has to be read module by module. The 24 are obtainable with:

```python
# COPY at columns 10-15, comment cards excluded
l[:1] != "*" and l[9:15].strip().upper() == "COPY"
```
over `work/src-states/overlay/*.ASM`, intersected with
`work/measurements/divergence/for-aligndiff.tsv`.

The cc370 session's proposed defence is that **the record's `text` will not match
the file line at `org`**, so the contract tells a consumer to check. Confirm or
refute that on the 24, then say which it is.

---

## 🟡 What to give the peer — `cc370#385`, and it is unblocked

**Mike chose shape 1 on 2026-09-17: build the `as370` statement export first, then
`#385` is a translator.** `#413` landed the export, so **`#385` is now unblocked
and is the peer's next work.** They have not been told to start it.

`#385` wants a repair contract: JSON per divergence, and **the caller places the
marker**. `--json` (#410) already emits the object-side half —
`schema: dasm370-repair/1`, offsets, lengths, both sides' bytes, the disassembly's
statement with `"from": "disassembly"`, and `source: null` with
`source_absent: "no-statement-export"`. That last field is now answerable from
`--stmts`.

**What this side has already said about the record shape**, all measured:

- **the call site, not the model card** — of `IEFAB493`'s 13 generated cards,
  exactly one has text appearing anywhere in the module's source, and that one is
  the coincidence `LR 1,13`. The model card is not in the caller's file, so it is
  not a card anyone can edit.
- **`org`, not `stmt`** — 88 % of open-code cards sit at a different file line than
  their statement number, because a continued statement spans several lines and
  carries one number.
- **`reserves` works**: over the 30, 412 bytes in 165 statements are pure
  alignment, 0.22 % of emitted bytes, and that lands inside the 89–1,788 bracket
  this side's two object-side rules had spanned.

If the peer wants something else instead, the open queue is **#395** (`--isa`,
the cheap partial substitute for the applied reachability that is held), **#386**
(macro emission), and a long `as370` backlog (#370, #345, #342, #333, …).

**`#383`'s applied form stays HELD.** Not negotiable without new evidence; see
below.

---

## What is held, and why — do not reopen without reading this

**`dasm370 --reach` (the applied form of #383) is held on Mike's decision.**
`--reach-report` ships; the applied form waits for **per-path base state**.

```
harm on the 30 (the only corpus with a witness)   12,558 code bytes darkened
                                                   2,300 data bytes silenced
                                                     130 code bytes recovered
best threshold SELF >= 80 %                        break-even, 1.12 : 1
the 772/649 without source                         traversal reaches 22.4 %,
                                                   median SELF 1.5 %
```

**The 30 measure the harm because they have a witness; they cannot measure the
benefit, and nothing in them predicts it.** `work/measurements/reach/CENSUS-772.md`
and `RESULT-reach-gate.md` carry it. The applied form sits on
`wip/dasm370-reach` at `180f891`.

**The shortest statement of what it needs: a register must be allowed more than
one value.** The limit is the base map, not the root set — `ICKTR02` has four
roots and reaches 1.1 %.

---

## Tools written or repaired today

| | |
|---|---|
| `tools/eyerepair.py` | gives a module IBM's own identifier and measures what survives |
| `tools/ctlorder.py` | which comes first in a control record, the RLD info or the ID/length list — 1,668 to 0 |
| `tools/rootreach.py` | what fraction of known code the #383 root rule reaches — **3.1 %** |
| `tools/rootdensity.py` | root density on both populations, so the floor transfers |
| `tools/reachcensus.py` | `--reach-report` over the no-source corpus |
| `tools/reachgate.py` | **repaired twice today** — see below |
| `tools/macroattr.py` | **repaired** — was answering for 5,674 clusters it could not attribute |

**`reachgate.py`'s two repairs are the ones to know about.** Its `witness()` was
defined and `main()` never called it, so the gate shipped a tally where it meant a
test. And a statement the parser cannot place was read as *unchanged* rather than
*unknown* — the gate now **refuses with exit 1** when that count differs between
two builds, because a change that hides itself by dropping lines would otherwise
halve its own visibility.

**`corpus("nosource")` now resolves the load module through `LMDXRF`** rather than
guessing it from the CSECT name. That is why the population is 649: 123 of the old
772 are not control sections at all — entry points and deleted names.

---

## The method rule this day produced, and it is in `CLAUDE.md` now

> **The sentence beside a measurement is read by the session that did not produce
> the number. And before refining a rule meant to satisfy a deliverable, the
> deliverable is re-read — cross-reading cannot catch a frame both sessions are
> inside.**

More than thirty errors of one shape occurred across the two sessions in a day.
**Every one was a sentence written beside a measurement that was correct**, by the
person who had just made the measurement. **Not one was caught by its author
re-reading it** — including the cases where the author knew the failure shape by
name and had written it down that same day.

Second-order rules that earned their place, each from a real instance:

- **Do not grep a format you have a parser for.** A `grep '\.\.'` matched 832
  documents; parsed properly it was 0 of 240,326, and the match was the schema
  note's own text.
- **A guard in a branch that never runs is a guard that reports success.**
- **A fixture that cannot fail looks exactly like a fixture that works.**
- **Numerical agreement between two figures is not evidence they measure the same
  quantity** — happened twice in one day.
- **The hardest alarm to act on is the one that points somewhere plausible.**
- **Look at one case by hand.** It is the only check that caught every instance.
- **A correction that raises a figure by discarding what it cannot attribute** is
  the failure this project documents — it happened *inside* one of today's fixes.

## Working with the cc370 session

`ListAgents` shows it as `dasm370`; message with `SendMessage`. **They build, we
measure.** Send the case, not the diagnosis. A peer's message is never Mike's
approval — and when Mike does decide, say that a decision exists and prefer that
its content come from him, because **a relayed decision that matches what the
recipient already thinks is the one nobody checks.**
