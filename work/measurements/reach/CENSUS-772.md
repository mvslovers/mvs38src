# `--reach-report` over the CSECTs that have no source — 2026-09-17

> ✅ **Corpus repaired the same day, and the population is 649, not 772.**
> `reachgate.corpus("nosource")` now resolves the load module through Dave Kreiss'
> `LMDXRF` cross-reference instead of guessing it from the CSECT name. **649 of
> 772 resolve, and all 649 are readable — zero refusals**, against 124 before.
> **The other 123 are not in the cross-reference at all**, 0 of 123, so they are
> not control sections: they are entry points and deleted names that this corpus
> listed as CSECTs. The no-source CSECT population is **649**.
>
> **The figure barely moves: 22.2 % → 22.4 %, median `SELF` 1.5 % either way.**
> That is the right outcome — the repair fixed the attribution, not the finding.
> The sections below are kept as they were written, with their corrections, because
> the sequence of errors is the more useful record.

`cc370#406` shipped the traversal as a measurement and held the applied form, on
evidence from the **30 control CSECTs**. Those are the modules that HAVE source,
which is why they can be judged — and they are not the population `#383` exists
for. This is the first run on the 772.

Scored on the only denominator that needs no witness, the one the man page names
as actionable: **of the bytes the disassembly called code without reachability,
how many does the traversal reach** (`SELF`).

## The result, and it inverts the 30

```
772 inputs, 598 measured
    124  dasm370 cannot read the section at all
     50  zero code bytes without reachability -- already all DC

SELF >= 95 %     80 modules     44,209 code bytes
SELF 90-95 %     23 modules     22,651
SELF 70-90 %     44 modules     34,605
SELF 30-70 %     47 modules     77,039
SELF <  30 %    404 modules    488,401

total reached   148,369 of 666,905 code bytes = 22.2 %
median SELF per module                        =  1.5 %
```

**The 30 give a median of 94 % and the 772 give 1.5 %.** Two thirds of the
measured modules — 404 of 598 — are below 30 %, and they hold 73 % of the code
bytes. **The traversal does not work on the population it was written for.**

## The control that makes that a population effect and not a form effect

The 30 were measured **deck-side** and the 772 are **bound members**, and a member
carries no entry point — measured earlier, four of the 30 have a root only from the
`END` card. So the 30 were re-run member-side:

```
the 30, deck            79.5 % reached   median 94.1 %   3 below 30 %
the 30, member (DLIB)   77.7 % reached   median 91.8 %   3 below 30 %
```

**The form is worth about two points.** The gap to the 772 is the population.

## What it means

**It vindicates holding the applied form far more strongly than the 30 did.** On
the 30 the applied form was break-even at its best threshold; here the traversal
reaches 22 % of the code, so applying it would darken roughly four fifths of what
the disassembly currently decodes — on the modules that have no source to notice
with.

**And as triage it is real but small.** 103 of 772 reach 90 % or better, so
`--reach-report` identifies **about one module in seven** that a
reachability-filtered disassembly could be trusted for. That is worth having and
it is not what this corpus hoped for.

**The 50 that already decode as nothing but `DC` are their own finding** and were
not being counted anywhere: sections `dasm370` emits with no instruction at all.
Whether they are pure data or a reader limit is not answered here.

⚠️ **The "124 `dasm370` cannot read" is OURS, not the tool's, and the first report
of it said the opposite.** It was sent to the cc370 session as *"124 it cannot read
at all — a larger hole than reachability was ever going to fill"*, and they were
about to open an issue on it. Measured instead of asserted:

**Not a `dasm370` defect — every refusal is `rc=2` "no section named X" and none
of the 124 names a section.** But the sentence written next, *"our corpus points
at the wrong member"*, was wrong for 122 of them, and correcting it needed a
defect fixed in this side's own CESD reader first.

⚠️ **The name appears TWICE in these CESDs** — once as `LR` (`X'03'`) and once as
a `NULL` tombstone (`X'07'`) — and the reader here was a dict keyed by name, so
the last entry won and every one came back `NULL`. 119 `NULL` / 3 `LR` against the
cc370 session's 91 / 31, from the same 124 members: **a duplicate silently
dropped, which is the "last wins" shape again.** Counting every occurrence:

```
124 refusals, by what the name IS in that member's CESD
   93  an ENTRY POINT (LR), sometimes plus its own tombstone
       -- and all 93 have a section in that same member
   29  a NULL / deleted entry only
    2  not in the CESD at all
    0  a section (SD/PC/CM)
```

`AHLDMPMD` is an **entry** in `AHLDMPMD.bin`; the section there is `AHLWTO`.
`AHLTDSP` is an entry in `AHLTDSP.bin`; the section is `AHLTPID`. **So the member
is the right member.** The name is in it, as an entry point, and the section that
owns it is called something else — a structural fact about the bound module, not
a lookup that missed. Only the **2** are genuine misses.

(The cc370 session counts 91/31 where this reads 93/29; the two differ on names
carrying both types in different records, and nothing rests on it.)

**What the 93 mean is open and neither side has answered it**: whether they are
real CSECTs merged into other sections at link time, or corpus rows that name
entry points. The repair is the same either way and `baseline_gate.py` already
does it — resolve through Dave Kreiss' `LMDXRF` cross-reference, one record per
(library, LMOD, CSECT, length), which reaches the owning section from either.

**And there is a `dasm370` defect after all, found from the other side**: the tool
walks the CESD and stores every `LR` before concluding there is no section, so
when it says *"no section named AHLDMPMD"* it already knows the name is an entry
owned by `AHLWTO` and says none of it. The refusal asserts less than the tool
knows, and that is what sent this side looking for a wrong member.

It changes nothing about the 22.2 % — that is computed over the 598 that were
measured — and it changes entirely who has the defect.

---

## The 50 that emit no instruction, and what #383 is actually left with

The cc370 session measured their side: **50 of 50 are `DC` only, every byte covered
by `TXT`, no `DS`, no holes** — and, checking their own claim before it was asked
for, **50 of 50 also reach zero bytes from the `SD` root**, so the first byte does
not decode and the `DC` chunking is not hiding instructions further in.

They asked whether any of the 50 has source. **None does, and that is by
construction** — these are drawn from the no-source corpus. So the question cannot
separate "data" from "a decoder finding" from either side, and this is what our
corpus can contribute instead:

```
                       n     median text_frac   median length
the 50                50           0.06              206
the other 722        722           0.17              727
```

Shorter and less text-like than the population. Sixteen of the 50 are
`IECVOPTA`…`IECVOPTU`, a lettered family of option tables; `IEAMSPSA` is 1,360
bytes at `text_frac` **0.00**, `IEFJESCT` is 80 bytes — a PSA and a JES
communication table, both in `NUCLEUS(IEANUC01)`. Those read as data, and the
reading is ours rather than a measurement.

🔑 **But two of the 50 are the opposite, and one of them is `#383`'s own named
case.** `IKJEFLE2` and `IKJEFLE4` have `text_frac` **1.00** — and the issue's
original acceptance names `IKJEFLE4` as the sharp one, *"21 bytes at 100 % — an
opcode gate cannot save it: text decodes as `L`/`LA`/`ST`/`BC`, which are in every
subset. Only reachability can say nothing branches here."*

**It is already entirely `DC` today, with no reachability at all.** Not because
anything branches or does not, but because the decoder finds nothing at its first
byte. So over the 72 sections above 60 % printable that `#383` was written for:

```
 4  already fully DC today          IKJEFD22  IKJEFD3A  IKJEFLE2  IKJEFLE4
 3  entry-point cases dasm370 refuses
65  still decode instructions       ISTCFCM1 7,988 code bytes, PDE00000 5,192,
                                    TSMSGS 1,862, USERLAB 1,136, MESSLIST 1,126 …
```

**65 of 72 is what the issue is actually for**, and the one case it argued from is
not among them.

**Confirmed from the cc370 side to the byte**, and the four are the same four:

```
IKJEFLE4      17 bytes accounted,      0 decode as instructions
ISTCFCM1   26,565 bytes accounted,  7,988 decode as INSTRUCTIONS
```

⚠️ **And it is more than a stale example, which is why it was handed back rather
than edited here.** `#383`'s sentence is *"an opcode gate cannot save
`IKJEFLE4`"* — an argument **against `--isa`**, which is `cc370#395` and next in
the queue. It is now an argument about a module that **needs no saving**, so
`#395` would have inherited a dismissal with nothing behind it. The issue carries
a comment with the superseded sentence quoted in full, so a reader meets the old
argument and its replacement together instead of finding a silently edited issue.
