# TODO — MVS 3.8j Source Recovery

Stand: 2026-09-04. Arbeitsliste zum
[Arbeitsplan](docs/arbeitsplan.de.md). Der Plan sagt *warum* und
*wohin*, diese Liste sagt *was als Nächstes*.

Nur auf Deutsch — das ist ein Arbeitsdokument, kein Dokument für Dritte.

**Legende:** 🔒 blockiert anderes · ⚡ läuft parallel, blockiert nichts ·
🚪 Gate: Ergebnis entscheidet über den weiteren Weg

---

## Sofort

### 1. ✅ Dave wegen der Lizenz gefragt — Antwort steht aus

- [x] Entwurf durchlesen und anpassen
- [x] **Abschicken** (04.09.2026)
- [ ] Nach ~4 Wochen einmal nachfassen, danach nicht mehr

Blockiert **nur die Veröffentlichung**, nicht die Arbeit.

**Datenpunkt zur Lizenzfrage, aus einer früheren Mail von Dave:** Er verteilt
`BLDMVS.7z` selbst öffentlich über die Dateiablage der turnkey-mvs-Gruppe und
nennt es ausdrücklich *„freely downloadable"*. Das ist keine Lizenzerteilung,
zeigt aber eine Absicht zur freien Weitergabe — hilfreich, falls die Antwort
ausbleibt.

### 1a. 🔒 Aktuelles BLDMVS.7z holen und abgleichen

Dave nennt als **aktuellen Stand des Build-Prozesses**:

```
https://groups.io/g/turnkey-mvs/files/MVS%203.8J%20Source%20Recovery/BLDMVS.7z
```

Unser lokaler Stand ist älter: `BLDMVS.AWS` vom 16.09.2021, die Instruktionen als
PDF in Version 2.1 vom 05.07.2020.

- [ ] Herunterladen (Gruppenmitgliedschaft nötig, deshalb von dir)
- [ ] Gegen `Dave Kreiss - MVS from Source/BLDMVS/` abgleichen: neuere
      Instruktionen? Neueres Tape? Zusätzliche PTF-Serien?
- [ ] Falls neuer: `MVSBLD/`-Extrakt erneuern und die 747-Zählung nachführen
- [ ] Die dortigen Vorsichtsmaßnahmen und die Anleitung zu den
      3390-Änderungen auf einem laufenden System auswerten

Sollte **vor** Punkt 5d passieren — sonst messen wir gegen einen veralteten
Arbeitsstand.

### 1b. 🔒 Auf MVS/CE v3.0.0 umsteigen

**Das hat sich weitgehend erledigt** — mainframed767 war schneller. Aktuell ist
**v3.0.0 „UNEXPECTED SLOTH"** vom 01.08.2026 (`MVSCE.release.v3.0.0.tar`,
199 MB). Lokal liegt noch 2.1.4 vom 08.07.2026.

Entscheidend: `jcl/customize.jcl` installiert beim Sysgen inzwischen
standardmäßig **OPNTERSE, UFSD, FTPD, HTTPD und MVSMF**. Der Hauptkanal des
Agenten ist damit ab Werk vorhanden, es muss nichts nachinstalliert werden.

- [ ] v3.0.0 herunterladen und als **Bezugsversion** festlegen
- [ ] Bestätigen, dass HTTPD und MVSMF im Release-Tar tatsächlich enthalten sind
      (nachgewiesen ist bisher nur das Baurezept im Repository, nicht das
      Artefakt)
- [ ] **Stände prüfen:** Welche HTTPD-, MVSMF-, UFSD- und FTPD-Versionen sind
      tatsächlich installiert? Siehe Punkt 1c — die Vermutung ist, dass sie
      hinter dem aktuellen Stand liegen. Notfalls über MVP selbst aktualisieren
- [ ] [RUNBOOK.md](docs/runbook.md) gegen v3.0.0 gegenprüfen — Geräteadressen,
      Skripte, Pfade

### 1c. 🔒 Vorher: libc370 releasen, dann alle vier Pakete relinken

**Der Auslöser liegt nicht in den vier Projekten, sondern eine Ebene tiefer.**
libc370 ist die Basisbibliothek des ganzen Ökosystems — ein Fehler dort ist ein
Fehler in httpd, mvsMF, ftpd und ufsd gleichzeitig. libc370s eigene `TODO.md`
sagt es unmissverständlich:

> *„With #145/#147 done, every multitasking consumer wants a relink on the next
> release — now for four reasons, not one."*

#### Stand libc370

Letztes Release **v1.0.3 vom 23.08.2026**. Seitdem liegen auf `main` unter
anderem:

| Datum | Änderung |
|---|---|
| 26.08. | `fix`: `puts()` eine kritische Sektion, `fclose()`-Teardown unter der Sperre, `DEQ` behält seine Scope-Bits (#147, Items 2/1/4) — `sysunlock()` konnte vorher nie freigeben |
| 26.08. | `fix`: **SYNAD auf den BSAM-DCBs** — ein echter E/A-Fehler ist jetzt `ferror()`+`EIO` statt eines adressraumtötenden **S001** (#147 Item 3) |
| 27.08. | `fix`: vier doppelte Externals entfernt (#151) |
| 30.08. | `feat(sysmac)`: `SPIE`, `TIME`, `WTOR`, `PUTX` ergänzt (#155) |

Dazu #145 (interne Writer, ownership-aware Wrapper), bereits vor v1.0.3 gemerged.

#### Stand der vier Konsumenten

Alle vier wurden gegen **libc370 v1.0.3** gebaut und brauchen den Relink:

| Projekt | Letztes Release | Datum | Eigene unreleased Änderungen |
|---|---|---|---|
| httpd | v4.0.1 | 25.08.2026 | nur Bump auf `4.0.2-dev` + TODO-Notizen |
| ufsd | v1.2.1 | 23.08.2026 | nur Bump auf `1.2.2-dev` |
| ftpd | v1.0.1 | 23.08.2026 | nur Bump auf `1.0.2-dev` |
| mvsmf | v1.0.0-**dev** (Pre-Release) | 25.08.2026 | **eine echte Korrektur** (PR #359 / Issue #210) |

Offene PRs: keine, in keinem der vier.

Dass drei davon inhaltlich nichts Eigenes mitbringen, ist also **kein Argument
gegen ein Release** — der Grund für den Rebuild sitzt in libc370.

#### Reihenfolge

- [ ] **libc370 v1.0.4 schneiden** — die Korrekturen liegen seit dem 26.08. auf
      `main` und sind in keinem Release
- [ ] **httpd, ufsd, ftpd** gegen die neue libc370 neu bauen und releasen
- [ ] **mvsmf** ebenso — und dabei gleich **ein stabiles v1.0.0** statt eines
      Pre-Releases. Bisher existiert nur der eine Tag `v1.0.0-dev`, während
      `MVP/desc/MVSMF` bereits `Version: 1.0.0` nennt, also eine Version, die es
      upstream nicht gibt
- [ ] Versionstabelle in
      [mail-mainframed767-mvsce-301.md](docs/mail-mainframed767-mvsce-301.md)
      aktualisieren

### 1d. ⚡ mainframed767 um ein MVS/CE 3.0.1 bitten

Entwurf liegt in
[mail-mainframed767-mvsce-301.md](docs/mail-mainframed767-mvsce-301.md).
**Erst nach 1c abschicken**, sonst nennt die Anfrage veraltete Versionen. Das
tragende Argument ist dann nicht „es gibt neuere Versionen", sondern: *die
Basisbibliothek hatte vier Korrekturen, die jeder Konsument relinkt braucht —
darunter eine, bei der ein E/A-Fehler den Adressraum mit S001 abgeschossen hat.*

- [ ] Versionstabelle im Entwurf gegen den Stand nach 1c aktualisieren
- [ ] Entwurf durchlesen, anpassen, als Issue oder Mail abschicken
- [ ] Mit anfragen: **welcher HTTPD landet tatsächlich im Build?** Der
      MVP-Deskriptor nennt 4.0.0, `MVS-sysgen/SOFTWARE/HTTPD` enthält aber
      `HTTPD330` mit `build.log` vom 13.02.2025. Bei 3.3.0 funktionieren die
      mvsMF-Konsolendienste nicht (brauchen `httpd ≥ 4.0.0-dev`, `cgictx`-API)
- [ ] Zwei kleinere Punkte mitmelden: `SCRIPTS/SHUTDOWN.RC` stoppt HTTPD und
      FTPD nicht, und gestartet wird auch nichts automatisch (kein `S HTTPD` im
      Repository, `COMMND00` hat nur `S NET` und JES2-Parameter)
- [ ] Pull Requests anbieten — und einlösen, falls angenommen

**Nicht blockierend.** Kommt keine Antwort, aktualisieren wir die vier Pakete
über MVP selbst und dokumentieren das als Schritt der Baseline-Einrichtung.

### 2. 🔒 Repo anlegen

Neues, kuratiertes Repo `mvs38-source-recovery` (Layout: Plan, Abschnitt 8).

- [ ] `git init`, Grundstruktur anlegen
- [ ] **`.gitattributes` mit `* -text` und `*.asm binary`** — vor dem ersten
      Commit. Wird das vergessen, normalisiert Git die CRLF und die
      80-Spalten-Sätze, und wir vergleichen ab da Artefakte unserer eigenen
      Werkzeugkette
- [ ] Repo **privat** (siehe Punkt 1)
- [ ] `README.md`, `CLAUDE.md` (Regeln für den Agenten)
- [ ] `.gitignore`: DASD-Images, `*.AWS`, Web-Spiegel bleiben draußen

### 3. 🔒 Tooling bauen und testen

- [ ] Hercules-DASD-Utilities aus `~/repos/hyperion` bauen: `dasdls`,
      `dasdpdsu`, `dasdseq`, `dasdcat`
- [ ] Prüfen, ob sie die MVS/CE-Volumeformate lesen — die Volumes sind gemischt
      3350, 3380 und 3390
- [ ] cc370 frisch bauen und installieren (`make && make install`), Version
      festhalten
- [ ] `file370 -v` an einem bekannten Loadmodul ausprobieren

### 4. 🔒 MVS/CE aufsetzen und Baseline einfrieren

- [ ] `MVSCE.release.v3.0.0.tar` auspacken
- [ ] IPLen, Rauchtest: JES2, TSO, SMP
- [ ] **Unveränderlichen Snapshot** der Volumes anlegen, mit Prüfsummen →
      `baseline/checksums.txt`
- [ ] mvsMF gegen MVS/CE zum Laufen bringen — bei v3.0.0 bereits installiert,
      nur zu starten und im Stand zu prüfen
- [ ] `/s HTTPD` nach dem IPL und `/p HTTPD` vor dem Shutdown in die eigene
      Betriebsroutine aufnehmen (`SHUTDOWN.RC` kennt HTTPD nicht)
- [ ] Bestätigen, dass `SYZJ201` appliziert ist (`retcode` kommt dann über die
      REST-API; `NOTIFY=` ergänzt mvsMF selbst)
- [ ] Baseline inventarisieren → `baseline/mvsce-v3.0.0.md`: installierte
      USERMODs, MVP-Pakete, Sysgen-Parameter, I/O-Gen
- [ ] **Bestätigen, dass die DLIBs (`AOS*`) auf `smp000.3350` liegen** — davon
      hängt der ganze Vergleichsmaßstab ab. Falls nicht: `zdlib1.het` laden
- [ ] **SMP-CDS auswerten: welche SYSMODs sind ACCEPTed?** Entscheidet, wie
      sauber die DLIBs als Vergleichsorakel sind (siehe Plan, Abschnitt 5)
- [ ] Hercules-Webkonsole als Notweg aktivieren (`conf/local/custom.cnf`:
      `HTTP PORT 8038 NOAUTH` / `HTTP START`)
- [ ] [RUNBOOK.md](docs/runbook.md) beim ersten Durchlauf verifizieren — jede
      Prozedur von 📄 auf ✅ heben oder korrigieren

Ohne dieses Inventar kann später niemand `DIFF-USERMOD` von `DIFF-UNBEKANNT`
unterscheiden — der Agent würde sich an erklärbaren Differenzen totlaufen.

### 4b. ⚡ Instanzen auf `mvsdev.lan` aufsetzen

Drei MVS/CE-Instanzen, je Hercules in einer tmux-Session (Rollen und Begründung
in [RUNBOOK.md](docs/runbook.md), Abschnitt 6):

| Instanz | Zweck |
|---|---|
| `mvsce-lab` | alle anderen Projekte, ständig verfügbar — **für den Agenten tabu** |
| `mvsce-src` | dieses Projekt: PTFs, APPLY/ACCEPT, IPL-Test |
| `mvsce-exp` | dieses Projekt: Experimente, vor allem SMPWRK3-Reproduktion |

- [ ] Portbelegung für drei Instanzen festlegen — **Reader-Ports sind die
      bekannte Kollisionsfalle** (`MVP/MVP.ini`, siehe `~/repos/mvs/REFCARD.md`)
- [ ] tmux-Sessionnamen und Startskripte je Instanz
- [ ] Prozedur „Instanz aus Template neu erzeugen" schreiben und testen
- [ ] mvsMF-Zugriff über Netz für den Agenten einrichten
- [ ] Klären, wo das Baseline-Template liegt (Mac oder `mvsdev.lan`) und wie die
      Prüfsummen über beide Orte konsistent bleiben

**Nicht auf dem kritischen Pfad.** Gebraucht werden die Instanzen erst ab M7.
M0 und M1 brauchen nur die Volume-Dateien, kein laufendes System — der Durchstich
in Punkt 5 geht also schon mit der lokalen 2.1.4.

### 5. 🚪 Der Durchstich: ein einziges Loadmodul

- [ ] Ein Loadmodul mit `dasdpdsu` aus `mvsres.3350` ziehen — **ohne laufendes
      MVS**
- [ ] `file370 -v` zeigt das ESD-Verzeichnis
- [ ] CSECTs, IDR-Sätze und Eyecatcher auslesen
- [ ] Ergebnis von Hand gegen dasselbe Modul auf dem laufenden System prüfen

**Das ist der wichtigste frühe Punkt der ganzen Liste.** Er beantwortet, ob die
host-seitige Extraktion überhaupt trägt. Wenn ja, ist vieles danach
Fleißarbeit. Wenn nein, planen wir um, bevor Aufwand hineingeflossen ist.

---

## Danach: Inventar und Machbarkeit

### 5b. 🚪 Die DLIB-These messen: MVS/CE gegen TK5

**Billig, früh, und das Ergebnis verändert die Statik des Projekts.**

These: Alle Turnkey-Distributionen sitzen auf denselben IBM-DLIBs. Unterschiede
entstehen erst durch Sysgen und USERMODs — und die wirken auf die *Target*
Libraries, nicht auf die DLIBs. Einzige Ausnahme: per **ACCEPT** eingespielte
SYSMODs.

Beide Seiten liegen lokal vor:

| System | DLIB-Volume |
|---|---|
| MVS/CE | `smp000.3350` |
| TK5 | `tk5dlb.392` (`~/Downloads/mvs-tk5/dasd/`, 30,5 MB) |

- [ ] `dasdls` über beide Volumes: welche `AOS*`-Bibliotheken gibt es, gleiche
      Mitgliederzahl?
- [ ] Gegenprobe an der Wurzel: Haben beide denselben `ptfs.het`-Stand und
      dieselben Morrison-USERMODs verarbeitet? (siehe Plan, Abschnitt 5)
- [ ] Objektdecks extrahieren und CSECT-weise vergleichen
- [ ] Abweichungen gegen die SMP-CDS beider Systeme halten — sind es ACCEPTete
      SYSMODs?
- [ ] Ergebnis in `baseline/dlib-vergleich.md` festhalten

**Hält die These**, ist unser Ergebnis Source für **MVS 3.8j**, nicht für unser
MVS/CE — distributionsunabhängig. Dann löst sich auch die Bezugsversionsfrage
weitgehend auf, und Daves DLIB-Ergebnisse tragen doch (siehe Plan, Abschnitt 5).

**Hält sie nicht**, bekommen wir statt einer Unsicherheit eine Liste betroffener
Elemente — auch das ist ein brauchbares Ergebnis.

### 5c. 🚪 `ptfs.het` untersuchen — die Messung mit der größten Hebelwirkung

**Korrektur einer früheren Annahme:** Die IBM-PTFs sind nicht verloren. Das
MVS-sysgen-Projekt liefert `tape/ptfs.het` mit **1.482 PTFs für MVS 3.8j**, und
`jcl/smpjob03.jcl` („ACCEPT FMIDS/PTFS") spielt sie per `ACCEPT G(fmid)` in die
DLIBs ein. Der Objektcode trägt sie also — der Source nicht.

Die entscheidende Frage: **Enthalten diese PTFs `++SRC`, oder nur `++MOD`?**

- [ ] `ptfs.het` besorgen (im sysgen-Repo, 14,2 MB) und auf dem Host auspacken
- [ ] Auszählen: wie viele der 1.482 PTFs enthalten `++SRC`-Elemente?
- [ ] Falls welche: welche Module betreffen sie, und decken sie sich mit unseren
      `DIFF-UNBEKANNT`-Fällen?
- [ ] Ergebnis in `baseline/ptfs-analyse.md`

**Warum das so viel wert ist:** Jeder PTF mit Source schließt ein Stück der Lücke
**mechanisch** — ohne Disassemblieren, ohne Angleich-Schleife, ohne Agent. Sind
es viele, verkleinert sich der Arbeitsvorrat erheblich. Sind es keine, haben wir
die Erklärung dafür, warum Source und Objekt überhaupt auseinanderlaufen — auch
das ist ein Ergebnis.

Beides ist billig zu haben und sollte vor der großen Vergleichskampagne
feststehen.

### 5d. 🚪 Daves 747 Module gegen die MVS/CE-DLIBs

**Die wichtigste Einzelmessung des Projekts** — sie beantwortet, ob wir auf
Daves Arbeit aufsetzen können oder sie neu machen müssen.

`MVSBLD/` ist nicht sein Ausgangsmaterial, sondern sein **Arbeitsstand**.
Nachgezählt, welche Module er tatsächlich angefasst hat:

| Serie | Bereich | Module |
|---|---|---:|
| `DSK0` | Basis-Bereinigung | 235 |
| `DSK1` | NUCLEUS | 158 |
| `DSK2` | SVCLIB | 32 |
| `DSK3` | JES2 + SMP | 36 |
| `DSK9` | Makro-Modernisierung | 12 |
| `DSKC` | CMDLIB | 203 |
| `DSKK` | LINKLIB (unvollständig) | 61 |
| `DSKL` | LPALIB (unvollständig) | 55 |
| | **insgesamt** | **747** von ~5.500 |

- [ ] Die 747 Module identifizieren (Markierung `DSKnnnn` in Spalte 65 bzw.
      `*DSKnnnn` in Spalte 1)
- [ ] Alle mit `as370` assemblieren und gegen die MVS/CE-DLIB-Elemente
      vergleichen
- [ ] Ergebnis auswerten: überwiegend `IDENTISCH`, systematische Restdifferenz,
      oder unsystematisch verstreut?
- [ ] **Sonderbehandlung markieren:** 50 Module tragen `???` (Dave konnte den
      Zweck nicht rekonstruieren), 16 tragen `!!!` (Kniff für den Vergleich).
      Dort darf kein Agent eigenmächtig aufräumen

**Fällt es gut aus**, ist der Arbeitsvorrat um 747 Module kleiner und die
Werkzeugkette an bekanntem Material validiert. **Fällt es schlecht aus**, liegen
seine eigentlichen PTFs als `MVSSRC.BLD.SMP.LIB` bis `.LIB5` auf dem
`BLDMVS.AWS`-Band in diesem Repo — in IEBUPDTE-Form, also erneut anwendbar. Neu
machen müssen wir seine Arbeit in keinem Fall.

### 6. Inventar und die beiden Tabellen (M1)

- [ ] Inventar über alle Systembibliotheken — **Target Libraries UND
      Distribution Libraries (`AOS*`)** (`dasdls`)
- [ ] CSECT-, IDR- und Eyecatcher-Extraktion, maschinenlesbar als CSV
- [ ] SMP-CDS auf `smp000` auswerten: SYSMOD → Element, plus ACCEPT-Status
- [ ] Index über alle lokalen Source-Bestände: `MVSBLD/` (5.528), `IKJ/` (269),
      `www.stben.net/`, `mvssrc/mainframe.eu/`, `NEW.ASM`, `MVT.ASM`
- [ ] Join → Tabelle A (portiert) und Tabelle B (fehlend)

### 7. 🚪 as370-Lückenanalyse (M2)

> **Vorabmessung vom 04.09.2026 — das Gate sieht gut aus.**
>
> 150 zufällig gezogene Module aus `MVSBLD/`, assembliert mit `as370 V1.0`,
> als einzige Makroquelle `~/repos/mvs/sys1.maclib` (742 Member):
>
> | | |
> |---|---:|
> | sauber assembliert | **56 (37 %)** |
> | mit Fehlern | 94 |
>
> **Entscheidend ist die Fehlerverteilung:** Es sind fast ausschließlich
> **fehlende Makros**, keine Assembler-Grenzen. Am häufigsten `GOIF` (79),
> `SET` (24), `IECRES`, `IEDQMSG`, `IEDHJN`, `IEHPOST`, `DSW`, `BLSUFRES`,
> `SMPPI`, `IECDSECS` — also AMODGEN- und private Makros, die schlicht noch
> nicht da sind.
>
> Echte as370-Lücken in der Stichprobe, gezählt in einstelligen Zahlen:
> **`DC/DS` Typ `S` ist nicht implementiert** (namentlich gemeldet), einzelne
> Addressability-Fehler, und Undefined-Symbol-Meldungen, die überwiegend
> Folgefehler fehlender DSECT-Makros sein dürften.
>
> **Schlussfolgerung:** Nicht as370 ist der Engpass, sondern die
> Makroverfügbarkeit — und das ist ein Extraktionsproblem, kein
> Entwicklungsproblem. Die Quote dürfte mit `SYS1.AMODGEN` und den privaten
> Makrobibliotheken deutlich steigen.
>
> *Vorläufig: Herkunft von `sys1.maclib` ungeprüft, Stichprobe klein, nur
> Assemblierbarkeit gemessen — nicht Objektgleichheit.*


- [ ] **`SYS1.AMODGEN` und die privaten Makrobibliotheken extrahieren** — das ist
      laut Vorabmessung der Haupthebel. Dazu `SYS1.APVTMACS`; Dave nennt zusätzlich
      selbst angelegte `PVTMAC`/`APVTMAC` mit Makros, „which are in none of the
      distributed maclibs"
- [ ] `SYS1.MACLIB` aus MVS/CE gegen `~/repos/mvs/sys1.maclib` abgleichen —
      letztere hat 742 Member unbekannter Herkunft
- [ ] Messung mit vollständigem Makrosatz wiederholen und die Quote fortschreiben
- [ ] `DC/DS` Typ `S` in as370 nachziehen — die einzige namentlich gemeldete
      Lücke aus der Vorabmessung
- [ ] as370 über einen Querschnitt von `MVSBLD/*.ASM` und `IKJ/*.asm` laufen
      lassen
- [ ] Fehler kategorisieren: fehlende Direktive, Makro, Ausdruckssyntax,
      Adressierung, sonstiges
- [ ] Bekannte Lücken gezielt prüfen: `START`, `PUNCH`, `REPRO`, `ICTL`,
      `OPSYN`, `DXD`
- [ ] „Häufig und billig" sofort in as370 nachziehen
- [ ] Gegenprobe gegen IFOX00 auf MVS an einem Modul

**Gate.** Fällt die Quote schlecht aus, hat as370 Vorrang vor allem anderen —
dann wird aus diesem Punkt das Hauptprojekt für eine Weile.

### 8. Daves „fertige" Module neu prüfen (M3)

Daves „verifiziert" gilt gegen **TK3**, nicht gegen MVS/CE. Das muss neu
festgestellt werden.

- [ ] `cmplmd370` bauen: `DIFIN`/`DIFOUT`-Semantik, `CLEARRLD`, JSON-Ausgabe,
      **Exit-Code 0 nur bei Byte-Identität**
- [ ] Pilot: ein CMDLIB-Modul komplett durch die Kette — **`as370`-OBJ gegen das
      DLIB-Element**, ohne `ld370` dazwischen. Dort kennen wir die erwartete
      Antwort
- [ ] Gegenprobe gegen das Target-Loadmodul; das Delta ist die
      USERMOD-/Sysgen-Schicht
- [ ] Danach **vollständig** über alle Bibliotheken (deine Entscheidung)
- [ ] Verdikte vergeben, `DIFF_DLIB` und `DIFF_TGT` getrennt führen
- [ ] Tabelle A mit echten Zahlen füllen

Erwartung: Gegen die DLIBs sollte die Trefferquote deutlich höher liegen als
gegen die Target-Libraries — dort fallen USERMODs, Sysgen-Konfiguration und
Linkage-Editor als Störquellen weg.

---

## Werkzeugbau

### 9. dasm370 und der Rundlauf (M4)

- [ ] `libobj370` aus as370/ld370/file370 extrahieren (cc370-Roadmap Phase 0).
      Validierung: die bestehenden Werkzeuge erzeugen weiterhin byte-identische
      Ausgabe
- [ ] `dasm370` v1 — Basis sind **as370s Opcode-Tabellen**, nicht der
      Waterloo-Code (Lizenz, siehe Plan Abschnitt 6)
- [ ] **Rundlauftest** `dasm370 → as370 → cmplmd370` muss `IDENTISCH` ergeben.
      Der Selbsttest des Disassemblers und die Voraussetzung für Fall D
- [ ] Alignment-Diff-Modus: Einfügungen und Löschungen als solche erkennen,
      nicht als Byte-Rauschen. Ohne ihn kann der Agent Differenzen nicht
      klassifizieren
- [ ] Ausgabequalität: Labels, `USING`-Rekonstruktion, Literale,
      Adresskonstanten

### 10. 🚪 Der Orchestrator (M5)

- [ ] `mvsrec`: Queue, Zustandsautomat, Budget, `work/state/` mit Wiederaufnahme,
      `evidence/`, Eskalationsberichte
- [ ] Leitplanken technisch durchsetzen, nicht nur dokumentieren (Plan,
      Abschnitt 2.4)
- [ ] `AGENT.md` schreiben — der Arbeitsvertrag, den ein Agent zu Beginn liest
- [ ] Trockenlauf über Fall-A-Module: Verdikt **ohne jede Iteration**
- [ ] Erster autonomer Lauf über fünf Fall-B-Module

**Gate für das Zielbild.** Hier entscheidet sich, ob die Autonomie trägt. Alles
davor ist Vorbereitung, alles danach Skalierung.

---

## Breite herstellen

### 11. Abdeckung auf DLIB-Ebene (M6)

Kein gezielter Zugriff mehr, sondern ein systematischer Durchgang. Ziel ist
Abdeckung, sortiert nach Aufwand statt nach Thema.

- [ ] Von Daves verifizierten Bereichen nach außen: NUCLEUS, SVCLIB, JES2, SMP,
      CMDLIB — dort liegt seine Source-Wartung bereits vor
- [ ] Danach Tabelle B von unten nach oben, nach `DIFF_DLIB` sortiert
- [ ] Fall D nebenher: Module ohne Source mechanisch auf `IDENTISCH-ROH` bringen
- [ ] **Kalibrierung an der `IKJEFT`-Gruppe.** Daves CSECT-Vergleich von 2024
      liefert dort eine fertige Skala: `IKJEFT40`, `52`, `53`, `54`, `56` mit
      2 bis 10 Byte Differenz bei gleicher Länge, `IKJEFT35` (1.456),
      `IKJEFT45` (1.441), `IKJEFT55` (4.012), bis `IKJEFT01` (6.867) und
      `IKJEFT02` (10.899). Bekannte Zahlen von leicht bis schwer — ideal, um den
      Agenten zu eichen
- [ ] **Vor der ersten eigenen Änderung einfrieren:** Git-Tag auf den
      `IDENTISCH`-Stand, Objekte als Referenz mit ablegen. Das ist der
      Abzweigpunkt zwischen Wiederherstellung und Entwicklung

**Nicht mehr das Ziel:** die BREXX-Integration. Sie war der Anlass des
ursprünglichen Mailverkehrs und taugt weiter als Testgelände, ist aber kein
Projektziel mehr. `IKJ/REXX_INTEGRATION_PLAN.md` ist historisch.

### 12. Zurück nach MVS (M7)

- [ ] `++PTF`/`++USERMOD` samt JCLIN aus Git-Source erzeugen — templatisierbar
- [ ] Transport über `xmit370` und `RECV370`
- [ ] APPLY/ACCEPT auf einem MVS/CE-**Klon**, gesteuert über mvsMF
- [ ] IPL- und Funktionstest **autonom auf dem Klon**, nach
      [RUNBOOK.md](docs/runbook.md), zwingend mit Zeitdeckel. Bei dir bleibt die
      Übernahme in ein anderes als das Klon-System

---


### 13. MVS/CE aus Source bauen (M8) — der Endzustand

Nicht „PTFs einspielen", sondern „das System aus unserem Source erzeugen".

Der Anknüpfungspunkt steht in `sysgen.py`: **`step_03_build_dlibs`** erzeugt die
DLIBs aus `tape/zdlib1.het`, `step_04_system_generation` und alles Weitere
leiten sich daraus ab. Kommt der DLIB-Inhalt aus unserem Source, baut der Rest
der Kette unverändert weiter.

- [ ] `step_03_build_dlibs` im Detail lesen — Form und Struktur des Ergebnisses
- [ ] DLIB-Inhalt aus unserem Source-Baum erzeugen
- [ ] Sysgen fahren, bei dem Schritt 03 ersetzt ist
- [ ] Ergebnis IPLen und gegen ein reguläres MVS/CE vergleichen

**Abnahme:** Ein IPL-fähiges MVS/CE, dessen DLIBs aus unserem Source stammen.

## Eigener Strang: SMPWRK3-Analyse

⚡ Blockiert bis M7 nichts und braucht kein laufendes MVS. Kann jederzeit
nebenher laufen.

Der Befund aus Daves Mail vom 08.06.2022: SMP setzt mitten in APPLY/ACCEPT das
Directory von `SMPWRK3` zurück, merkt es nicht und assembliert weiter; der
Linkedit erzeugt danach nicht ausführbare Loadmodule. Zuerst betroffen ist
APPLY von `EBB1102`.

**Wir haben den SMP-Source lokal** — 119 `HMASM*`-Module in
`Dave Kreiss - MVS from Source/MVSBLD/`. Damit ist die Analyse sofort
startbar.

Konkrete Einstiegspunkte aus einer ersten Durchsicht:

- [ ] **`HMASMIO`** (dazu `HMASMIO1`, `HMASMION`) — die zentrale I/O-Schicht.
      Alle SMP-Module rufen sie mit einem Funktionscode in `IOPFUNCT` auf;
      `IOPSTOWR` ist „STOW replace". Hier läuft die Directory-Behandlung
      zusammen, hier ist der Fehler am wahrscheinlichsten zu finden
- [ ] Die drei Module, die `SMPWRK3` namentlich referenzieren: **`HMASMCMP`**
      (schließt `SMPWRK3`, um den DEB für das Interface-Modul zu setzen —
      auffällig), **`HMASMDC2`**, **`HMASMPIN`**
- [ ] Die vier Module mit `STOW`-Bezug: `HMASMDC1`, `HMASMDR2`, `HMASMCRW`,
      `HMASMRCC`
- [ ] Daves eigene offene Frage beantworten: **Kann `STOW` unter MVS 3.8 ein
      Directory löschen?** Die STOW-Routine ist SVC 21 = **`IGC0002A`**
      („FIRST LOAD OF BPAM STOW ROUTINE"), liegt in `MVSBLD/IGC0002A.ASM` und
      als Listing unter `www.stben.net`. Von dort aus die Folgeloads verfolgen
- [ ] Hypothese formulieren, dann gezielt reproduzieren

**Falsche Fährte vermeiden:** `HMASMPIN` ist eines der Module, für die kein
Source existierte und die Dave neu geschrieben hat. Das macht es verdächtig —
ist es aber nicht. Dave hat den Fehler auf einem **frischen TK3-System mit
originalen SMP-Modulen** reproduziert. Die Ursache liegt also im
Original-SMP, nicht in Daves Rekonstruktion.

Ein zweiter Gedanke, der zu prüfen wäre: Der Fehler tritt nur bei **großen**
APPLYs auf. Das riecht nach einer Grenze — Directory-Blöcke, eine
Extent-Grenze, ein Zähler, der überläuft. Daves Versuch, `SMPWRK3` mit größerem
Directory anzulegen, half nicht; das spricht eher gegen eine reine
Directory-Größe und für etwas anderes, das mit der Menge skaliert.

---

## Entschieden

- [x] **Neu-Basislinierung vollständig**, alle Bibliotheken, inklusive Vergleich
- [x] **Vergleichsmaßstab:** primär das DLIB-Objektdeck, sekundär das
      Target-Loadmodul; das Delta ist die USERMOD-/Sysgen-Schicht und wird
      gemessen statt geraten
- [x] **Iterationsbudget gestaffelt:** Fall B ≈ 30, Fall D ≈ 50, Fall C ≈ 150,
      plus Zeitdeckel
- [x] **Der Agent darf auf dem Klon IPLen**, Betriebswissen in
      [RUNBOOK.md](docs/runbook.md)

## Noch offen

- [ ] **MVP-Pakete:** nur Liste, oder auch deren Inhalt inventarisieren?
- [ ] **Zeitdeckel** für IPL und Jobs — ergibt sich aus dem ersten Lauf
- [ ] **Bezugsversion MVS/CE** — Vorschlag: v3.0.0, siehe Punkt 1b
- [ ] **`IDENTISCH-ROH`:** bleiben Fall-D-Module mit absoluten Offsets stehen,
      oder wird Lesbarmachung später ein eigenes Ziel?
