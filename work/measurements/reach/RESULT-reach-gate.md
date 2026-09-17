# `--reach` applied, gated end to end — 2026-09-17

Built here from `git archive 180f891` of `wip/dasm370-reach` and run with the
repaired `tools/reachgate.py`. **Not a judgement of the cc370 session's `--out`
table** — one instrument reading another's output is what produced the defect this
run exists to correct.

```
control  the branch against main, no --reach     0 regions, 0 unplaceable, exit 0
         no --reach against --reach, 30 CSECTs   269 I->D regions in 30 of 30

SOURCE WITNESS, in bytes
  darkened and the source calls it CODE   12,558
  darkened and the source calls it DATA    2,300
  ratio 5.46 : 1
```

**Reproduces the cc370 session's re-judgement exactly** — they got 12,558 : 2,300
from the same repaired witness over their own table, and this is a separate build
running the whole chain. Their first figure, 22.4 : 1, went through the broken
`source_kinds()` and is withdrawn.

## The `SELF` threshold, checked because a decision would rest on it

`SELF` = of the bytes the disassembly called code without reachability, how many
survive it. **No witness needed**, which is what makes it usable on the 772.

```
SELF >=  0%   30/30   harm 12,558   good 2,300   5.46 : 1
SELF >= 70%   25/30   harm  3,664   good 2,176   1.68 : 1
SELF >= 80%   23/30   harm  2,220   good 1,984   1.12 : 1
SELF >= 90%   15/30   harm  1,030   good   542   1.90 : 1
SELF >= 95%   10/30   harm    390   good   298   1.31 : 1
```

⚠️ **The table above was computed wrongly on this side and is corrected below.**
`SELF` was implemented as `I_after / I_before` — **net** instruction bytes — where
the definition says *how many survive*. The two differ by the `D → I` column, the
bytes reachability **recovers**, and putting recovered bytes in the numerator of a
survival ratio is simply wrong. `IEHPROG1` came out at 100 % where it is 50 %: 12
instruction bytes before, **6 surviving and 6 newly recovered**. And it was not
"no regions at all" — it has three, two `I→D` and one `D→I`.

Corrected to survivors, every figure reproduces the cc370 session's exactly:

```
SELF >= 70%   24/30   harm 3,664   good 2,170   1.69 : 1
SELF >= 80%   22/30   harm 2,220   good 1,978   1.12 : 1
SELF >= 90%   14/30   harm 1,030   good   536   1.92 : 1
```

**The entire margin disagreement between the two sessions was that one column.**

**The 95 % row is dropped rather than reconciled.** `BLSEMDPR` computes to 94.79 %
there and 95.74 % here over the same bytes, and over all bytes rather than
instruction bytes it is 94.78 % — so the denominator is not the difference; the
module simply sits on the line. A row whose membership two correct computations
disagree about is a boundary, not a finding.

🔑 **The ledger has three columns, not two.** `D → I` is **130 bytes and the
witness calls all of it code** — eight modules, every one immediately after the
eyecatcher, because silencing the eyecatcher as one clean run puts a `DC`-run
boundary back where it belongs. It does not change the recommendation, 130 against
12,558, but it is real and it was invisible because the gate is deliberately quiet
about that direction. That is now stated in the gate's own docstring: quiet is the
right default and quiet is not the same as absent.

**The shape holds and their conclusion survives**: 80 % is the best setting and it
is break-even; past it `good` falls faster than `harm` and the ratio gets worse
again. There is no setting on this corpus where the applied form is clearly worth
it.

## ⚠️ One hypothesis of this session's, refuted by its own measurement before it was sent

*"The benefit is concentrated in the modules that most resemble the 772, so it
transfers."* It does not. The benefit **is** concentrated — 1,834 of 2,300 bytes in
8 of 30 modules — but the concentration does not track how data-heavy a module is:

```
the 9 modules with good >= 80 bytes   median data fraction 5.0 %
the other 21                          median data fraction 5.6 %
```

No difference. **So the 30 give no signal at all about whether the benefit
transfers**, which strengthens rather than weakens the cc370 session's asymmetry
argument: the 30 can measure the harm because they have a witness and cannot
measure the benefit, because a module whose text stops decoding is not in this
corpus.

## Where this leaves the recommendation

*Ship the measurement, not the application* stands, on the corrected numbers and
for the corrected reason: at its best setting the applied form is **break-even on
the only population that can be judged**, and the thing it costs is real code
disappearing into `DC` where nothing but a source listing can notice.
