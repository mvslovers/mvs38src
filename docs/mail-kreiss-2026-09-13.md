# Mailentwurf an Dave Kreiss — 2026-09-13, **nicht gesendet**

> Sendefertig. Der Text unter dem Trennstrich ist die Vorlage — er steht so, wie er
> abgeschickt werden kann; darüber steht nur, warum er so steht.

> Wartet auf Mikes Wort. Zwei echte Fragen darin, und beide kann nur Dave
> beantworten: was `./ DELETE` erwartet, und ob seine Makro-Bibliotheken das
> `ESTAE` tragen, das keine unserer drei Kopien hat.

Der Anlass ist nicht Höflichkeit, sondern Arbeit, die ohne ihn stehenbleibt:

- **Ein Makro-Stand fehlt in allen drei Bibliotheken**, auch in TK5s eigener
  ([`missing-macros.md`](missing-macros.md)). Sein angebotenes Zip löst das und
  sonst nichts. **Korrigiert:** der erste Entwurf schrieb „175 Module" — das war
  eine Verallgemeinerung aus *einem* Fall, und `seclocate.py` hat sie widerlegt
  (2 von 21 lokalisierten Einfügungen). Die Mail sagt die Zahl jetzt selbst
  richtig, samt der Korrektur, weil Dave beurteilen kann, was das wert ist.
- **`MAINT05Z` war richtig, und danach ist die Quellbibliothek beschädigt.** Die
  Objektseite ist einwandfrei. Das ist seine SMP, und die Quellseitenverwaltung
  ist genau die Funktion, die er hinzugefügt hat.
- **`where.py --base tgt` ist das Werkzeug, nach dem er gefragt hat**, und er weiß
  nicht, dass es existiert.

Kein Drängen beim Zip: er hat es von sich aus angeboten. Der Absatz nennt, was es
öffnet, und lässt es dabei.

---

**Subject:** Build MVS from Source — MAINT05Z was the missing step, and one macro we cannot find

Hi Dave,

you were right about `MAINT05Z`, and the difference is not subtle.

We had skipped it to avoid writing to a running system. Following your note, we
took a full backup of the build machine — 32 volumes, checksummed — ran
`MAINT05Z`, and then the chain behind it. It went all the way: **82 jobs,
`MAINT06@` through `MAINT15G`, across all four JCL libraries, ending exactly where
your own chain ends.** 34 jobs `CC 0000`, 23 `CC 0004`, 25 `CC 0008`, **no ABEND
and no `CC 0012` anywhere.** The run before it, on the stock SMP, died on the
first job.

And the `./ DELETE` question answers itself:

| `HMA3462 INVALID IEBUPDTE CONTROL STATEMENT` | |
|---|---:|
| previous run, stock SMP, five jobs | **675,382** lines |
| this run, your SMP | **0** |

`MAINT06@` alone accounted for 487,641 of them. So it was never a fact about
`./ DELETE` — it was a fact about which SMP was asked, exactly as you said.

## One thing came out of it that I think you will want to know

The **object** side of that run is clean. The **source** side is not, and I do not
understand it well enough to say why.

After the chain, `MVSSRC.BLD.AMVSSRC` has **384 members that cannot be read at
all** — not by mvsMF, not by FTP, and not by MVS itself:

```
IEB351I I/O ERROR ,RDTEST ,S1 ,196,DA,SYSUT1 ,READ ,NO RECORD FOUND,
        000000AF000C04,BSAM
```

All 384 were readable before the chain, with content. `IEHLIST LISTVTOC` says the
volume has 1,017 free cylinders, so it is not space.

And **69 more members lost their beginning.** `AHLCWRIT` went from 12,372 lines to
2,600 and now starts in the middle of an instruction — its `TITLE`, `CSECT` and
`USING` are gone. The cut falls exactly at sequence number `097730`, a line
boundary rather than a block boundary, which is why I mention it: that looks like a
line-range delete with a base it did not expect, rather than a media fault. Two
independent readers give the same 2,600 lines, so the member really is like that on
the volume.

I am not asking you to debug our system — the backup means nothing is lost, and we
can re-run. But if `./ DELETE` has an expectation about sequence numbering or about
the state of the source library going in, that would explain it, and you are the
only person who knows.

## The macro we cannot find, and what your zip would settle

You offered to *"create a zip file of all the resulting source (including all
assembler code and macro libraries)"*. Here is the single largest thing it would
close.

There is a macro we cannot find, and I want to be careful about how big I claim it
is — my first estimate was far too large and I corrected it before writing this.
`IDAVBPJ1` at offset `0x00A6`:

```
ours   1F00           0A3C          SLR 0,0            ; SVC 60
IBM    D702 100D 100D 1B00 0A3C     XC 13(3,1),13(1) ; SR 0,0 ; SVC 60
```

That is inside an `ESTAE PURGE=QUIESCE,PARAM=COMMAR,MF=(E,ESTALST)` expansion. The
module's own `XC ESTALST(16),ESTALST` is there and correct — the eight bytes are in
the macro.

And the macro is the same version everywhere we can look: MVS/CE's distribution
`AMACLIB`, MVS/CE's target macro library, and **TK5's own `SYS1.AMACLIB(ESTAE)`**
are byte-identical apart from one trailing blank line, and all three emit `SLR 0,0`
with no `XC`. So the `ESTAE` that assembled the shipped object is in none of them.

How many modules that accounts for, honestly: 189 modules in the corpus are exactly
eight bytes shorter than IBM's object, and I assumed they were all this. They are
not. Aligning our text against the shipped text module by module, twenty-one of the
first thirty I could align showed a distinct missing run, and only two of them were
this `ESTAE` sequence. Eight bytes is just a common amount of missing code. So the
`ESTAE` level is worth some modules rather than a hundred and seventy-five — but it
is certainly missing from every library we can reach, including TK5's own, and it is
the kind of thing only your macro libraries can settle.

## And the tool you said you needed

You wrote that what would help is not a faster loop but something that says *what
changed* between the disassembly and the assembled version. We have that, and I
should have mentioned it sooner.

`where.py` takes a module, assembles it, compares the object against the shipped
one, and prints **every differing byte with the source statement that owns it** —
resolving the section base out of the assembly listing, because the comparator's
offsets are section-relative and the listing's are absolute. `--base tgt` compares
against the **target** library, on your advice.

```
IKJEFT07  (LPALIB(IKJEFT07), tgt)
  IKJEFT07   base=0x000000  text=5 holes=0
     0x000f (abs 0x00000f)  2B text  ours=f7f8   IBM=f8f5
        stmt at 0x00000f |         DC    C'IKJEFT07  78.177'|
```

Two bytes and one statement: the eyecatcher date. `78.177` should be `85.049`, and
the module then matches IBM's object exactly. Four of the first six TSO modules we
worked this way turned out to be that kind of thing — a date, a message number, a
branch condition, two table constants — not the hand-disassembly you have been
doing.

It runs on the Mac, needs no MVS, and takes about a second per module. If it would
be useful to you, say the word and I will send it with whatever it needs.

## Where the numbers are

**1,491 of 5,353 modules now assemble byte-identical to TK5's object** — measured
against the target libraries, as you advised, with the distribution libraries where
a CSECT has no target counterpart. That was 1,277 this morning. None of the gain
came from guessing: the method is to sort the whole tree by how far each module is
from the object and look at the nearest, which is how the `ESTAE` case surfaced at
all.

Thanks for the `MAINT05Z` note. It was one line in your mail and it moved the
whole chain.

Best regards,
Mike
