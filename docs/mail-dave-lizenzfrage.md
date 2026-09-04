# Mailentwurf an Dave Kreiss — Lizenz- und Veröffentlichungsfrage

**Status: Entwurf. Nicht versendet.** Bitte durchlesen, anpassen, dann selbst
abschicken.

An: `davekreiss@gmail.com`
Betreff: `Publishing your MVS 3.8j source recovery work`

---

## Worum es geht

Du hast Dave am **27.05.2021** gefragt, ob seine Sourcen nur privat genutzt
werden dürfen oder auf GitHub gestellt werden können (`mainframed/mvs38_sources`
bzw. `mvslovers`). Er ist in seiner Antwort desselben Tages nicht darauf
eingegangen — die Frage ist bis heute offen und blockiert jede Veröffentlichung.

Der Entwurf trennt bewusst drei Dinge, die oft vermischt werden:

1. **Der IBM-MVS-Source selbst.** Nicht Daves Sache und nicht seine
   Entscheidung. MVS 3.8j gilt in der Community als frei verteilbar; dafür
   brauchen wir seine Erlaubnis nicht.
2. **Daves eigene Arbeit.** Seine PTFs, seine rekonstruierten und
   disassemblierten Module, die Build-Jobstreams, die Dokumentation. Das ist
   sein Werk, und darum geht es.
3. **Daves Werkzeuge.** `COMPLMD`, `MACCVT`, `LMDXRF38`, `LMDRPT38` und die
   anderen. Hier gibt es eine Besonderheit: `LOADLMD` und `MAPLMD` sind laut
   seiner eigenen Dokumentation abgeleitet vom Disassembler auf **CBT-Tape
   File 217** (ursprünglicher Autor R. Thornton). Diese Herkunft erbt jede
   Veröffentlichung mit — deshalb fragt der Entwurf ausdrücklich danach.

Zusätzlich fragt der Entwurf, wie er genannt werden möchte, und ob er beim
SMPWRK3-Problem inzwischen weitergekommen ist. Letzteres kostet eine Zeile und
kann uns Wochen sparen.

---

## Der Entwurf

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

## Anmerkungen zum Entwurf

- **Tonfall.** Die Frage von 2021 ist unbeantwortet geblieben; der Entwurf
  schiebt das ausdrücklich nicht Dave zu („entirely my fault for burying it").
  Das macht es ihm leicht, jetzt zu antworten.
- **Ein klares Nein ist erlaubt.** Der Absatz „If the answer is no, or ‚not
  yet'" steht bewusst drin. Ohne ihn entsteht Druck, und Druck erzeugt bei
  dieser Art Frage eher gar keine Antwort als eine ehrliche.
- **CBT-Tape 217 offen angesprochen.** Wir weisen selbst auf die fremde Herkunft
  hin, statt sie zu übergehen. Das ist sowohl korrekt als auch glaubwürdiger.
- **Das Update über die neue Werkzeugkette** steht vorne, weil es zeigt, dass
  seine Arbeit weitergeht — das ist für ihn vermutlich die interessanteste
  Nachricht in der Mail.
- **SMPWRK3 zum Schluss und ausdrücklich als Nebenthema.** Wir bitten ihn nicht,
  das Problem zu lösen, sondern nur um vorhandene Notizen. Das Angebot, ihm
  unsere Erkenntnisse zu schicken, ist ernst gemeint und sollte eingehalten
  werden.

## Wenn keine Antwort kommt

Dave hat 2021 nicht geantwortet und war 2022 und 2024 jeweils sehr knapp. Ein
realistischer Plan kommt ohne seine Antwort aus:

- Das Repo bleibt privat. Die Arbeit geht trotzdem weiter — die Lizenzfrage
  blockiert nur die Veröffentlichung, nicht die Wiederherstellung.
- Nach etwa vier Wochen einmal freundlich nachfassen, danach nicht mehr.
- Was aus dem IBM-Source und aus unserer eigenen Arbeit besteht, ist von der
  Frage ohnehin nicht betroffen und könnte separat veröffentlicht werden.
