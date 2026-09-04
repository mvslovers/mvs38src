# MVS 3.8j aus Sourcen bauen — Projektzusammenfassung

Zusammenfassung des Mailverkehrs zwischen **Mike Großmann**, **Dave Kreiss** und
**Greg Price** (Dez. 2020 – Juli 2024) sowie der Dokumentation
*„Recovering and Building MVS 3.8j from SOURCE using SMP", Version 2.1,
Stand 5. Juli 2020, von Dave Kreiss*.

Quellen: `WORK/doc/*.pdf` und
`Dave Kreiss - MVS from Source/BLDMVS/Build MVS From Source Instructions.pdf`.

> Englische Fassung: [kreiss-projekt.en.md](kreiss-projekt.en.md)

---

## 1. Ziel und Grundidee

Dave Kreiss verfolgt seit Jahren das Ziel, **MVS 3.8j vollständig aus Quellcode
neu zu bauen** — und zwar mit **SMP (System Modification Program) als
Wartungsvehikel**, also mit dem klassischen Mainframe-Verfahren statt mit
externen Source-Management-Werkzeugen.

Begründung (Mail 22.12.2020 / Doku): Jede Änderung an MVS-Executables muss am
Ende ohnehin über SMP als PTF oder USERMOD in die Target-Libraries gelangen.
Ein externes Tooling würde diesen Schritt nur verschieben, nicht ersparen.

Ausgangsbasis ist ein **Turnkey-System TK3** (TK4- wird über einen eigenen
Anhang der Doku unterstützt). Referenz für „korrekt" ist der Objektcode der
ausgelieferten TK3-Libraries: Der wiederhergestellte Source gilt als richtig,
wenn er **CSECT-identischen Objektcode** erzeugt.

Größenordnung: rund **5.500 Source-Module** und **2.000 Makros**.

---

## 2. Methodik der Source-Wiederherstellung

Dave beschreibt sein Vorgehen am ausführlichsten in der Mail vom 03.07.2024:

> „The process is basically slow, first I try to isolate inserted/deleted
> instructions/data and fill them as best as I can. Then get all instruction
> displacements right then the storage/constants. Often DSECT displacements are
> different and that has to be fixed, usually related to getmained work areas
> and their layout."

Reihenfolge also:

1. Eingefügte/gelöschte Instruktionen und Daten isolieren und bestmöglich füllen.
2. Alle Instruktions-Displacements korrigieren.
3. Storage und Konstanten angleichen.
4. Abweichende DSECT-Displacements korrigieren — meist bei GETMAINten
   Arbeitsbereichen und deren Layout.

Ergänzend beschreibt **Greg Price** (19.12.2020) die klassische Schleife, die
demselben Zweck dient: Vorhandenen Source assemblieren, den aktuellen Objektcode
disassemblieren, beides vergleichen, ein paar Instruktionen angleichen — und
wieder von vorn. Für das `REUSE`-Operand von `ALLOCATE` musste er dafür rund
acht Module disassemblieren; einzelne Module kosteten ihn Wochen.

### Was genau ist Daves Baseline?

Das ist der Punkt, an dem sein Aufbau leicht missverstanden wird, denn es gibt
**zwei** Baselines — und der Abstand zwischen ihnen ist das ganze Projekt.

| | Was | Rolle |
|---|---|---|
| **Source-Baseline** | Der von IBM ausgelieferte MVS-Source, auf den `SRC*`-Volumes des Turnkey-Systems (bei TK4- aus `source.zip`) | Ausgangspunkt, den er verbessert |
| **Objekt-Baseline** | Die DLIBs und Target Libraries des **laufenden TK3-Systems** | Das Orakel, an dem gemessen wird |

Der entscheidende Satz steht in der Einleitung der Dokumentation:

> *„None of these builds will create total matching target system libraries as
> **the source distributed isn't in sync with the distributed
> distribution/target libraries**."*

**Der ausgelieferte Source passt nicht zum ausgelieferten Objektcode.** Das
Objekt trägt Wartungsstände, die den Source nie erreicht haben. Genau diese
Lücke ist das Problem — und sie existiert unabhängig davon, welches Turnkey-System
man nimmt.

### Warum baut Dave dann PTFs?

Weil seine `DSKnnnn`-PTFs **keine IBM-PTFs sind**. Es sind selbstgeschriebene,
synthetische PTFs, die ausschließlich einen Zweck haben: **den Source-Text auf
den Stand zu heben, den der Objektcode längst hat.**

Die Dokumentation sagt es zweimal unmissverständlich:

> *„DSK1nnn – Modifications to NUCLEUS to **bring those modules up to TK3
> maintenance level**."*

> *„The resulting PTFs update the elements so they will **match the object code
> in the target libraries**."*

Ein `DSK1164` fügt dem System also keine Funktion hinzu. Er ändert nur den
Quelltext so, dass dessen Assemblierung das Modul ergibt, **das im System schon
läuft**.

### Die beiden naheliegenden Rückfragen

**„Bei TK3/TK4- sind doch die meisten PTFs längst eingespielt?"** — Ja, **im
Objektcode**. Und genau das ist die Ausgangslage, nicht der Ausweg. Die Wartung
steckt in den Loadmodulen und Objektdecks; im Quelltext steckt sie nicht. Dass
das System aktuell ist, hilft dem Source kein Stück.

**„Könnte man nicht einfach die vorhandenen IBM-PTFs einspielen?"**

Hier ist eine Korrektur nötig: **Die PTFs sind sehr wohl erhalten, und sie sind
längst eingespielt.** Das MVS-sysgen-Projekt liefert mit `tape/ptfs.het` eine
Sammlung von **1.482 bekannten PTFs für MVS 3.8j** aus, und der Sysgen wendet sie
an — `jcl/smpjob03.jcl` trägt den Titel *„ACCEPT FMIDS/PTFS"* und macht für jedes
FMID ein `ACCEPT G(fmid)`, also die Gruppe aus Funktion **und** zugehörigen PTFs,
in die Distribution Libraries.

Der Objektcode in den DLIBs trägt diese Wartung also bereits. Trotzdem hinkt der
Source hinterher — genau der Befund, den Dave beschreibt.

**Warum, bleibt eine offene, aber messbare Frage.** Die naheliegende Erklärung:
MVS-PTFs jener Zeit lieferten überwiegend **fertige Objektmodule** (`++MOD`) und
keinen Quelltext (`++SRC`). Dann würde ihr Einspielen den Objektcode
aktualisieren und den Source unberührt lassen — was exakt die beobachtete Lücke
erzeugt.

Bewiesen ist das nicht. `ptfs.het` ist 14,2 MB groß und öffentlich verfügbar;
nachzusehen, wie viele dieser 1.482 PTFs `++SRC` enthalten, ist eine
überschaubare Messung mit großer Hebelwirkung: **Jeder PTF mit Source schließt
ein Stück der Lücke mechanisch.** Steht als Messpunkt im Arbeitsplan.

Deshalb bleibt nur der Weg, den sowohl Dave als auch Greg Price gegangen sind:
disassemblieren, vergleichen, den Source von Hand nachziehen — und das Ergebnis
als eigenen PTF festhalten.

### Warum überhaupt SMP und eigene FUNCTIONs?

Das SMP-Environment des laufenden TK3-Systems verwaltet **Objektcode**. Dave
wollte den **Source** unter SMP-Verwaltung haben. Also hat er ein **zweites,
paralleles SMP-Environment** unter `MVSSRC.BLD` aufgebaut und darin die
IBM-FUNCTIONs unter ihren Original-FMIDs neu angelegt — `EBB1102` für das Base
Control Program, `EAS1102` für den Assembler, `EJE1103` für JES2 und so weiter —,
diesmal aber mit dem gesammelten Quelltext als Inhalt:

> *„First all source code was collected and SMP FUNCTIONS were created to manage
> the code **at the source level** as close as I could determine to the current
> TK3 SMP environment."*

Aus diesem Environment assembliert und linkt SMP dann in **eigene** DLIB- und
Target-Libraries — und die vergleicht er gegen die echten. Daher auch die
getrennten Statistiken in Anhang C.

**Für uns folgt daraus ein praktischer Punkt:** Daves DSK-PTFs sind nicht
Beiwerk, sondern das eigentliche Ergebnis seiner Arbeit. Sie sind die
Source-Wartung für NUCLEUS, SVCLIB, JES2, SMP und CMDLIB, in IEBUPDTE-Form und
damit auch außerhalb von SMP verwertbar.

### Automatisierte Massenänderungen (MACCVT)

Ein großer Teil von MVS ist ursprünglich in **PL/S** geschrieben; der
ausgelieferte „Source" ist der vom PL/S-Compiler erzeugte Assembler. Dave hat
mit `MACCVT` ein Werkzeug gebaut, das diesen Code massenhaft lesbarer macht:

- **Register-Equates vereinheitlichen** auf `R0`–`R15` (statt `@00`–`@15`,
  `@0`–`@F` und weiteren Stilen). Motiv: In einem einzigen Modul existieren oft
  viele verschiedene Symbole für dasselbe Register.
- **PL/S-Inline-Strukturdefinitionen durch System-DSECTs ersetzen**:
  `L R10,LCCACPUS(,R8)` wird zu `L R10,LCCACPUS-LCCA(,R8)`; die
  auskommentierten PL/S-EQUs weichen dem passenden Mapping-Makro.
- **Bit-Definitionen** vom PL/S-Format auf die Flags der System-DSECTs umstellen.

Dave selbst nennt das Programm „a twisted piece of code" — es sei weit über sein
ursprüngliches Design hinausgewachsen, leiste aber im Wesentlichen das Nötige.
Er weist auch auf die Grenze hin: Die Technik `LABEL-DSECT(Rx)` sei nicht die
sauberste Lösung, aber die einzige, die sich automatisiert durchführen lässt.

### Weitere Eingriffe, damit der Vergleich aufgeht

- Nicht druckbare Zeichen aus Kommentaren entfernt; `DC C'…'`-Konstanten mit
  Hex-Inhalt (u. a. IDCAMS- und ICKDSF-Parser-Dictionaries) zu `DC X'…'` gewandelt.
- `END [label],(C'PL/S',nnnn,nnnnn)` um den Compiler-Versionsparameter bereinigt.
- Alignment: `DS CL3` → `DC 0F'0'`, Slack-Bytes `DS CLn` → `DC XLn'0'`, damit die
  vom Assembler nicht erzeugten Bytes im Objektvergleich nicht als Zufallsdaten
  auftauchen.
- Ältere Makro-Level: Manche Module wurden seinerzeit mit älteren Makros
  assembliert und erzeugen daher andere Instruktionssequenzen. Behelf: mit `ORG`
  über die Expansion zurückspringen, das Makro auskommentieren und die Expansion
  inline setzen, oder das alte Makro inline aufnehmen. Markiert mit `!!!` bzw.
  `!!! SOURCE COMPARE FIX !!!`.
- Wo Dave nicht rekonstruieren konnte, was der Code tut, blieben absolute Offsets
  stehen, markiert mit `???` (rund 20+ Module, vor allem in SMP). Beispiel aus
  `IGFTMC00`: `NI 67(R9),255-X'80'   ??? DSK1164`.

### PTF-Nummernschema

Änderungen sind in Spalte 1 als `*DSKnnnn` oder in Spalte 65 als `DSKnnnn`
markiert.

| Bereich | Bedeutung |
|---|---|
| `DSK0001`–`DSK0099` | Makro-Änderungen |
| `DSK0100`–`DSK0999` | Source so korrigieren, dass er sauber assembliert |
| `DSK1nnn` | NUCLEUS auf TK3-Wartungsstand |
| `DSK2nnn` | SVCLIB auf TK3-Wartungsstand |
| `DSK3nnn` | JES2 und SMP auf TK3-Wartungsstand |
| `DSK5000`/`6000`/`7000`/`8000` | Phase 1: auskommentierten Code entfernen |
| `DSK6000` | die SMP-Modifikation selbst (siehe unten) |
| `DSK9000` | Phase 2: Inline-Makroexpansionen durch echte Makroaufrufe ersetzen |
| `DSKCxxx` | Phase 3: SYS1.CMDLIB |
| `DSKKxxx` | Phase 4: SYS1.LINKLIB |
| `DSKLxxx` | Phase 5: SYS1.LPALIB |

### SMP-Erweiterung 4.48 → 4.49

SMP kennt keine Möglichkeit, Source-Zeilen zu löschen. Da beim
PL/S-Aufräumen sehr viel auskommentierter Code anfällt, hat Dave SMP so
erweitert, dass es die IEBUPDTE-Anweisungen **`./ REPL` und `./ DELETE`**
akzeptiert. Damit wechselt die SMP-Version von **4.48 auf 4.49**. Diese
Änderung (PTF `DSK6000`, eingespielt vom Job `MAINT05Z` in `SYS1.LINKLIB`) ist
**Voraussetzung für alle Phasen ab Phase 1**.

---

## 3. Aufbau des Build-Prozesses

Der Build ist in **Basis + fünf Phasen** gegliedert. Alle Jobs sind verkettet:
Jeder Job submittet den nächsten und prüft Return Codes; bei einem Fehler stoppt
die Kette.

| Phase | Inhalt |
|---|---|
| **Basis** | Verändert das laufende MVS nicht, arbeitet nur unter `MVSSRC.BLD`. `DSK0000`–`DSK0099` Makros, `DSK0100`–`DSK0999` Source-Bereinigung, `DSK1000` identisches IPL-fähiges NUCLEUS, `DSK2000` identisches SVCLIB, `DSK3000` identisches JES2 und SMP. |
| **Phase 1** | Spielt das SMP-PTF ein (4.48 → 4.49) und **aktualisiert dabei die `SYS1.LINKLIB` des laufenden Systems**. Danach werden mit `DSK5000`–`DSK8000` die auskommentierten PL/S-EQUs entfernt. Alle Module bleiben objektidentisch — bis auf die drei geänderten CSECTs im SMP-Loadmodul. |
| **Phase 2** | `DSK9000`: ersetzt Inline-Expansionen alter Makros durch echte Makroaufrufe. Ab hier sind viele Module **nicht mehr objektidentisch**, aber funktional äquivalent. |
| **Phase 3** | `DSKCxxx`: `SYS1.CMDLIB`. **Abgeschlossen** — alle CMDLIB-Module passen zum TK3-Objektcode. |
| **Phase 4** | `DSKKxxx`: `SYS1.LINKLIB`. **Unvollständig.** Enthält zusätzlich die Unterstützung für 3350, 3380 und 3390 Mod 1/2/3 (u. a. IEHDASDR). |
| **Phase 5** | `DSKLxxx`: `SYS1.LPALIB`. **Unvollständig**, ebenfalls mit DASD-Erweiterungen. |

> ⚠️ **Phase 1 nicht auf dem Produktivsystem laufen lassen** — sie enthält
> IEBCOPY-Schritte gegen laufende Systembibliotheken. Die Doku verlangt ein
> geklontes System (TK3: eigenes `MVSBLD`-DASD-Verzeichnis und eigene
> Hercules-Config; TK4-: Kopie des gesamten TK4--Verzeichnisses).

### Installationsvoraussetzungen

- **12 leere, gelabelte 3390-1-Volumes** auf den Adressen `192`–`19D`:
  `BLDDLB`, `BLDTGT`, `BLDSMP`, `BLDSR1`, `BLDSR2`, `BLDLS1`–`BLDLS5`,
  `BLDWK1`, `BLDWK2` — einzutragen in die Hercules-Config und in
  `SYS1.PARMLIB(VATLST00)`.
- Auf **TK4-** zusätzlich: `source.zip` installiert, MVS-Source-Katalog
  verbunden (`SYS1.SETUP.CNTL(MVS0200)`), RAKF-Profile in
  `SYS1.SECURE.CNTL(PROFILES)` um `DATASET MVSSRC.BLD.* ALTER` und
  `DATASET SYS1.UCAT.TSO UPDATE` erweitern.
- Installationstape `BLDMVS.AWS` auf Gerät `480` mounten, Ladejob `$$$LOAD`
  ausführen. Er legt an: `MVSSRC.BLD.SMP.JCL`, `.SMP.LIB`, `.NEW.ASM`,
  `.MVT.ASM`, `.UTILITY.ASM` sowie `.SMP.JCL1`–`.JCL5` und `.SMP.LIB1`–`.LIB5`.
- `$00SMPPR` legt einmalig die PROCs `BLDSMP`, `BLDSUB`, `BLDCLR`, `BLDCOPY`,
  `BLDPRT` in `SYS1.PROCLIB` an (erfordert HERC01 bzw. Update-Recht).
- `$01SMPAL` startet den Build und ist zugleich der **Restartpunkt** — der Job
  löscht alle Datasets auf den BLD-Volumes bis auf die vom Tape geladenen. Die
  Volumes müssen für einen Neustart also nicht ersetzt werden.

**Laufzeit:** gut zwei Stunden (Daves Referenz: Windows 10, i7 3,4 GHz,
Hercules 4.0.0.8497; TK4- lief vergleichbar schnell).

### Ergebnis eines Basis-Builds

1. Ein Satz **Distribution Libraries** (Objektcode, Makros, Parameter) plus die
   erzeugte MVS-Source-Library — Struktur nahezu identisch zur bestehenden
   SMP-Umgebung.
2. Ein Satz **Target Libraries** mit den Executables, ebenso plus Source.
3. Eine **Listing-Library** mit den bei APPLY und ACCEPT erzeugten
   Source-Listings — außerhalb der SMP-Kontrolle, da SMP Utility-Output nicht
   verwaltet.

Neu angelegt wurden die SMP-verwalteten Source-Libraries `MVSSRC` / `AMVSSRC`
sowie `PVTMAC` / `APVTMAC` für Makros, die in keiner ausgelieferten MACLIB
enthalten sind.

---

## 4. Werkzeuge (Appendix B der Doku)

Source in `MVSSRC.BLD.UTILITY.ASM`.

| Programm | Funktion |
|---|---|
| `COMPLMD` | **Kernwerkzeug der Verifikation.** Vergleicht zwei Load-Module-CSECTs. `DIFIN`/`DIFOUT` erlauben es, bekannte „Löcher" (Zufallsdaten aus `DS`-Statements) gezielt zu ignorieren; `DC` erzeugt passende Assembler-`DC`-Statements; `CLEARRLD=YES` neutralisiert relozierbare Konstanten. |
| `LOADLMD` | Lädt einen CSECT aus einem Loadmodul ins Storage, ohne zu relozieren. Basis für `COMPLMD`. Abgeleitet vom Disassembler auf CBT-Tape File 217 (R. Thornton). |
| `MAPLMD` | Erzeugt eine Tabelle aller CSECTs eines Loadmoduls inkl. privater CSECTs. |
| `MACCVT` | Die oben beschriebene PL/S-Konvertierung. Steuerkarten in `#MACCVTX`, FMID-Tabelle in `#MACCVTF`, reine Registerkonvertierung in `#MACCVTR`. |
| `MVSASM38` | Zerlegt den APPLY/ACCEPT-Output in einzelne Assembly-Listing-Member. |
| `MVSLKD38` | Dasselbe für Linkedit-Listings. |
| `LMDXRF38` | Liest das Directory einer DLIB/Target-Library und erzeugt Sätze je Loadmodul und CSECT. |
| `LMDRPT38` | Wertet die `LMDXRF38`-Sätze aus und berichtet Unterschiede zwischen Original- und Build-Libraries (`SUMMARY`, `COMPARE`, `ERRORS`, `MISSING`, CSV-Output). |
| `MVSSMP38` | Prüft SMP-Output auf Fehler; konfigurierbare maximale Return Codes je Schritt (`ASMRC=`, `LKDRC=`, `SMPRC=` …). |

---

## 5. Stand des Projekts

### Fertig und getestet

| Bereich | Status |
|---|---|
| `SYS1.NUCLEUS` | Source erzeugt identischen Objektcode; **IPL-fähig und erfolgreich getestet** |
| `SYS1.SVCLIB` | identisch |
| **JES2** | identisch |
| **SMP** | identisch (bis auf die drei bewusst geänderten CSECTs) |
| `SYS1.CMDLIB` | identisch — Funktionstest steht aus |
| Assembler `IFOX00` | aus dem Build erzeugte Version erfolgreich eingesetzt |

Dave hat mit diesen Bibliotheken „various TSO work" gemacht und den Build viele
Male fehlerfrei durchlaufen lassen.

### Unfertig

`SYS1.LINKLIB`, `SYS1.LPALIB`, `SYS1.VTAMLIB` und `SYS1.TELCMLIB` sind **nicht
abgeschlossen**. Daves eigene Einschätzung in der Doku: Der aktuell erzeugte
Code für diese Bibliotheken „stand little chance of working correctly".
Grund für den Abbruch (Mail 22.12.2020): LINKLIB, LPALIB und VTAM sind schlicht
zu groß. Er wechselte stattdessen auf die DASD-Themen.

### Vergleichsstatistik (Appendix C)

> Die Doku vermerkt selbst: „This has changed but I haven't had time to update
> the differences column." Die Zahlen sind also nicht aktuell.

**Target Libraries**

| Library | Original LMODs | Original CSECTs | Build LMODs | Build CSECTs | Differenzen |
|---|---|---|---|---|---|
| CMDLIB | 212 | 753 | 213 | 753 | 234 |
| LINKLIB | 660 | 1.683 | 660 | 1.721 | 688 |
| LPALIB | 1.203 | 2.346 | 1.200 | 2.343 | 1.344 |
| NUCLEUS | 26 | 355 | 26 | 354 | **0** |
| SVCLIB | 58 | 59 | 58 | 59 | **0** |
| TELCMLIB | 188 | 192 | 188 | 192 | 88 |
| VTAMLIB | 18 | 65 | 15 | 63 | 17 |
| **Summe** | **2.365** | **5.453** | **2.360** | **5.485** | **2.371** |

**Distribution Libraries:** 5.126 LMODs / 5.454 CSECTs im Original gegenüber
5.126 / 5.456 im Build, 2.379 Differenzen über 34 AOS*-Bibliotheken.

### Seitenzweige

- **3390-Unterstützung.** Standalone-IPL von einem reinen 3390-SYSRES
  funktioniert (per USERMOD/PTF über den Build-Prozess erzeugt). Für
  **3390 Mod 2/3** blieb ein **Problem im DEB** ungelöst (Mails 22.12.2020 und
  27.05.2021).

  > ⚠️ **Warnung von Dave zu den 3390-Mods.** Die 3390-2- und -3-Modifikationen
  > liegen auf dem Installationstape, haben aber **mindestens einen Fehler in
  > der Freispeicherberechnung, der den freien Platz eines Volumes beschädigt**.
  > Seine ausdrückliche Empfehlung: diese Mods **nicht auf ein Produktivsystem**
  > bringen. In den Instruktionen stehe das an mehreren Stellen. Er hat den Build
  > zudem **ausschließlich auf TK3 getestet**.
  >
  > Praktisch heißt das: Daves Phasen 4 und 5 (`DSKK7xx`–`9xx`, `DSKL7xx`–`9xx`)
  > enthalten genau diese 3390-Erweiterungen. Wer seinen Build laufen lässt —
  > etwa um den SMPWRK3-Fehler zu reproduzieren — fährt sie mit.
- **Bis zu 32.760 Tracks (3390-27).** Code war 2024 geschrieben, lief aber „mit
  einigen Fehlern"; Dave fehlte die Zeit zur Diagnose (Mail 02.07.2024).
- **DSS370.** Der von IBM verwendete MVS-3.8-Debugger wurde **vollständig
  gebaut**, aber **nie getestet**. Source: `IQA`-präfixierte Module in
  `MVSSRC.BLD.NEW.ASM`, Loadmodul `NDSS370` in `SMP.LIB` (Mail 02.07.2024).

### Module, die noch Arbeit brauchen

Disassemblierte NUCLEUS-Module, die noch auf DSECTs umgestellt werden müssen
(sie referenzieren bislang nur absolute Offsets):
`IECVTCCW`, `IGC121`, `IGG019P2`, `IGG019QE`, `IGG019Q0`, `IGG019RC`.

SMP-Module, für die kein Source existierte und die komplett neu geschrieben
wurden:
`HMASMADD`, `HMASMEFR`, `HMASMMDR`, `HMASMMPA`, `HMASMMPL`, `HMASMPIN`,
`HMASMULI`, `HMASMULK`.

Nicht rekonstruierbar sind die **Parameter-Dictionaries von IDCAMS und ICKDSF** —
reine Hex-Konstanten, erzeugt von einem Prozess (vermutlich `COMGEN`), der nicht
verfügbar ist. Dave hat Teile des Layouts aus dem Parser-Code abgeleitet, aber
nicht finalisiert.

---

## 6. Der Blocker: SMPWRK3-Directory-Reset

Das ist die wichtigste offene Frage des gesamten Projekts. Sie hat es seit
2022 zum Stillstand gebracht (Mails 03.06.2022 und 08.06.2022).

**Symptom:** SMP setzt **mitten in APPLY oder ACCEPT das Directory von
`SMPWRK3` zurück** — also genau der Datei, in der die Objektdecks abgelegt
werden.

**Ablauf des Fehlers:**

1. Während der Assemblierungsphase legt SMP Objektdecks in `SMPWRK3` ab.
2. An einem Punkt wird das `SMPWRK3`-Directory zurückgesetzt.
3. SMP bemerkt das nicht und assembliert und speichert unbeirrt weiter.
4. Am Ende fehlen Objektdecks in `SMPWRK3`.
5. Beim anschließenden Linkedit entstehen für alle Loadmodule mit fehlenden
   Objektdecks **nicht ausführbare Versionen**.

**Nachgewiesen** über einen GTF-Trace und die Untersuchung einer permanent
angelegten `SMPWRK3`-Datei.

**Erste betroffene FUNCTION:** APPLY von **`EBB1102`** (Base Control Program)
und die zugehörigen PTFs. Inzwischen sind auch weitere FUNCTIONs betroffen.

**Was Dave erfolglos versucht hat:**

- `SMPWRK3` mit größerem Directory anlegen.
- Die betroffene FUNCTION aufteilen — erfolglos und schwer handhabbar.
- Ältere Versionen des Build-Installationstapes — gleiches Problem.
- Frische TK3-Installation, um beschädigte HMASMP-Module auszuschließen —
  gleicher Fehler.

**Was dagegen früher nachweislich funktioniert hat:** ein kompletter
generierter Build inklusive erfolgreichem IPL, ebenso die selbst geschriebenen
PTFs für einen 3390-IPL-fähigen SYSRES und die IEBUPDTE-`./ DELETE`-Erweiterung
von SMP.

**Offene Spur:** Dave hat den SMP-Source noch nicht daraufhin durchgesehen. Er
formuliert die Kernfrage so — wie wird das Directory überhaupt zurückgesetzt,
wenn nicht durch Überschreiben mit einem `X'FF'`-Member, und unterstützt das
`STOW`-Makro unter MVS 3.8 überhaupt ein Löschen des Directories?

Mike hat angeboten, das Problem an **Jay Maynard** in der Community weiterzugeben;
Dave hat der Weitergabe seiner Adresse zugestimmt (09.06.2022). Ein Ergebnis ist
in diesem Mailverkehr nicht dokumentiert.

---

## 7. TSO / IKJ-spezifische Erkenntnisse

Mikes eigentliches Interesse ist die Integration von **BREXX/370** in TSO —
REXX-Execs sollen sich wie CLISTs implizit (`%rexx`) und explizit (`EXEC …`)
aufrufen lassen. Der vermutete Ansatzpunkt ist `IKJCT430`. Dazu aus dem
Mailverkehr:

### Aktualisierte IKJCT-Module (Mail 24.12.2020)

Dave hat den Source aller CMDLIB-Module so rekonstruiert, dass sie zum
ausgelieferten TK3-Objektcode passen. Von den `IKJCT`-Modulen waren
**aktualisiert**:

`IKJCT430`, `IKJCT431`, `IKJCT432`, `IKJCT435`, `IKJCT464`, `IKJCT466`, `IKJCT469`

Alle übrigen `IKJCT`-Module stimmten bereits im Auslieferungszustand überein.

Die Updates zu `IKJCT431` stecken zusätzlich im Member **`DSKC191`** in
`MVSSRC.BLD.SMP.LIB3`, im IEBUPDTE-Format — damit lässt sich der Originalsource
auch von Hand auf den aktuellen Stand bringen (Mail 22.12.2020).

Hintergrund von Mikes Ausgangsfrage: Die im Netz gefundenen Sources
(`www.stben.net`) passen nicht zu MVS 3.8j — `IKJCT431` trägt dort
`DC C'IKJCT431 78.048'`, in Greg Prices Usermod dagegen `DC C'IKJCT431 87.344'`.

### Die Faustregel für Aktualität (Mail 27.05.2021)

> „So any module not in VTAMLIB, LINKLIB or LPALIB are current."

Alles, was **nicht** in `VTAMLIB`, `LINKLIB` oder `LPALIB` liegt, ist in Daves
Source-Bestand auf aktuellem Stand. Für die `IKJEFF`-Module heißt das: vermutlich
aktuell, sofern ihre Target-Library keine der drei genannten ist.

### CSECT-Vergleich der IKJEFT-Module (Mail 03.07.2024)

Dave hat `COMPLMD` über die rund 25 `IKJEFT`-Source-Elemente laufen lassen.
Sein Kommentar: Es gebe „some big changes not incorporated in the version of
source we have". Auffällig sei außerdem, dass das TMP-Message-Modul an vier
Stellen eingebunden ist und offenbar in **zwei Varianten** existiert, je nach
eingespielten PTFs.

| Library | LMOD | CSECT | Status | Diff. | Kommentar |
|---|---|---|---|---:|---|
| LPALIB | IKJEFT02 | IKJEFTE2 | | | Auth cmds |
| LPALIB | IKJEFT02 | IKJEFTE8 | | | Auth pgms |
| LPALIB | IKJEFT02 | IKJEFTNS | Equal | | No bg cmds |
| LPALIB | IKJEFT01 | IKJEFTSC | Length equal | 15 | Disasm |
| LPALIB | IKJEFT01 | IKJEFT01 | | 6.867 | TMP initialize |
| LPALIB | IKJEFT02 | IKJEFT02 | | 10.899 | TMP mainline |
| LPALIB | IKJEFT02 | IKJEFT03 | | 1.637 | TMP attention |
| LPALIB | IKJEFT04 | IKJEFT04 | | 2.477 | TMP STAI exit |
| LPALIB | IKJEFT04 | IKJEFT05 | | 5.200 | TMP STAE exit |
| LPALIB | IKJEFT02 | IKJEFT06 | Duplicate | 1.363 | TMP messages |
| LPALIB | IKJEFT01 | IKJEFT06 | Duplicate | 1.362 | TMP messages |
| LPALIB | IKJEFT04 | IKJEFT06 | Duplicate | 1.363 | TMP messages |
| LPALIB | IKJEFT07 | IKJEFT06 | Duplicate | 1.351 | TMP messages |
| LPALIB | IKJEFT07 | IKJEFT07 | Equal | | TMP STAE retry |
| LPALIB | IKJEFT02 | IKJEFT08 | | 75 | TMP call |
| LPALIB | IKJEFT09 | IKJEFT09 | Length equal | 7 | Disasm |
| LINKLIB | IKJEFT25 | IKJEFT25 | | 878 | TIME command |
| LPALIB | IKJPTGT | IKJEFT30 | | 4.116 | Stack service |
| LPALIB | IKJPTGT | IKJEFT35 | | 1.456 | IO service messages |
| LPALIB | IKJPTGT | IKJEFT40 | Length equal | 10 | Putline |
| LPALIB | IKJPTGT | IKJEFT45 | | 1.441 | Put Get |
| LPALIB | IKJPTGT | IKJEFT52 | Length equal | 7 | Chain out routine |
| LPALIB | IKJPTGT | IKJEFT53 | Length equal | 4 | Unchain routine |
| LPALIB | IKJPTGT | IKJEFT54 | Length equal | 6 | Text insert |
| LPALIB | IKJPTGT | IKJEFT55 | | 4.012 | Getline |
| LPALIB | IKJPTGT | IKJEFT56 | Length equal | 2 | Terminal out |
| CMDLIB | TERMINAL | IKJEFT80 | Equal | | Terminal command |
| CMDLIB | PROFILE | IKJEFT82 | Length equal | 54 | Profile command |

Lesart: Die TMP-Kernmodule (`IKJEFT01`, `IKJEFT02`, `IKJEFT03`, `IKJEFT04`,
`IKJEFT05`) weichen massiv ab — mehrere tausend Bytes Unterschied. Der
verfügbare Source ist dort weit vom TK3-Objektcode entfernt. Dagegen sind
`IKJEFTNS`, `IKJEFT07` und `IKJEFT80` bereits identisch, und eine Reihe der
`IKJPTGT`-CSECTs (`IKJEFT40`, `52`, `53`, `54`, `56`) unterscheidet sich nur in
einer Handvoll Bytes bei gleicher Länge — die sind mit überschaubarem Aufwand
zu schließen.

Greg Price merkte schon 2020 an, dass Dave die **TSO-Commands und TMP-Module zu
diesem Zeitpunkt noch nicht bearbeitet hatte** — was diese Tabelle bestätigt.

---

## 8. Bekannte Stolpersteine beim Build

### S013-18 im Job BLDIMAG (Mails 08./09.06.2022)

Mikes erster Anlauf scheiterte an:

```
IEC141I 013-18,IGG0191B,BLDIMAG,GEN,SYSIN,194,BLDSMP,MVSSRC.BLD.NEW.ASM
IEF450I BLDIMAG GEN - ABEND S013 U0000
```

**Ursache:** Ein Member fehlt im SYSIN-Dataset — konkret war
`MVSSRC.BLD.NEW.ASM` **komplett leer**. Diese Library wird vom ersten Ladejob
(`$$$LOAD`, Datei 3 des Tapes) gefüllt. Bei diesem Fehlerbild ist also der
**Ladejob** zu prüfen, nicht der Build.

### Sporadische S106-F und IEBCOPY-Programmcheck (Appendix H der Doku)

Von SMP angestoßene Assemblierungen brechen gelegentlich mit **S106-F**
(unkorrigierbarer E/A-Fehler beim Programmladen) ab, von SMP angestoßene
IEBCOPY-Läufe mit einem **Programmcheck bei CCW-Command X'00'**:

```
IEA703I 106- F EBB1102B SMP MODULE ACCESSED IFOX62
IEB139I I/O ERROR DURING READ - EBB1102B,SMP ,348,DA,SYM10114,00- OP,PROGRAM CHECK
```

Später kam **SD2D** hinzu (Program Fetch fand falschen Satztyp für ein
Overlay-Segment), sowohl bei `IEWL` als auch bei `IEBCOPY`.

- Tritt vor allem bei großen APPLY/ACCEPT-Läufen auf, meist in `EBB1102`.
- Reproduziert auf Hercules 3.12 und 4.00, auf TK3 wie auf TK4-.
- Dave hält es für einen **MVS-3.8-Bug, nicht für einen Hercules-Bug**, und
  vermutet ein Timing-Problem rund um PCI (Program Fetch und IEBCOPY nutzen
  beide PCI), möglicherweise ausgelöst durch das Windows-Dispatching.
- Hercules auf Realtime-Priorität zu setzen half nicht.
- **Der Fehler ist sporadisch — ein Neustart des Builds von vorn ist in der
  Regel erfolgreich.**

### Regression eigener USERMODs

Wer PTFs oder USERMODs auf sein TK3-System aufgebracht hat, die NUCLEUS,
SVCLIB, JES2 oder SMP betreffen, verliert diese in den MVSBLD-Libraries: Die
neue SMP-Umgebung weiß nichts von den TK3-Updates. Solche USERMODs müssen
nachgezogen werden, insbesondere alle `PRE`-Angaben müssen auf die PTFs des
Build-Prozesses umgestellt werden.

### TK4--Besonderheiten (Appendix A der Doku)

- Wegen **RAKF** scheitert `MAINT05Z` beim Update der `SYS1.LINKLIB` mit
  **913-38**: Von einem Job abgesetzte Jobs erben die Userid des Absenders
  nicht und laufen unter dem Default-User `PROD`. Abhilfe: `MAINT05Z` als
  **HERC01** von Hand submitten.
- TK4- hat eine andere I/O-Konfiguration; deshalb ist ein **I/O-Gen**
  erforderlich (`TK4IO1` bis `TK4IO2B`), vorbereitet durch `ZJW0011`
  (24 PF-Tasten für Konsolen) und `DSK0044`.
- Anschließend werden die TK4--Mods als Source-PTFs nachgezogen: `ZP60031`,
  `AY12275`/`OY12275`, `VS49603`, `ZP60005`, `ZP60013`, `ZP60017`, `ZP60023`,
  `SYZJ20X`, `TJES801`, `WM00017`, `ZJW0008`, `ZP60015`.
- Nach `ZCPYJES` ist beim nächsten IPL ein **CLPA** nötig (`R 0,CLPA` auf
  `IEA101A`), da `SYS1.LPALIB` verändert wurde.

---

## 9. Chronologie des Mailverkehrs

| Datum | Von | Kerninhalt |
|---|---|---|
| 18.12.2020 | Mike → Greg Price | BREXX/370 V2R3 ist draußen, V2R4 in Arbeit (`ADDRESS ISPEXEC` fertig, IRXEXCOM zu 90 %, eigene Host Command Environments). Frage: gefundene Sources passen nicht zu MVS 3.8j (`IKJCT431` 78.048 vs. 87.344). |
| 19.12.2020 | Greg Price → Mike | Beschreibt die Schleife aus Assemblieren, Disassemblieren und Vergleichen. Für `ALLOCATE REUSE` musste er ~8 Module disassemblieren. Verweist auf Dave Kreiss. |
| 21.12.2020 | Greg Price → Mike, cc Dave | Führt Dave ein: umfangreiche Massenänderungen am MVS-Source, lesbarere Registerkonvention, System-DSECTs statt PL/S-Mappings. Merkt an, dass TSO-Commands und TMP-Module noch offen sind. |
| 22.12.2020 | Dave → Greg, Mike | **Erste Projektübersicht.** Ziel SMP als Wartungsvehikel; NUCLEUS fertig und IPL-fähig, dann SVCLIB, CMDLIB, außerdem SMP und JES2. SMP-Mod für IEBUPDTE-Delete. LINKLIB/LPALIB/VTAM zu groß → Wechsel auf 3390-Themen: IPL funktioniert, Mod 2/3 hat ein DEB-Problem. Hinweis auf `DSKC191`. Dropbox- und OneDrive-Link. |
| 24.12.2020 | Dave → Mike | Arbeitet seit den frühen 1970ern als Systemprogrammierer mit MVS, aber wenig mit TSO-Internas. Alle CMDLIB-Module rekonstruiert und objektidentisch. Liste der aktualisierten `IKJCT`-Module. Schickt `ikjct.zip`. |
| 25.05.2021 | Mike → Dave | Sucht `IKJEFF*`-Sources; das GitHub-Repo `mvs38/MVS3.8-Source-Recovery` ist verschwunden. |
| 27.05.2021 | Dave → Mike | Link auf **den kompletten MVS-Source**: 7z-Archiv, ca. 52 MB gepackt, 756 MB entpackt, **5.528 Member**. Hat den GitHub-Auftritt gelöscht — kam mit Git nicht zurecht und wollte es nicht lernen. |
| 27.05.2021 | Mike → Dave | Frage nach dem Aktualitätsstand und **ob die Sources auf GitHub veröffentlicht werden dürfen** (`mainframed/mvs38_sources`, `mvslovers`). |
| 27.05.2021 | Dave → Mike | „Any module not in VTAMLIB, LINKLIB or LPALIB are current." Standalone-3390-IPL läuft, einige Probleme offen. **Die Frage nach der Veröffentlichung bleibt unbeantwortet.** |
| 03.06.2022 | Dave → Mike | Hohe Arbeitsbelastung, dazu ein SMP-Bug: SMP setzt mitten in APPLY/ACCEPT das Objektmodul-Directory zurück, Links schlagen fehl. Diverse kleinere FUNCTIONs und PTFs probiert, SMP-Loadmodule geprüft. „In other words stalled…." |
| 08.06.2022 | Mike → Dave | Erster eigener Build-Versuch: `$01SMPAL` bricht mit S013-18 ab, `MVSSRC.BLD.NEW.ASM` ist leer. Bittet um eine präzise Beschreibung des SMP-Problems für Jay Maynard. |
| 08.06.2022 | Dave → Mike | S013-18 = fehlendes SYSIN-Member. **Ausführliche Analyse des SMPWRK3-Directory-Resets** (siehe Abschnitt 6). |
| 09.06.2022 | Dave → Mike | Weitergabe der Adresse an Jay Maynard in Ordnung. Für das leere `NEW.ASM` den ersten Ladejob prüfen. |
| 01.07.2024 | Mike → Dave | Fragt nach aktuellem Stand und den neuesten Sourcen. |
| 02.07.2024 | Dave → Mike | Wenig passiert. **32.760-Track-Unterstützung (3390-27)** geschrieben, aber fehlerhaft und nicht diagnostiziert. **DSS370 vollständig gebaut, aber ungetestet** (`IQA*` in `NEW.ASM`, `NDSS370` in `SMP.LIB`). Dropbox-Link auf das letzte Installationspaket. |
| 02.07.2024 | Mike → Dave | Fragt nach dem konkreten Vorgehen beim Aktualisieren der Sources. |
| 03.07.2024 | Dave → Mike | **Beschreibt die Methodik** (siehe Abschnitt 2), erwähnt `COMPLMD` und liefert die **CSECT-Vergleichstabelle der IKJEFT-Module** (siehe Abschnitt 7). |

---

## 10. Artefakte und Downloads

Die in den Mails genannten Links (Stand jeweils zum Mailzeitpunkt; Verfügbarkeit
nicht geprüft):

| Datum | Inhalt | Link |
|---|---|---|
| 22.12.2020 | `BLDMVS.7z` — Installationspaket | `https://www.dropbox.com/s/y1g31sll213vdgb/BLDMVS.7z?dl=0` |
| 22.12.2020 | dasselbe auf OneDrive | `https://1drv.ms/u/s!Ajp_FMPdPVCkk2pMvzHkFTVAQ4Ib?e=kHSXWn` |
| 27.05.2021 | **Kompletter MVS-Source**, 52 MB gepackt / 756 MB entpackt / 5.528 Member | `https://1drv.ms/u/s!Ajp_FMPdPVCklgD6hVrav5ce-aAt` |
| 02.07.2024 | `BLDMVS.7z` — Installationstape und Doku | `https://www.dropbox.com/scl/fi/rsb9vzg0z9gm3vchovyaw/BLDMVS.7z?rlkey=kt4bimi1y4dz6cz07fps4eyfp&st=tm63bku5&dl=0` |
| laufend | **`BLDMVS.7z` — der aktuelle Stand**, von Dave als *„freely downloadable"* bezeichnet | `https://groups.io/g/turnkey-mvs/files/MVS%203.8J%20Source%20Recovery/BLDMVS.7z` |

Die groups.io-Ablage ist Daves eigene, öffentliche Bezugsquelle und damit
maßgeblich. Unser lokaler Stand (`BLDMVS.AWS` vom 16.09.2021, Instruktionen
Version 2.1 vom 05.07.2020) ist mutmaßlich älter und gehört abgeglichen.

Nicht mehr erreichbar: `https://github.com/mvs38/MVS3.8-Source-Recovery` —
Dave hat das Repository gelöscht (Mail 27.05.2021).

Lokal in diesem Repository vorhanden:

- `Dave Kreiss - MVS from Source/BLDMVS/` — Installationspaket: `BLDMVS.AWS`
  (190 MB Tape), `$$LOAD$$.JCL`, die zwölf leeren DASD-Volumes und die
  Instruktionen als PDF.
- `Dave Kreiss - MVS from Source/MVSBLD/` — 5.528 `.ASM`-Member.

---

## 11. Offene Punkte

1. **SMPWRK3-Directory-Reset** — der eigentliche Blocker. Nächster
   naheliegender Schritt wäre der von Dave selbst genannte, aber nie
   ausgeführte: den SMP-Source daraufhin durchsehen, wie das Directory
   zurückgesetzt wird, und klären, ob `STOW` unter MVS 3.8 ein Löschen des
   Directories überhaupt zulässt.
2. **Lizenz- und Veröffentlichungsstatus ungeklärt.** Mike hat am 27.05.2021
   ausdrücklich gefragt, ob die Sources nur privat genutzt oder auf GitHub
   gestellt werden dürfen. Dave ist in seiner Antwort **nicht darauf
   eingegangen**. Vor einer Veröffentlichung sollte das geklärt werden.
3. **LINKLIB und LPALIB** sind nur angefangen und laut Doku funktional
   fragwürdig. **VTAMLIB und TELCMLIB** sind gar nicht bearbeitet.
4. **3390 Mod 2/3** — DEB-Problem ungelöst.
5. **3390-27 / 32.760 Tracks** — Code vorhanden, Fehler nicht diagnostiziert.
6. **DSS370** — komplett gebaut, aber nie getestet.
7. **CMDLIB** ist objektidentisch, aber **funktional nie verifiziert**.
8. **IDCAMS-/ICKDSF-Parameter-Dictionaries** — Generierungsprozess (`COMGEN`)
   fehlt, Layout nur teilweise dekodiert.
9. **Ergebnis der Anfrage an Jay Maynard** ist im Mailverkehr nicht dokumentiert.
