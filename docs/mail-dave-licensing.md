# Message to Dave Kreiss — the licensing question

**Status: sent on 2026-09-04.** Kept here as a record; the reply is outstanding.

To: `davekreiss@gmail.com`
Subject: `Publishing your MVS 3.8j source recovery work`

---

## What this is about

Mike asked Dave on **2021-05-27** whether his sources were for private use only
or could be published on GitHub (`mainframed/mvs38_sources` or `mvslovers`). The
reply of the same day did not address it, and the question stayed open — blocking
any publication.

The draft deliberately separates three things that are easily conflated:

1. **The IBM MVS source itself.** Not Dave's to license and not his call.
   MVS 3.8j is regarded in the community as freely distributable; his permission
   is not needed for it.
2. **Dave's own work.** His PTFs, his reconstructed and disassembled modules, the
   build jobstreams, the documentation. That is his, and that is the subject.
3. **Dave's utilities.** `COMPLMD`, `MACCVT`, `LMDXRF38`, `LMDRPT38` and the
   rest. There is a wrinkle here: per his own documentation, `LOADLMD` and
   `MAPLMD` derive from the disassembler on **CBT tape file 217** (original
   author R. Thornton). Any publication inherits that provenance, which is why
   the draft asks about it explicitly.

The draft also asks how he would like to be credited, and whether he has made
progress on the SMPWRK3 problem. The latter costs one line and could save weeks.

---

## The draft

```text
Subject: Publishing your MVS 3.8j source recovery work

Hi Dave,

I hope you're doing well.

I'm picking up the MVS-from-source work again, and this time with a different
setup. We now have a host-native toolchain for MVS 3.8j — an Assembler-XF clone
that produces object decks byte-identical to IFOX00, a linkage editor, and load
module tooling, all running on macOS. That means the assemble / compare loop you
used to run through SMP can run locally in seconds instead of minutes, and SMP
only has to apply the finished PTFs at the end. I'm also building a
disassembler to close the loop for modules where no source exists.

The target system will be MVS/CE rather than TK3, so a fair amount of
re-baselining is ahead of me, but your build documentation and your sources are
the foundation for all of it.

Before any of this goes anywhere public, I want to settle a question I asked you
back in May 2021 and never got a clear answer to — entirely my fault for burying
it in a longer mail.

May we publish your work?

Concretely, I'd like to put the recovered sources, your PTFs and the build
documentation into a git repository under github.com/mvslovers, with clear
attribution to you as the author of the recovery work. Right now everything sits
in a private archive, and I'd rather not publish anything without your explicit
agreement.

Three specific questions:

1. Your recovery work — the reconstructed and disassembled modules, the DSK*
   PTFs, the build jobstreams, the instructions document. Is it OK to publish
   those, and if so, under what terms? If you'd like a particular license
   applied, tell me which and I'll use it. If you'd prefer your own copyright
   notice kept on every file, that's easy to do too.

2. Your utilities — COMPLMD, MACCVT, LMDXRF38, LMDRPT38, MVSASM38 and the
   others. Same question. One detail I want to flag rather than gloss over: your
   documentation says LOADLMD and MAPLMD are derived from the disassembler on
   CBT tape file 217, original author R. Thornton. If you know anything about
   the terms that code came under, I'd like to hear it — otherwise I'll treat
   those two more cautiously than the rest.

3. How would you like to be credited? Name only, name and email, or something
   else? I'll follow whatever you prefer.

To be clear about what I'm *not* asking: the IBM MVS 3.8j source itself isn't
yours to license and I'm not treating it as such. This is only about the work
you did on top of it.

If the answer is no, or "not yet", that's a perfectly fine answer and the
material stays private — I'd just like to know where I stand.

One last thing, unrelated: have you made any progress on the SMPWRK3 directory
reset since 2022? We're planning to dig into the SMP source to find out how that
directory can get cleared mid-APPLY. If you have any notes, traces or half-formed
hunches lying around, they'd save me a lot of time. If not, no problem — I'll
send you what I find either way.

Thanks for everything, and best regards from Germany,
Mike
```

---

## Notes on the draft

- **Tone.** The 2021 question went unanswered; the draft explicitly does not put
  that on Dave ("entirely my fault for burying it"). That makes it easy for him
  to answer now.
- **A clear "no" is allowed.** The paragraph beginning "If the answer is no, or
  'not yet'" is deliberate. Without it there is pressure, and pressure on a
  question like this tends to produce no answer rather than an honest one.
- **CBT tape 217 raised openly.** We point out the third-party provenance
  ourselves rather than glossing over it. That is both correct and more credible.
- **The update on the new toolchain comes first**, because it shows his work is
  being carried on — probably the most interesting news in the message for him.
- **SMPWRK3 last and explicitly as a side note.** We are not asking him to solve
  the problem, only for any notes he has. The offer to send him our findings is
  meant seriously and should be honoured.

## If no answer comes

Dave did not reply in 2021 and was very brief in 2022 and 2024. A realistic plan
does not depend on his answer:

- The repository stays private. The work continues regardless — the licensing
  question blocks publication, not recovery.
- Follow up once after about four weeks, then let it rest.
- Whatever consists of IBM source and of our own work is unaffected by the
  question anyway and could be published separately.
