# `--reach-report` over the 772 that have no source — 2026-09-17

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

**And 124 that cannot be read at all** is the number to chase before any of this:
16 % of the population is not a reachability question.
