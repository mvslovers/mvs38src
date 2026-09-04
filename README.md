# mvs38src — MVS 3.8j aus Source

Wiederherstellung des MVS-3.8j-Quellcodes auf **DLIB-Stand**, mit dem Ziel,
MVS/CE künftig aus diesem Source zu bauen.

> **Privat**, solange die Lizenzfrage mit Dave Kreiss nicht beantwortet ist.
> Siehe [`docs/mail-dave-lizenzfrage.md`](docs/mail-dave-lizenzfrage.md).

## Das Ziel in zwei Stufen

1. **Ein Source-Baum auf DLIB-Stand von MVS 3.8j** — distributionsunabhängig,
   also nicht „Source für unser MVS/CE", sondern Source für MVS 3.8j. Das ist der
   Stamm; alles Weitere — BREXX-Integration, 3390-Erweiterungen, was auch immer —
   ist eine Entwicklung, die von dort abzweigt.
2. **MVS/CE künftig aus diesem Source bauen.** Die Nahtstelle steht in
   `sysgen.py` des MVS-sysgen-Projekts: `step_03_build_dlibs` erzeugt die DLIBs
   aus dem IBM-Band `zdlib1.het`, alles danach leitet sich daraus ab. Kommt der
   DLIB-Inhalt aus unserem Source, baut der Rest der Kette unverändert weiter.

## Warum das überhaupt Arbeit ist

Der von IBM ausgelieferte Source passt nicht zum ausgelieferten Objektcode. Das
Objekt trägt Wartungsstände, die den Quelltext nie erreicht haben. Diese Lücke zu
schließen ist die Aufgabe.

Der Erfolgsmaßstab ist objektiv: **Der assemblierte CSECT ist byte-identisch zum
DLIB-Objektdeck, oder er ist es nicht.** Genau das macht die Arbeit
automatisierbar.

## Arbeitsweise

Die Wiederherstellung läuft **auf dem Host**; MVS ist nur Orakel und
Laufzeitumgebung. Assembliert wird mit `as370` aus
[cc370](https://github.com/mvslovers/cc370), verglichen mit `cmplmd370`
(zu bauen). Ein Agent arbeitet eine Modulliste ab; SMP kommt erst am Ende der
Kette zum Einsatz.

## Wo was liegt

| Verzeichnis | Inhalt |
|---|---|
| `docs/` | Plan, Runbook, Analyse von Dave Kreiss' Projekt, Mailentwürfe |
| `baseline/` | MVS/CE-Baseline: Inventare, Prüfsummen, DLIB-Vergleiche |
| `src/` | der wiederhergestellte Source, nach Zielbibliothek |
| `tables/` | generierte Tabellen: portiert / fehlend |
| `tools/` | Pipeline und Orchestrator |
| `work/` | Arbeitsschlange und Zustand des Agenten |
| `evidence/` | Beweiskette je Modul: Diffs, Iterationsverlauf, Berichte |
| `ptf/` | SMP-Verpackung: `++PTF`/`++USERMOD`, JCLIN |

**Rohmaterial liegt nicht hier**, sondern in `~/repos/MVSSRC`: Dave Kreiss'
Installationspaket und sein Arbeitsstand (`MVSBLD/`, 5.529 Module), der
Mailverkehr als PDF, die TSO-Sourcen und zwei Web-Spiegel.

## Einstieg

1. [`TODO.md`](TODO.md) — was als Nächstes zu tun ist
2. [`docs/arbeitsplan.de.md`](docs/arbeitsplan.de.md) — warum und wohin
   ([englisch](docs/arbeitsplan.en.md))
3. [`docs/kreiss-projekt.de.md`](docs/kreiss-projekt.de.md) — worauf wir aufsetzen
   ([englisch](docs/kreiss-projekt.en.md))
4. [`docs/runbook.md`](docs/runbook.md) — wie die Dinge praktisch funktionieren
