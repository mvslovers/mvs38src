# Draft: mail to Dave Kreiss, 2026-09-12

Status report plus one real question (`./ DELETE` on RECEIVE). The tape is
mentioned in a subordinate clause on purpose — he has already said he intends to
cut one, and asking again would only add pressure to something he is doing
anyway.

---

**Subject:** Build MVS from Source — where we are, and one SMP question

Hi Dave,

a status report, and one question I think only you can answer.

Since we last wrote, your build runs end to end on a TK5 system — 260 jobs to
the phase-1 boundary, with your own `ZLMDRPTD` and `ZLMDRPTT` at the end of it.
We also built a second, independent path: a cross-assembler (`as370`) that runs
on a Mac, so the whole tree can be assembled and compared against the
distribution libraries without MVS in the loop. MVS is still the oracle —
every claim about what the assembler *should* do is checked against the real
IFOX00 rather than against a reading of the manual.

That gives two numbers, and they answer different questions:

* **`as370` reproduces IFOX00's object deck for 5,427 of 5,528 modules.** That
  is a statement about our tool, not about the source.
* **The build's CSECT is byte-identical to the one IBM shipped for 1,422 of
  5,485.** That is the real one.

Broken down the way you described it yourself:

| target library | CSECTs built | identical to IBM's | |
|---|---:|---:|---:|
| `SYS1.LPALIB` | 2,343 | 290 | 12.4 % |
| `SYS1.LINKLIB` | 1,721 | 468 | 27.2 % |
| `SYS1.CMDLIB` | 753 | 229 | 30.4 % |
| `SYS1.NUCLEUS` | 354 | 334 | 94.4 % |
| `SYS1.TELCMLIB` | 192 | 32 | 16.7 % |
| `SYS1.VTAMLIB` | 63 | 10 | 15.9 % |
| `SYS1.SVCLIB` | 59 | 59 | 100.0 % |
| **total** | **5,485** | **1,422** | **25.9 %** |

**Your account of what was finished is confirmed exactly.** `SVCLIB` is
complete, `NUCLEUS` is at 94 %, and the two you named as outstanding hold 4,064
of the 5,485 CSECTs — which is what "a lot of modules" turns out to mean when
you count them. We measured the same thing a second time from the other side,
on the host against the distribution libraries, and got 27.3 %; different
program, different population, same answer.

## The question

Running your chain past `MAINT05F` — the `MAINT06@`…`MAINT15G` sequence in
`SMP.JCL1` through `JCL5` — the RECEIVE of `MAINT06@` rejects 485 of your
SYSMODs:

```
./ DELETE SEQ1=00151902,SEQ2=00151902
HMA3462 ** INVALID IEBUPDTE CONTROL STATEMENT
```

and then every APPLY that selects one of them fails with `HMA4012 ... NOT FOUND
ON SMPPTS LIBRARY`.

We put it to the system as a controlled case: two SYSMODs in one RECEIVE,
identical line for line except that one carries a single `./ DELETE`. The one
without it is received; the one with it is not. So the SMP on this system takes
`./ CHANGE` and refuses `./ DELETE`, and one such statement costs the whole
SYSMOD.

That affects the `DSK5xxx`/`DSK6xxx` families in particular — the
"remove commented-out code" phase, where deleting lines by sequence number is
exactly the natural thing to write.

**Does this match what you saw?** We are running on TK5 with its own SMP, and
the obvious possibilities are that you ran a different SMP level, or that there
is a step we have not found that rewrites those updates, or that your runs lost
these SYSMODs too and it never showed because the affected modules were not ones
you were checking. Any of those would help; so would "no idea, it always worked
here", because that would tell us to look at our system rather than at your
PTFs.

For what it is worth, where a SYSMOD *does* arrive, your repairs land and they
reach IBM's object: applying what did get through moved 13 modules to
byte-identical and lost none.

## Small things

* The two jobs at the head of the chain that end non-zero — `$02ASM` (`CC 0024`,
  `PRTTRK` referencing `DS4DEVCY`/`DS4DEVTR`, which MVS 3.8's `IECSDSL1` does not
  define) and `$08STG1A` (`CC 0020`, a `SYSLIB` concatenation with `AMODGEN`'s
  19,040 ahead of `MACLIB`'s 27,920) — are both harmless as far as we can tell,
  and `ZSTAGE2` repairs the second one nine jobs later. We left them alone.
* On space: `$01SMPAL` gives `MVSSRC`, `AMVSSRC`, `ASMPRINT` and `SMPACDS` no
  secondary quantity, which on a 3390-1-sized primary is unavoidable. Supplying
  `S=50` at submit time was enough. Separately, `MVSSRC.BLD.SMPOUT` reached the
  16-extent limit and had to be re-allocated in one piece.

And whenever you get round to the rebuilt install tape — no hurry at all — we
would happily re-run all of this against it and send you the same table for the
new state; the whole chain is automated now, so it costs us an afternoon rather
than a project.

Thank you again for releasing the work. Everything we publish credits you by
name and email, as you asked.

Best regards,
Mike
