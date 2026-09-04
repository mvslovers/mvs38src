# Runbook — wie die Dinge praktisch funktionieren

Betriebswissen für dieses Projekt: MVS/CE starten, IPLen, Kommandos absetzen,
Jobs einreichen. Adressiert an Mensch **und** Agent — was hier steht, darf ein
Agent ausführen, ohne nachzufragen.

Ergänzt den [Arbeitsplan](arbeitsplan.de.md) um das *Wie*.

> **Statuskennzeichnung.** Dieses Dokument entsteht vor dem ersten Lauf. Jede
> Prozedur trägt einen Status:
> **✅ verifiziert** · **📄 aus der Konfiguration abgeleitet** (plausibel, aber
> noch nicht ausgeführt) · **❓ offen**
>
> Wer eine Prozedur zum ersten Mal ausführt, korrigiert sie hier und setzt den
> Status auf ✅. Das ist Teil der Aufgabe, kein Nachgedanke.

> **Bezugsversion: noch 2.1.4, soll aber v3.0.0 werden.** Alle
> Konfigurationsangaben unten stammen aus `MVSCE.release.v2.1.4.tar`, der lokal
> vorliegenden Fassung. Aktuell ist **v3.0.0 „UNEXPECTED SLOTH" vom 01.08.2026**
> (`MVSCE.release.v3.0.0.tar`, 199 MB). Reihenfolge der Releases: 2.1.4
> (08.07.2026) → 2.1.5 (13.07.2026) → 3.0.0 (01.08.2026).
>
> **Der Umstieg lohnt sich:** Ab dem aktuellen Stand installiert
> `jcl/customize.jcl` beim Sysgen standardmäßig **OPNTERSE, UFSD, FTPD, HTTPD und
> MVSMF** — der Hauptkanal des Agenten ist also bereits an Bord. **Beim
> Versionswechsel ist dieses Dokument gegenzuprüfen**: Geräteadressen, Skripte
> und Pfade können sich ändern.

---

## 1. Aufbau von MVS/CE 2.1.4

📄 *aus `MVSCE.release.v2.1.4.tar` gelesen*

```
MVSCE/
├── conf/
│   ├── local.cnf              # Hercules-Hauptkonfiguration — nicht editieren
│   ├── mvsce.rc               # Startskript: IPL + hao-Automatik
│   └── local/custom.cnf       # ► HIER kommen eigene Ergänzungen rein
├── DASD/                      # mvsres.3350, mvs000.3350, smp000.3350,
│                              # work00/01.3350, syscpk.3350, spool1, page00,
│                              # pub000.3380, pub001.3390, sortw1-6.2314
└── MVP/                       # Paketmanager mit Zusatzsoftware
```

`conf/local/custom.cnf` trägt im Auslieferungszustand nur den Kommentar
*„This conf file can be used to add custom configs"* — das ist der vorgesehene
Ort für alles, was wir hinzufügen. `local.cnf` bleibt unangetastet, damit ein
MVS/CE-Update nicht mit unseren Änderungen kollidiert.

### Wichtige Geräteadressen

| Adresse | Typ | Zweck |
|---|---|---|
| `0010` | 3270 | Master-Konsole (über `CNSLPORT 3270`) |
| `0009` | 3215-C | Alternativkonsole — **für Automatisierung erforderlich** |
| `0015` | 1403 | Hardcopy der Master-Konsole → `mvslog.txt` |
| `000C` | 3505 | Kartenleser, sockdev `localhost:3505`, **ASCII** |
| `001A` | 3505 | Kartenleser, sockdev `localhost:3506`, **EBCDIC** |
| `000D` | 3525 | Kartenstanzer JES2 → `punchcards/pch00d.txt` |
| `0150` | — | IPL-Volume (`mvsres`) |

Weitere Eckdaten aus `local.cnf`: `ARCHMODE S/370`, `MAINSIZE 16`, `NUMCPU 2`,
`CODEPAGE 819/1047`, `OSTAILOR QUIET`.

---

## 2. Starten und IPLen

📄 *aus `conf/mvsce.rc` abgeleitet*

MVS/CE bringt dafür ein Startskript mit:

```sh
cd /pfad/zu/MVSCE
./start_mvs.sh          # = hercules -f conf/local.cnf -r conf/mvsce.rc -o hercules.log
```

`mvsce.rc` erledigt den IPL selbst:

```
facility enable HERC_TCPIP_EXTENSION
facility enable HERC_TCPIP_PROB_STATE
facility enable herc_370_extension
IPL 150
hao tgt input for console 0:0009
hao cmd /
hao tgt $HASP426 SPECIFY OPTIONS - HASP-II, VERSION JES2 4.1
hao cmd /r 0,noreq
```

Bemerkenswert daran — und der Grund, warum ein Agent hier überhaupt etwas
ausrichten kann: **`hao` ist der Hercules Automatic Operator.** Er reagiert auf
Konsolmeldungen mit vorher festgelegten Kommandos. MVS/CE benutzt das bereits,
um `$HASP426` automatisch mit `/r 0,noreq` zu beantworten. Derselbe Mechanismus
steht uns für eigene Automatik offen.

### Wenn ein CLPA nötig ist

Nach jeder Änderung an `SYS1.LPALIB` — etwa nach `ZCPYJES` — muss der nächste
IPL die Link Pack Area neu aufbauen. Auf die Meldung `IEA101A` antwortet man:

```
/r 0,clpa
```

📄 Ob `mvsce.rc` das bereits abfängt, ist **❓ offen** — beim ersten IPL prüfen
und hier nachtragen.

### Nach dem IPL: HTTPD starten

⚠️ **Das ist der wichtigste Handgriff nach jedem IPL.**

```
/s HTTPD
```

MVS/CE startet den Webserver nicht von selbst, und **mvsMF läuft als CGI-Modul
unter HTTPD**. Solange HTTPD nicht läuft, hat der Agent seinen Hauptkanal nicht:
keine Jobs einreichen, keinen Status abfragen, keinen Spool holen.

Das ist kein Versäumnis unsererseits, sondern Absicht des Projekts. Die
MVS-sysgen-Dokumentation sagt es ausdrücklich: die Pakete werden
*„installed but not started"* eingespielt. Im gesamten Repository gibt es kein
`S HTTPD` — weder in `COMMND00` (dort stehen nur `S NET` und die JES2-Parameter)
noch sonstwo. Der Start bleibt Sache des Betreibers.

Daraus folgt eine Reihenfolge, die ein Agent kennen muss: Unmittelbar nach dem
IPL steht **nur** die Hercules-Konsole zur Verfügung. Der Notweg aus Abschnitt 3b
ist also nicht bloß Rückfallebene für den Störungsfall — er ist der einzige Weg,
über den sich HTTPD überhaupt starten lässt. Wer die Webkonsole nicht aktiviert
hat, kann nach einem IPL nichts automatisieren.

### Abnahme eines erfolgreichen IPL

Ein Agent braucht ein maschinelles Erfolgskriterium, keinen Blick auf den
Bildschirm. Vorschlag, **❓ beim ersten Lauf zu bestätigen**:

1. `mvslog.txt` (Hardcopy von Gerät `0015`) auf die Startmeldungen prüfen
2. JES2 ist oben, wenn `$HASP492` erschienen ist
3. TSO ist oben, wenn die `TSO`-Prozedur gestartet ist
4. `/s HTTPD` abgesetzt und quittiert
5. Gegenprobe: eine mvsMF-Anfrage beantwortet sich — **das ist das eigentliche
   Abnahmekriterium**, denn erst damit ist der Kanal des Agenten offen

**Wichtiger als das Positivkriterium ist das Negativkriterium:** Ein Wait-State
oder ein hängender IPL äußert sich als *Ausbleiben* von Meldungen. Der Agent
braucht deshalb einen **Zeitdeckel** — kommt binnen n Minuten keine erwartete
Meldung, gilt der IPL als gescheitert und wird eskaliert, statt weiter zu warten.

---

## 3. Die drei Wege, Kommandos abzusetzen

### a) mvsMF — der Normalweg für den Agenten ✅ *Verfahren dokumentiert, Setup ❓*

Die z/OSMF-REST-API. Damit gehen Jobs einreichen, Status abfragen,
Spool-Output holen, Datasets lesen und schreiben sowie Konsolkommandos
absetzen.

Für den Agenten ist das der bevorzugte Weg: strukturierte Antworten, keine
Bildschirminhalte zu parsen.

Zwei Punkte, die man wissen muss:

- **`retcode` braucht `NOTIFY=` in der Jobkarte.** `HASPSSSM` schreibt
  `JCTCNVRC` nur für Jobs, die einen Notify angefordert haben. MVS/CE bringt den
  dafür nötigen USERMOD `SYZJ201` mit.
- **Darum muss sich niemand kümmern:** mvsMF ergänzt `NOTIFY=$MVSMF`
  automatisch bei jeder eingereichten Jobkarte, die keines mitbringt. Eine Karte
  mit eigenem `NOTIFY` bleibt unangetastet.

### b) Hercules-Webkonsole — der Notweg 📄 *Syntax aus dem Hercules-Source*

Wenn mvsMF nicht läuft — nicht installiert, abgestürzt, oder das System ist
gerade erst hochgekommen — bleibt die HTTP-Konsole von Hercules.

**Sie ist in MVS/CE 2.1.4 nicht aktiviert.** Dafür in `conf/local/custom.cnf`:

```
HTTP PORT 8038 NOAUTH
HTTP START
```

Danach `http://localhost:8038/` im Browser. Wahlweise mit Authentifizierung:
`HTTP PORT 8038 AUTH <user> <password>`.

Randbedingung aus `httpserv.c`: Der Port muss **≥ 1024** sein (einzige Ausnahme
ist 80). Ein kleinerer Port wird abgewiesen.

Über diesen Weg gehen Hercules-Kommandos (`ipl 150`, `devinit`, `devlist`,
`stopall`) und, mit `/`-Präfix, MVS- und JES2-Kommandos.

### c) tn3270 auf die Master-Konsole — Handbetrieb

`CNSLPORT 3270`, Gerät `0010`. Für alles, was ein Mensch sehen will.

### Hercules-Kommando oder MVS-Kommando?

An der Hercules-Konsole gilt:

| Eingabe | Geht an |
|---|---|
| `ipl 150`, `devinit`, `devlist` | Hercules |
| `/d a,l`, `/r 0,clpa`, `/$dj1` | MVS bzw. JES2 |

Das `/`-Präfix ist der Unterschied. Wer es vergisst, redet mit dem falschen
Empfänger — meist folgenlos, gelegentlich nicht.

---

## 4. Jobs einreichen

📄 *aus `local.cnf` abgeleitet*

**Über mvsMF** (bevorzugt): `PUT /zosmf/restjobs/jobs`.

**Über den Kartenleser** als Notweg: MVS/CE hat zwei sockdev-Leser — `000C` auf
`localhost:3505` (ASCII) und `001A` auf `localhost:3506` (EBCDIC). JCL wird
einfach auf den Port geschrieben:

```sh
cat job.jcl | nc localhost 3505
```

**Über `devinit`** von der Hercules-Konsole, wie in Daves Anleitung und bei
Moseley üblich:

```
devinit 000C /pfad/zu/job.jcl
```

---

## 5. Tape mounten

📄 Wird für Daves `BLDMVS.AWS` gebraucht.

```
devinit 0480 /pfad/zu/BLDMVS.AWS
```

❓ Ob MVS/CE ein Bandlaufwerk auf `0480` hat, ist **noch zu prüfen** — Daves
Anleitung setzt das für TK3/TK4- voraus. Falls nicht vorhanden, in
`conf/local/custom.cnf` ergänzen.

---

## 6. Instanzen auf `mvsdev.lan`

❓ *Geplant, noch nicht aufgesetzt*

Die Systeme laufen nicht auf dem Mac, sondern auf **`mvsdev.lan`**, jeweils
Hercules in einer eigenen tmux-Session. Vorgesehen sind **drei Instanzen**,
sobald MVS/CE 3.0.1 vorliegt.

| Instanz | Zweck | Wer greift zu | Lebensdauer |
|---|---|---|---|
| `mvsce-lab` | Alle **anderen** Projekte. Ständig verfügbar. | Mensch | dauerhaft |
| `mvsce-src` | Dieses Projekt: PTFs einspielen, APPLY/ACCEPT, IPL-Test (M7) | Agent | wird regelmäßig aus dem Template zurückgesetzt |
| `mvsce-exp` | Dieses Projekt: Experimente, vor allem die **SMPWRK3-Reproduktion** | Agent und Mensch | Wegwerfsystem |

### Warum zwei für dieses Projekt

Weil die beiden Aufgaben sich gegenseitig blockieren würden. Die
SMPWRK3-Analyse besteht darin, **absichtlich große APPLY-Läufe zu fahren, bis
der Fehler auftritt** — bei Dave dauerte ein Durchlauf gut zwei Stunden, und das
Ergebnis ist ein kaputtes System. Liefe das auf derselben Instanz, auf der wir
PTFs verifizieren, stünde die Verifikation ständig still. Getrennt können beide
Stränge parallel laufen.

### Die Baseline ist keine Instanz

⚠️ **Wichtige Unterscheidung.** Die Baseline aus M0 ist ein
**eingefrorener, geprüfsummter Satz Volume-Dateien, der nie läuft** — kein
laufendes System, keine tmux-Session.

Der Grund: Jeder IPL verändert die Volumes. SMF schreibt, Page-Datasets werden
benutzt, JES2 aktualisiert seinen Checkpoint, der Katalog ändert sich. Ein
System, das läuft, ist kein unveränderliches Orakel mehr. Die drei Instanzen
oben werden **aus** dem Template erzeugt, das Template selbst bleibt unberührt.

Daraus folgt auch: **Zurücksetzen muss billig und skriptbar sein.** Der Agent
wird `mvsce-src` regelmäßig kaputtmachen — ein fehlgeschlagenes ACCEPT, ein
hängender IPL, ein Wait-State. „Instanz aus Template neu erzeugen" gehört
deshalb als Prozedur hierher, nicht als Handarbeit.

### Zugriffsregel für den Agenten

| Instanz | Agent |
|---|---|
| `mvsce-lab` | **kein Zugriff.** Das ist deine Arbeitsumgebung für andere Projekte |
| `mvsce-src` | Vollzugriff, darf kaputtgehen |
| `mvsce-exp` | Vollzugriff, soll kaputtgehen |
| Baseline-Template | **nur lesend** |

### Portbelegung

Drei Instanzen auf einem Host brauchen einen Plan. Aus
`~/repos/mvs/REFCARD.md` ist die Stolperfalle bereits bekannt: Bei zwei
Systemen auf einem Host mussten die **Reader-Ports** kollisionsfrei getrennt
werden (`MVP/MVP.ini`, `ascii_reader` / `ebcdic_reader`), sonst kommt
`MVP999E UNABLE TO FIND …`.

❓ **Noch festzulegen** — je Instanz: tn3270, mvsMF/HTTPD, FTP, die beiden
Reader, Hercules-Webkonsole. Tabelle hier eintragen, sobald vergeben.

### Wo laufen die Werkzeuge?

Eine Frage, die früh geklärt gehört: Die Werkzeugkette (`as370`, `dasm370`,
`cmplmd370`, die Hercules-DASD-Utilities) läuft auf dem **Mac**, die Volumes
liegen auf **`mvsdev.lan`**.

Für M0 und M1 ist das unkritisch: Die Extraktion braucht **kein laufendes MVS**,
nur die Volume-Dateien, und sie passiert **einmal**. Der einfachste Weg ist
also, das Baseline-Template einmal auf den Mac zu holen, dort alles zu
extrahieren und die Ergebnisse ins Repo zu legen.

Die Instanzen auf `mvsdev.lan` werden erst ab **M7** wirklich gebraucht — wenn
PTFs eingespielt und getestet werden. **Der Aufbau der drei Systeme steht
deshalb nicht auf dem kritischen Pfad** und muss nicht auf 3.0.1 warten, um mit
M0 anzufangen.

### ⚠️ Daves 3390-Mods beschädigen den Freispeicher

Dave selbst dazu: Die 3390-2- und -3-Modifikationen auf seinem Installationstape
haben **mindestens einen Fehler in der Freispeicherberechnung, der den freien
Platz eines Volumes beschädigt**. Seine Empfehlung: nicht auf ein
Produktivsystem bringen.

Für uns heißt das konkret:

- Seine Phasen 4 und 5 (`DSKK7xx`–`9xx`, `DSKL7xx`–`9xx`) enthalten genau diese
  Erweiterungen. Wer seinen Build laufen lässt, fährt sie mit.
- Der wahrscheinlichste Anlass dafür ist die **SMPWRK3-Reproduktion** — und
  genau dafür ist `mvsce-exp` da. Ein Wegwerfsystem, dessen Volumes nach jedem
  Versuch neu aus dem Template kommen.
- Auf `mvsce-src` haben Daves Build und seine 3390-Mods **nichts zu suchen**.
- Unsere eigentliche Arbeitsweise ist davon nicht betroffen: Wir lesen seinen
  **Source** und assemblieren auf dem Host. Gefährlich wird nur das Ausführen
  seines Builds auf einem echten System.

### Noch zu klären

- [ ] Portbelegung für drei Instanzen festlegen
- [ ] tmux-Sessionnamen und Startskripte je Instanz
- [ ] Prozedur „Instanz aus Template neu erzeugen" schreiben und testen
- [ ] Zugriff des Agenten auf `mvsdev.lan` einrichten (mvsMF über Netz)
- [ ] Entscheiden, ob das Baseline-Template auf dem Mac oder auf `mvsdev.lan`
      liegt — und wie die Prüfsummen über beide Orte konsistent bleiben

## 6b. Instanz aus dem Template erzeugen

Alles, was schreibt — APPLY, ACCEPT, `ZCPY*`, IPL — läuft auf einer Instanz,
nie auf dem Template.

```sh
cp -R MVSCE-template MVSCE-src   # DASD/ mitkopieren
```

In der Kopie eine eigene Hercules-Konfiguration verwenden, damit nie
versehentlich die Template-Volumes angezogen werden — das ist die häufigste Art,
sich eine Baseline zu zerstören.

**Regel für den Agenten:** Lesend auf das Template (`dasdls`, `dasdpdsu`,
heruntergefahren), schreibend ausschließlich auf `mvsce-src` oder `mvsce-exp`.

---

## 7. Loadmodule ohne laufendes MVS holen

📄 Der Kern der host-seitigen Arbeitsweise. Werkzeuge aus
`~/repos/hyperion` (noch zu bauen).

```sh
dasdls   -info mvsres.3350                      # Datasets auf dem Volume
dasdpdsu mvsres.3350 SYS1.LPALIB                # Member einzeln herausziehen
dasdcat  mvsres.3350 "SYS1.PARMLIB(IEASYS00)"   # ein Member ansehen
file370 -v IKJPTGT                              # ESD, CSECTs, IDRs
```

⚠️ **Nur bei heruntergefahrenem Hercules.** Ein laufendes MVS und ein
gleichzeitig lesendes `dasd*`-Werkzeug auf derselben Datei ergeben
inkonsistente Ergebnisse.

---

## 8. Herunterfahren

📄 *aus `MVSCE/SCRIPTS/SHUTDOWN.RC` gelesen*

⚠️ **Vorher HTTPD stoppen — `SHUTDOWN.RC` kennt es nicht.**

```
/p HTTPD
```

Das mitgelieferte Skript fährt weder HTTPD noch FTPD noch mvsMF herunter. Ohne
diesen Schritt wird der Webserver vom Quiesce überrollt.

Das gilt **auch für den aktuellen Stand des Projekts**: In `SCRIPTS/SHUTDOWN.RC`
im MVS-sysgen-Repository kommen `HTTPD`, `FTPD` und `MVSMF` an keiner Stelle vor.
Die Pakete werden seit Neuerem standardmäßig installiert, das Shutdown-Skript
weiß aber nichts davon. Eine Meldung an das Projekt lohnt sich (siehe
[TODO.md](../TODO.md), Punkt 1b).

Danach das mitgelieferte Skript — **nicht von Hand herunterfahren**, MVS/CE
bringt eine vollständige Prozedur mit. An der Hercules-Konsole:

```
script SCRIPTS/SHUTDOWN.RC
```

Das Skript setzt zuerst `hao`-Regeln, die den weiteren Ablauf selbst steuern,
und stößt dann die Quiesce-Schritte an:

| Auslöser | Reaktion |
|---|---|
| `HASP099` | `script SCRIPTS/pjes2` — JES2 beenden |
| `HASP085` | `script SCRIPTS/zeod` — `Z EOD` |
| `IEE334I` | `script SCRIPTS/quiesce` |
| `HHC00814I … SIGP Stop` | `script SCRIPTS/poweroff` |
| `nn IKT010D` | `/R nn,FSTOP` |

Die Quiesce-Schritte davor, in dieser Reihenfolge: `$CA,ALL` (automatische
Kommandos abbestellen), `SWITCH SMF`, `MODIFY TSO,USERMAX=0` (keine neuen
Logons), `$PI` (Initiatoren), Drucker/Stanzer/Leser einzeln, `STOP TSO`,
`HALT net,quick`.

**Das ist zugleich die Vorlage für eigene Automatik.** MVS/CE zeigt hier
vorbildlich, wie man `hao` einsetzt: auf eine Meldung warten, darauf reagieren,
statt blind Pausen zu setzen. Wer für den Agenten eigene Abläufe baut, sollte es
genauso machen.

⚠️ An der Hercules-Konsole beendet `quit` den Emulator sofort — das entspricht
einem Stromausfall, wenn MVS nicht vorher sauber heruntergefahren wurde.

---

## 9. Was ein Agent darf

| Erlaubt | Nicht erlaubt |
|---|---|
| Baseline-Volumes **lesen** (`dasdls`, `dasdpdsu`, `dasdcat`) | Baseline-Volumes beschreiben |
| Klon starten, IPLen, Jobs einreichen, Konsole lesen | Auf dem Arbeitssystem des Menschen arbeiten |
| APPLY/ACCEPT auf dem Klon | Übernahme in ein anderes als das Klon-System |
| Bei ausbleibendem IPL-Erfolg nach Zeitdeckel eskalieren | Unbegrenzt auf eine Meldung warten |
| Nach dem IPL `/s HTTPD`, vor dem Shutdown `/p HTTPD` | Den Shutdown fahren, ohne HTTPD vorher zu stoppen |
| Auf `mvsce-src` und `mvsce-exp` alles | **`mvsce-lab` anfassen** — das ist die Arbeitsumgebung für andere Projekte |
| Daves Build und seine 3390-Mods **nur** auf `mvsce-exp` | Sie auf irgendein System bringen, dessen Volumes zählen — sie beschädigen den Freispeicher (siehe unten) |
| Eine kaputte Instanz aus dem Template neu erzeugen | Das Baseline-Template beschreiben |
| Diese Datei korrigieren, wenn eine Prozedur nicht stimmt | Eine Prozedur stillschweigend anders ausführen als hier beschrieben |

---

## 10. Noch zu klären

- [ ] Fängt `mvsce.rc` die `IEA101A` bereits ab, oder ist `/r 0,clpa` manuell
      nötig?
- [ ] Bandlaufwerk auf `0480` vorhanden?
- [ ] Maschinelles Abnahmekriterium für einen erfolgreichen IPL festlegen und
      hier eintragen
- [ ] Zeitdeckel für IPL und für Jobs festlegen
- [ ] `hao`-Regeln für unsere eigenen Automatikfälle sammeln — `SHUTDOWN.RC` ist
      die Vorlage
- [ ] Die Skripte unter `MVSCE/SCRIPTS/` durchsehen; dort steckt vermutlich
      weiteres Betriebswissen, das hierher gehört
- [ ] mvsMF-Setup auf dem lokalen MVS/CE dokumentieren (Port, Start, Prüfung)
- [ ] **`SHUTDOWN.RC` um HTTPD erweitern**, statt `/p HTTPD` jedes Mal von Hand
      abzusetzen — eine eigene Kopie des Skripts oder eine zusätzliche
      `hao`-Regel. Solange das nicht passiert ist, gehört der Handgriff in jede
      Abschaltprozedur
- [ ] Prüfen, ob sich `/s HTTPD` per `hao` an den IPL hängen lässt, damit der
      Kanal des Agenten ohne Zutun offen ist
- [ ] Auf **v3.0.0** umstellen und dieses Dokument gegenprüfen
- [ ] Nach dem Umstieg feststellen, **welche HTTPD- und mvsMF-Stände** gebacken
      sind. Die Konsolendienste von mvsMF brauchen laut dessen README
      `httpd ≥ 4.0.0-dev` (`cgictx`-API)

## Verwandte Dokumente

- `~/repos/mvs/REFCARD.md` — Betriebs-Spickzettel für die **öffentlichen
  Demosysteme** (TK5 und MVS/CE auf dem Hetzner-Server). Anderer Aufbau als
  hier, aber die Kommandos und die Konsolenlogik sind dieselben.
- `~/repos/mvs/jes2-commands.md` — vollständige JES2-Operator-Kommandoreferenz,
  aus `HASPCOMM` extrahiert.
