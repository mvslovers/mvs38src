# CLAUDE.md — mvs38src

Wiederherstellung des MVS-3.8j-Source auf DLIB-Stand. Ziel und Aufbau stehen im
[README](README.md); was als Nächstes ansteht, in [`TODO.md`](TODO.md).

**Vor inhaltlicher Arbeit lesen:** [`docs/arbeitsplan.de.md`](docs/arbeitsplan.de.md).
Für alles, was ein laufendes MVS berührt: [`docs/runbook.md`](docs/runbook.md).

## Die eine Regel, die alles trägt

**Erfolg wird nicht behauptet, sondern gemessen.** Ein Modul gilt genau dann als
wiederhergestellt, wenn `cmplmd370` mit Exit-Code 0 endet — der assemblierte
CSECT ist byte-identisch zum DLIB-Objektdeck. Kein Ermessen, keine Einschätzung,
keine Formulierung wie „sollte jetzt passen".

Daraus folgt: **niemals ein Verdikt setzen, das nicht aus einem Werkzeuglauf
stammt.**

## Umgang mit dem Source

**Fixed-Format-Assembler, 80 Spalten.** Sätze von exakt 80 Zeichen,
Sequenznummern in Spalte 73–80, CRLF-Zeilenenden.

- **Niemals umformatieren.** Keine Zeilen kürzen, kein Whitespace „aufräumen",
  keine Zeilenenden konvertieren. Spalte 72 ist die Fortsetzungsspalte.
- `.gitattributes` erzwingt das (`* -text`, `*.asm binary`). Nicht lockern —
  genau diese Bytes sind der Vergleichsgegenstand.
- Änderungen werden markiert wie bei Dave: Spalte 1 `*DSKnnnn` oder Spalte 65
  `DSKnnnn`.

**Zwei Markierungen bedeuten „Hände weg":**

- `???` — Dave konnte nicht rekonstruieren, was der Code tut (50 Module)
- `!!!` — Kunstgriff, damit der Objektvergleich aufgeht (16 Module)

Dort wird nicht aufgeräumt, nicht modernisiert, nichts „offensichtlich
Besseres" eingesetzt.

## Reihenfolge, die nicht verhandelbar ist

1. **Byte-Identität herstellen.** Erst danach, in getrennten Commits, optional
   lesbarer machen. Zwei bewegliche Ziele gleichzeitig kosten die
   Vergleichbarkeit — das war Dave Kreiss' Phase 2.
2. **Vor der ersten eigenen Änderung einfrieren.** Git-Tag auf den
   `IDENTISCH`-Stand plus die zugehörigen Objekte als Referenz. Danach gilt der
   Delta-Vergleich, nicht mehr die Identitätsprüfung.

## Grenzen gegenüber MVS

- Baseline-Volumes ausschließlich **lesend** (`dasdls`, `dasdpdsu`,
  heruntergefahren). Geschrieben wird nur auf `mvsce-src` oder `mvsce-exp`.
- `mvsce-lab` ist tabu — das ist die Arbeitsumgebung für andere Projekte.
- ⚠️ **Dave Kreiss' Build und seine 3390-Mods beschädigen den Freispeicher eines
  Volumes.** Sie laufen ausschließlich auf `mvsce-exp`. Details im Runbook.
- Nach jedem IPL `/s HTTPD` — ohne HTTPD kein mvsMF und damit kein Kanal.
  Vor dem Shutdown `/p HTTPD`, das mitgelieferte Skript kennt ihn nicht.

## Rohmaterial

Liegt **nicht hier**, sondern in `~/repos/MVSSRC`:

| Pfad | Inhalt |
|---|---|
| `Dave Kreiss - MVS from Source/MVSBLD/` | sein Arbeitsstand, 5.529 `.ASM`, davon 747 bearbeitet |
| `Dave Kreiss - MVS from Source/BLDMVS/` | Installationspaket, `BLDMVS.AWS`, Instruktionen als PDF |
| `IKJ/` | TSO-Module, `.asm` plus aus Kommentaren extrahierte `.pli` |
| `WORK/doc/` | der Mailverkehr mit Dave Kreiss als PDF |
| `www.stben.net/`, `mvssrc/mainframe.eu/` | zwei Web-Spiegel gefundener Sourcen |

## Konventionen

- Antworten auf Deutsch, sofern nicht anders geschrieben.
- **Referenzdokumente** (`docs/*.de.md` / `*.en.md`) zweisprachig,
  **Arbeitsdokumente** (`TODO.md`, Runbook, Entwürfe) nur deutsch.
- Modul- und Datasetnamen in Backticks und groß: `IKJCT430`, `SYS1.CMDLIB`.
- Der Name schreibt sich **Dave Kreiss**, mit Doppel-s.
