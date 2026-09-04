# MVS 3.8j aus Source — Arbeitsplan für den Neustart

Stand: 2026-09-04. Dieser Plan nimmt Dave Kreiss' Projekt wieder auf, wechselt
aber Zielsystem, Werkzeuge und Arbeitsweise.

Grundlagen: [kreiss-projekt.de.md](kreiss-projekt.de.md)
(Stand des Kreiss-Projekts) und `Build MVS From Source Instructions.pdf`.

> English version: [arbeitsplan.en.md](arbeitsplan.en.md)

**Ersetzt** `MVSSRC_BAK/SYSGEN-UND-SOURCE-BUILD-ARBEITSPLAN.md` (2026-09-03).
Jener Plan ging von einem selbst durchgeführten Jay-Moseley-SYSGEN aus. Das
entfällt: MVS/CE **ist** ein fertiger Moseley-Sysgen. Die dortigen Warnungen zur
Vermischung von Moseley-Baseline und Kreiss-Build gelten unverändert weiter und
sind in Abschnitt 5 übernommen.

---

## 1. Wohin das führen soll

Zwei Sätze:

**Die Wiederherstellung läuft auf dem Host, MVS ist nur noch Orakel und
Laufzeitumgebung.** Und: **Am Ende bekommt ein KI-Agent eine Modulliste und
arbeitet sie autonom ab.**

Der zweite Satz ist die eigentliche Anforderung, und er bestimmt jede
Entwurfsentscheidung im Rest dieses Dokuments. Alles muss maschinenlesbar,
deterministisch und ohne menschliches Urteil entscheidbar sein.

Dave hat den Zyklus aus Assemblieren, Disassemblieren und Vergleichen auf MVS
gefahren — jeder Durchlauf ein SMP-Job, jede Iteration Minuten bis Stunden. Bei
einem Agenten, der hunderte Iterationen pro Modul braucht, ist das nicht
finanzierbar. Also verlagern wir den Zyklus auf den Mac:

```
                    ┌─────────────────── HOST ───────────────────┐
                    │                                            │
  MVS/CE-Volumes ──►│  dasdls/dasdpdsu ──► LMOD-Extrakt          │
  (mvsres, mvs000)  │                          │                 │
                    │                          ▼                 │
                    │  file370/idrdump370 ──► CSECT + IDR +       │
                    │                         Eyecatcher         │
                    │                          │                 │
                    │        ┌─────────────────┴──────────┐      │
                    │        ▼                            ▼      │
                    │  dasm370 (neu)              vorhandener     │
                    │  LMOD ──► Assembler         Source          │
                    │        │                    (MVSBLD, IKJ,   │
                    │        │                     stben, MVT)    │
                    │        └──────────┬─────────────────┘       │
                    │                   ▼                         │
                    │            as370 ──► OBJ                    │
                    │                   │                         │
                    │                   ▼                         │
                    │   cmplmd370: OBJ vs. DLIB-OBJ (primär)      │
                    │              bzw. vs. LMOD-CSECT            │
                    │                   │                         │
                    │             ┌─────┴──────┐                  │
                    │        identisch      Differenz             │
                    │             │              │                │
                    │             ▼              └──► Agent-      │
                    │        Git-Commit               Iteration   │
                    │             │                               │
                    └─────────────┼───────────────────────────────┘
                                  ▼
                        SMP-PTF (xmit370 / RECV370)
                                  │
                                  ▼
                    ┌────────── MVS/CE ──────────┐
                    │  APPLY / ACCEPT            │
                    │  IPL- und Funktionstest    │
                    │  (Steuerung via mvsMF)     │
                    └────────────────────────────┘
```

Der Zweck ist **keine einzelne Funktion, sondern eine Grundlage**, und das Ziel
hat zwei Stufen:

1. **Ein Source-Baum auf DLIB-Stand** — der Stamm, distributionsunabhängig.
2. **MVS/CE künftig aus diesem Source bauen** — statt aus den IBM-Bändern.

Erst die zweite Stufe macht die erste dauerhaft nützlich. Ein Source-Baum, der
nur danebenliegt, veraltet; einer, aus dem das System tatsächlich gebaut wird,
bleibt zwangsläufig aktuell.

### Der Anknüpfungspunkt an MVS/CE

MVS/CE wird von `sysgen.py` gebaut, und dessen Schrittfolge nennt die Nahtstelle
selbst:

```
step_01_build_starter        Startersystem
step_02_install_smp4         SMP4 installieren        ← tape/zdlib1.het
step_03_build_dlibs          DLIBs bauen              ← tape/zdlib1.het   ◄── HIER
step_04_system_generation    Stage 1 / Stage 2 aus den DLIBs
step_05_usermods             Moseleys USERMODs
…
step_13_customize            MVP-Pakete (UFSD, FTPD, HTTPD, MVSMF …)
```

**`step_03_build_dlibs` erzeugt die DLIBs aus dem IBM-Distributionsband
`zdlib1.het`. Alles danach leitet sich aus diesen DLIBs ab.**

Damit ist der Weg zum Ziel klar umrissen: Wenn wir den DLIB-Inhalt **aus unserem
Source erzeugen** können, tritt er an die Stelle des Ergebnisses von Schritt 03 —
und die Schritte 04 aufwärts bauen daraus ein vollständiges MVS/CE, ohne dass
daran etwas geändert werden müsste.

Das ist zugleich die Begründung dafür, warum die DLIB-Ebene und nicht die
Target-Ebene der Maßstab ist (Abschnitt 5): **Es ist genau die Ebene, an der
MVS/CE selbst ansetzt.**

*Einschränkung: Die Schrittfolge ist aus den Funktionsnamen und den
`devinit`-Aufrufen in `sysgen.py` gelesen. Die Einzelheiten von `step_03` sind
noch zu prüfen, bevor daraus ein Bauplan wird.*

> **Hinweis zur Vorgeschichte:** In den Mails von 2020 bis 2024 ist die
> BREXX/370-Integration in TSO (`IKJCT430`, `IKJEFT55`, die TMP-Module) der
> Anlass für alles. **Das ist sie nicht mehr.** Sie taugt weiterhin als
> Testgelände, weil Daves CSECT-Vergleich von 2024 dort bekannte Ziele
> unterschiedlicher Schwierigkeit liefert — aber sie ist kein Ziel des Projekts.
> `IKJ/REXX_INTEGRATION_PLAN.md` ist damit historisch, nicht richtungsweisend.

### Warum dieser Weg am Blocker vorbeiführt

Daves Projekt steht seit 2022 am SMPWRK3-Directory-Reset (siehe Zusammenfassung,
Abschnitt 6). Der Fehler tritt bei **großen** APPLY/ACCEPT-Läufen auf, zuerst bei
`EBB1102`. Wenn Assemblieren und Vergleichen lokal passieren, macht SMP nur noch
das, wofür wir es wirklich brauchen: kleine, fertige PTFs anwenden und die
Bibliotheken verwalten. Die Massen-APPLYs, die den Bug auslösen, entfallen.

Der Bug ist damit nicht gelöst — aber er blockiert nicht mehr den Fortschritt.

---

## 2. Das Zielbild: der autonome Modul-Agent

### Warum das überhaupt funktionieren kann

Autonomie scheitert normalerweise daran, dass ein Agent nicht sicher weiß, ob er
fertig ist. Hier ist das anders: **Der Erfolgsmaßstab ist objektiv und
maschinell prüfbar.** Der assemblierte CSECT ist byte-identisch zum CSECT im
Loadmodul, oder er ist es nicht. Kein Ermessen, keine Interpretation, kein
Selbstbetrug möglich.

Das ist die entscheidende Eigenschaft dieses Vorhabens, und sie muss geschützt
werden: **Der Agent darf ein Modul niemals aufgrund seiner eigenen Einschätzung
als fertig melden, sondern ausschließlich aufgrund des Exit-Codes von
`cmplmd370`.** Alles andere in diesem Abschnitt ist Mechanik; das hier ist das
Prinzip.

### Der Auftrag pro Modul

Der Agent bekommt eine Liste. Ein Eintrag ist minimal ein Modulname; alles
Weitere ermittelt er selbst:

```yaml
# work/queue.yaml
- lmod: IKJPTGT
  csect: IKJEFT40
  lib: LPALIB
  prio: 1
- lmod: IKJPTGT
  csect: IKJEFT55
  lib: LPALIB
  prio: 1
- lmod: IKJEFT02
  csect: IKJEFT02
  lib: LPALIB
  prio: 2
  budget: 200        # optional: abweichendes Iterationsbudget
```

### Der Zustandsautomat

```
                          ┌─────────┐
                          │   NEU   │
                          └────┬────┘
                               │ dasdpdsu + file370 + idrdump370
                               ▼
                        ┌──────────────┐
                        │ EXTRAHIERT   │  LMOD, CSECT, Länge,
                        └──────┬───────┘  Eyecatcher, IDRs bekannt
                               │ Index über alle Source-Bestände
                               ▼
                     ┌───────────────────┐
                     │ KANDIDATEN-SUCHE  │
                     └─────────┬─────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        ▼                      ▼                      ▼
  ┌───────────┐         ┌────────────┐         ┌─────────────┐
  │ Fall A/B  │         │  Fall C    │         │   Fall D    │
  │ Source da │         │ Source da, │         │ kein Source │
  │           │         │ weit weg   │         │             │
  └─────┬─────┘         └─────┬──────┘         └──────┬──────┘
        │                     │                       │
        │                     │                       │ dasm370
        │                     │                       ▼
        │                     │              ┌─────────────────┐
        │                     │              │ ROHDISASSEMBLAT │
        │                     │              └────────┬────────┘
        │                     │                       │
        └─────────┬───────────┴───────────────────────┘
                  ▼
        ┌───────────────────────┐
        │   ANGLEICH-SCHLEIFE   │◄────────────┐
        │   (Abschnitt 2.3)     │             │
        └───────────┬───────────┘             │
                    │ as370 + cmplmd370       │
                    ▼                         │
             ┌─────────────┐                  │
             │ DIFF_BYTES? │                  │
             └──────┬──────┘                  │
                    │                         │
       ┌────────────┼────────────┐            │
       │ = 0        │ sinkt      │ stagniert  │
       ▼            └────────────┘            │
 ┌────────────┐          │                    │
 │ IDENTISCH  │          └────────────────────┘
 └─────┬──────┘                    │ Budget erschöpft
       │                           ▼
       │                    ┌─────────────┐
       │                    │ ESKALIERT   │──► Bericht, nächstes Modul
       │                    └─────────────┘
       ▼
 ┌────────────┐   Templating    ┌──────────────┐   mvsMF    ┌───────────────┐
 │ Git-Commit │────────────────►│ PTF-ERZEUGT  │───────────►│ MVS-VERIFIZIERT│
 └────────────┘                 └──────────────┘            └───────────────┘
```

**Wichtig: `ESKALIERT` beendet nur die Arbeit an diesem Modul, nicht den Lauf.**
Der Agent schreibt einen Bericht, legt das Modul zur Seite und nimmt das nächste.
Genau das meint „so lange es geht ohne mein Eingriff": Der Lauf endet, wenn die
Liste leer ist, nicht beim ersten harten Fall.

### 2.1 Versionsermittlung — und ihre Grenze

„Version ermitteln" heißt konkret: drei Angaben aus dem Loadmodul ziehen.

| Angabe | Woher | Aussage |
|---|---|---|
| Eyecatcher | Textscan im CSECT, z. B. `IKJCT431 87.344` | Auf welchem Source-Stand wurde assembliert |
| Translator-IDR | IDR-Satz, Subtyp `X'04'` | Womit und wann assembliert |
| HMASPZAP-IDR | IDR-Satz, Subtyp `X'01'` | Ob und wie nachträglich gezappt |

Wichtig für die Werkzeugkette: **Diese drei Angaben stehen im Target-Loadmodul,
nicht im DLIB-Objektdeck** — Objektdecks tragen keine IDR-Sätze. Die
Versionsermittlung liest also das Loadmodul, der Byte-Vergleich läuft danach
gegen das DLIB-Element. Beide Seiten werden gebraucht, für Verschiedenes.

**Die Falle, die der Agent kennen muss:** Ein passender Eyecatcher beweist
nichts. Per `IMASPZAP` eingespielte Fixes verändern den Eyecatcher nicht — das
Modul trägt weiter seinen alten Stand und ist trotzdem verändert. Umgekehrt kann
ein abweichender Eyecatcher an einer Neuassemblierung ohne inhaltliche Änderung
liegen.

Daher gilt: **Die Versionsprüfung ist ein Vorfilter für die Kandidatenauswahl,
niemals ein Ergebnis.** Sie sortiert die Kandidaten, entschieden wird
ausschließlich durch den Byte-Vergleich. Wenn die HMASPZAP-IDR ZAP-Spuren zeigt,
notiert der Agent das als Erklärungshypothese für spätere Differenzen — das ist
oft genau der Grund für ein paar abweichende Bytes.

### 2.2 Die vier Fälle

| Fall | Ausgangslage | Vorgehen | Automatisierbarkeit |
|---|---|---|---|
| **A** | Source vorhanden, assembliert sofort byte-identisch | Bauen, vergleichen, fertig | **vollständig** — reine Verifikation |
| **B** | Source vorhanden, kleine Differenz (zweistellige Byte-Zahl bei gleicher Länge) | Angleich-Schleife | **hoch** — der Suchraum ist klein |
| **C** | Source vorhanden, große Differenz (Tausende Bytes, andere Länge) | Disassemblat als Referenz, Angleich-Schleife gegen den vorhandenen Source | **mittel** — hier steckt die eigentliche Arbeit |
| **D** | Kein Source | `dasm370` → assemblieren → vergleichen | **byte-identisch: hoch. Lesbar: niedrig.** |

Zu Fall D eine Ehrlichkeit, die Dave am eigenen Leib erfahren hat: Ist der
Rundlauf `dasm370 → as370 → cmplmd370` erst einmal dicht, dann ist
Byte-Identität für ein Modul ohne Source fast trivial zu erreichen. Das Ergebnis
ist aber Assembler mit absoluten Offsets statt DSECT-Bezügen — genau das, was
Dave bei `IECVTCCW`, `IGC121`, `IGG019P2`, `IGG019QE`, `IGG019Q0` und `IGG019RC`
als offene Baustelle hinterlassen hat. Der Agent liefert damit ein baubares,
korrektes, aber schwer lesbares Modul.

**Das ist kein Mangel, sondern eine Zwischenstufe.** Byte-Identität zuerst,
Lesbarkeit als getrennter, optionaler zweiter Schritt (siehe Entscheidung 5 in
Abschnitt 3). Der Agent markiert solche Module als `IDENTISCH-ROH`.

### 2.2b Zwei Wege, den Source auf den Objektstand zu bringen

„Den Source auf den Objektstand bringen" ist das Ziel — aber es gibt dafür zwei
grundverschiedene Wege, und die Wahl fällt **pro Modul**:

| | Vorwärtspatchen | Neu erzeugen |
|---|---|---|
| **Vorgehen** | Vorhandenen Source solange angleichen, bis er das Objekt erzeugt | Objekt disassemblieren, Ergebnis ist der neue Source |
| **Aufwand** | hoch, pro Modul | gering, sobald der Rundlauf steht |
| **Ergebnis** | Original mit Kommentaren, Labels, DSECT-Bezügen, PL/S-Herkunft | korrekt, aber strukturlos: absolute Offsets, keine Kommentare |
| **Fälle** | A, B, C | D |

Rein technisch würde Weg 2 für **alle** Module genügen. Sobald
`dasm370 → as370 → cmplmd370` dicht ist, ließe sich jedes Modul mechanisch auf
Objektstand bringen — vollautomatisch, ohne Angleich-Schleife.

**Das wäre trotzdem falsch.** Was den Source wertvoll macht, sind nicht die
Bytes, sondern die Kommentare, die Namen und die Struktur — das, was erklärt,
*was* der Code tut. Ein disassemblierter `IKJCT430` erzeugt zwar das richtige
Modul, taugt aber nicht als Grundlage, um darin überhaupt etwas zu ändern —
und Änderbarkeit ist der ganze Zweck der Übung. Dave hat genau diesen Zustand hinterlassen: `IECVTCCW`,
`IGC121`, `IGG019P2`, `IGG019QE`, `IGG019Q0`, `IGG019RC` sind korrekt und
unbrauchbar zugleich, und er hat sie ausdrücklich als offene Baustelle markiert.

**Regel:** Weg 2 nur, wo Weg 1 nicht geht — also bei Fall D und dort, wo die
Angleich-Schleife eskaliert. Das Verdikt heißt dann `IDENTISCH-ROH` und ist ein
Zwischenstand, kein Ziel.

### 2.2c Wenn das Orakel wegfällt

Ein Punkt, der weiter reicht als die Wiederherstellung selbst, und der bisher
in diesem Plan fehlte.

Byte-Identität ist das Orakel für **Wiederherstellung**. In dem Moment, in dem
wir ein Modul **ändern** — einen Einsprung in `IKJCT430`, oder was auch immer
wir am System anpassen wollen —, ist es weg. Ein geänderter Source erzeugt
zwangsläufig anderen Objektcode. Das ist eine Einbahnstraße: Diese Tür geht
nicht wieder zu.

Daraus folgen zwei Dinge.

**Erstens: Vor der ersten Änderung wird eingefroren.** Der Stand mit Verdikt
`IDENTISCH` bekommt einen Git-Tag, und das zugehörige Objekt wird als Referenz
mit abgelegt. Das ist der letzte Punkt, an dem Source und System nachweislich
übereinstimmen. Ohne diesen Fixpunkt ist später nicht mehr feststellbar, ob eine
Abweichung von uns stammt oder von einem Fehler in der Wiederherstellung.

**Zweitens: Das Orakel wird schwächer, aber es verschwindet nicht.** Die Frage
verschiebt sich von *„ist es identisch?"* zu *„weicht es genau so ab, wie ich es
beabsichtigt habe?"*:

```
  Δ_source := diff(source_eingefroren, source_geändert)
  Δ_objekt := cmplmd370(objekt_eingefroren, objekt_neu)

  Prüfung:  erklärt Δ_source vollständig Δ_objekt?
            unerwartete Bytes außerhalb der geänderten Bereiche = Fehler
```

Das ist maschinell prüfbar und damit weiterhin agententauglich — nur eben als
*Delta-Vergleich* statt als Identitätsprüfung. Eine Änderung, die drei
Instruktionen einfügt, darf genau dort und nur dort etwas verschieben.

**Drittens, und das bleibt beim Menschen:** Ab diesem Punkt sagt kein
Byte-Vergleich mehr etwas über Korrektheit. Ob eine Änderung tatsächlich funktioniert,
zeigt nur ein Test auf einem laufenden System. Die Wiederherstellung endet mit
einem beweisbaren Ergebnis; die Weiterentwicklung tut das nicht.

Daves Markierungskonvention passt genau hierher: Änderungen in Spalte 1 als
`*DSKnnnn` oder in Spalte 65 als `DSKnnnn` zu kennzeichnen macht das Delta im
Source selbst sichtbar — und damit auch für einen Agenten auffindbar, der
Δ_source gegen Δ_objekt halten soll.

### 2.3 Die Angleich-Schleife — das Herzstück

Hier wird Daves Handarbeit mechanisch. Er hat sein Vorgehen am 03.07.2024 in
einer klaren Reihenfolge beschrieben, und genau die wird zur Iterationsstrategie:

```
  D_ref  := dasm370(DLIB-OBJ)                Referenz aus dem IBM-Objektcode
                                             (ersatzweise LMOD-CSECT, wenn es
                                             kein DLIB-Element gibt)
  D_src  := dasm370(as370(source))           dasselbe aus unserem Source
  Δ      := align_diff(D_ref, D_src)         instruktionsweiser Abgleich

  für jede Abweichung in Δ, in dieser Priorität:
    1. Verschiebung  → Instruktionen fehlen oder sind zuviel
    2. Displacement  → Basisregister-/DSECT-Bezug stimmt nicht
    3. Konstante     → DC/DS-Inhalt oder -Länge
    4. Layout        → DSECT-Displacement, meist GETMAINte Workarea

  Patch anwenden → as370 → cmplmd370 → DIFF_BYTES neu messen
```

Der Vergleich läuft **instruktionsweise, nicht byteweise**. Das ist der
Unterschied zwischen „an Offset 0x4B2 stimmen 3 Bytes nicht" und „hier fehlt ein
`LA R1,x`, wodurch sich alles Folgende verschiebt". Nur die zweite Aussage ist
für einen Agenten handlungsleitend. Deshalb braucht `dasm370` einen
Alignment-Diff-Modus, der Einfügungen und Löschungen als solche erkennt statt
als Byte-Rauschen.

**Konvergenzregel:** `DIFF_BYTES` muss über ein gleitendes Fenster von N
Iterationen sinken. Stagnation oder Anstieg ist ein Abbruchkriterium — nicht ein
Grund, es nochmal anders zu probieren. Der Agent eskaliert dann mit seinem
besten Zwischenstand.

### 2.4 Leitplanken

Ohne diese ist ein autonomer Lauf gefährlich:

| Regel | Grund |
|---|---|
| **Ein Modul, eine Datei, ein Branch.** Der Agent editiert ausschließlich die Source-Datei seines eigenen Moduls. | Verhindert, dass ein Fehlschlag andere Module beschädigt |
| **Jede Iteration wird committet**, mit `DIFF_BYTES` in der Commit-Message. | Fortschritt ist sichtbar, jeder Stand rekonstruierbar |
| **Kein Schreibzugriff auf MVS/CE-Volumes.** Nur lesend extrahieren. | Die Baseline muss unveränderlich bleiben |
| **Kein Netzwerkzugriff im Modul-Loop.** | Reproduzierbarkeit |
| **Budget je Modul**: max. Iterationen und max. Laufzeit, konfigurierbar. | Kostendeckel, kein Endlosdrehen |
| **Erfolg nur per Exit-Code.** Der Agent darf `IDENTISCH` nicht behaupten. | Die zentrale Anti-Halluzinations-Regel |
| **Referenz-Loadmodul ist read-only und geprüft.** Prüfsumme im Manifest. | Ohne verlässliches Orakel ist alles wertlos |
| **`ESKALIERT` ist ein normales Ergebnis**, kein Fehler. | Sonst optimiert der Agent auf Vermeidung statt auf Wahrheit |

### 2.5 Der Eskalationsbericht

Wenn ein Modul aufgegeben wird, ist der Bericht das Produkt. Er muss so
beschaffen sein, dass du (oder ein anderer Agent) in fünf Minuten einsteigen
kannst:

```
modul:            IKJEFT02 (in IKJEFT02, LPALIB)
ausgangslage:     Fall C — Source aus MVSBLD/, Eyecatcher weicht ab
start:            DIFF_BYTES = 10.899
beste iteration:  #147, DIFF_BYTES = 2.203
letzte 20 iter.:  keine Verbesserung
hypothese:        Ab Offset 0x1A40 verschobene DSECT-Bezüge; vermutlich
                  andere Workarea-Länge nach GETMAIN bei 0x0C18
verbleibende
abweichungen:     3 Cluster, siehe evidence/IKJEFT02/iter147.diff
gebraucht wird:   Bestätigung der Workarea-Layout-Hypothese
```

### 2.6 Was der Agent zuverlässig kann — und was nicht

Diese Grenze ehrlich zu ziehen ist Teil des Plans.

**Kann er:** Extrahieren, Versionen lesen, Kandidaten indizieren, assemblieren,
vergleichen, Differenzen klassifizieren, mechanische Angleiche (Verschiebungen,
Displacements, Konstanten), Fall D mechanisch schließen, PTFs aus Templates
erzeugen, Jobs über mvsMF absetzen und auswerten, buchführen.

**Kann er nicht ohne dich:** Entscheiden, ob eine nicht erklärbare Differenz
akzeptabel ist. Beurteilen, ob ein Modul funktional korrekt ist (Byte-Identität
sagt nichts über den Fall, dass wir das falsche Referenzmodul gezogen haben).
IPL-Freigabe. Und die semantische Rekonstruktion dort, wo Dave selbst `???`
hingeschrieben hat — wenn niemand mehr weiß, was der Code tut, weiß der Agent es
auch nicht.

---

## 3. Annahmen und getroffene Entscheidungen

Alles hier ist eine Festlegung, keine offene Frage. Widersprich, wo es nicht passt.

| # | Entscheidung | Begründung |
|---|---|---|
| 1 | **Zielsystem ist MVS/CE**, nicht TK3/TK4-. Bezugsversion soll **v3.0.0** (01.08.2026) werden; lokal liegt noch 2.1.4. | Fertiger Moseley-Sysgen ohne Turnkey-Aufbau. Enthält SMP (`smp000.3350`), JES2, TSO und den MVP-Paketmanager. Ab v3.0.0 werden **FTPD, HTTPD und MVSMF standardmäßig mitinstalliert** — der Hauptkanal des Agenten ist damit ab Werk vorhanden (aber nicht gestartet, siehe [Runbook](runbook.md)). |
| 2 | **Neues, kuratiertes Git-Repo** für den Recovery-Source; MVSSRC bleibt unversioniertes Rohmaterial-Archiv. | Deine Entscheidung. Trennt Fundstück von Arbeitsstand. |
| 3 | **`dasm370` entsteht in cc370**, nicht standalone. | Deine Entscheidung, deckt sich mit `cc370/docs/tool-roadmap.md`: erst `libobj370` extrahieren, dann Werkzeuge als dünne Frontends. |
| 4 | **Akzeptanzkriterium ist CSECT-Byte-Identität** gegen das MVS/CE-Loadmodul, mit tolerierten „Löchern" (Dave: `DIFIN`). | Ohne diesen Maßstab ist Autonomie unmöglich — siehe Abschnitt 2. |
| 5 | **Daves Modernisierung (MACCVT) wird nicht sofort übernommen.** Erst Byte-Identität, dann optional lesbar machen — in getrennten Commits. | Zwei Ziele gleichzeitig war Daves Phase 2, und genau dort verlor er die Vergleichbarkeit. Für den Agenten wäre es fatal: zwei bewegliche Ziele, kein eindeutiger Erfolgsmaßstab. |
| 6 | **Das Repo bleibt privat**, bis die Lizenzfrage geklärt ist. | Dave hat deine Frage vom 27.05.2021 nach GitHub-Veröffentlichung nie beantwortet. |
| 7 | **Pilot ist ein von Dave verifiziertes CMDLIB-Modul**, nicht IKJEFT. | Dort kennen wir die Antwort. Man testet eine Werkzeugkette gegen ein bekanntes Ergebnis, nicht gegen ein unbekanntes. |
| 8 | **Basis von `dasm370` sind as370s Opcode-Tabellen**, nicht der Waterloo-Disassembler. | Lizenzproblem, siehe Abschnitt 6. |
| 9 | **Jedes Werkzeug bekommt maschinenlesbare Ausgabe (JSON) und definierte Exit-Codes.** | Nicht optional. Ein Agent, der Klartext-Ausgabe parsen muss, ist unzuverlässig. |
| 10 | **Primäres Orakel ist das DLIB-Objektdeck, nicht das Target-Loadmodul.** | Siehe Abschnitt 5 — beantwortet die Frage nach einem „sauberen" Vergleichssystem, ohne einen eigenen Sysgen zu fahren. |
| 11 | **Neu-Basislinierung vollständig**, alle Systembibliotheken, inklusive Vergleich. | Deine Entscheidung. Danach ist Daves Status kein Hörensagen mehr. |
| 12 | **Iterationsbudget gestaffelt nach Fall**: B ≈ 30, D ≈ 50, C ≈ 150, dazu ein Zeitdeckel je Modul. | Deine Entscheidung. Leichte Fälle laufen billig durch, schwere bekommen eine echte Chance. |
| 13 | **Der Agent darf auf einem Klon auch IPLen.** Betriebswissen dafür steht im [Runbook](runbook.md). | Deine Entscheidung. Grenze bleibt: nie auf der Baseline, nie auf deinem Arbeitssystem. |

---

## 4. Was sich gegenüber Dave ändert

| | Dave (2015–2024) | Wir |
|---|---|---|
| Zielsystem | TK3, später auch TK4- | **MVS/CE v3.0.0** |
| Assemblieren | IFOX00 auf MVS, via SMP | **as370 auf dem Host** |
| Disassemblieren | Disassembler von CBT-Tape 217 auf MVS | **dasm370 auf dem Host** (zu bauen) |
| Vergleichen | `COMPLMD`/`LOADLMD` auf MVS | **cmplmd370 auf dem Host** (zu bauen) |
| Quellhaltung | SMP-FUNCTIONs und PTFs in MVS-Datasets | **Git**, SMP erst am Ende der Kette |
| Iterationszyklus | SMP-Job, Minuten bis Stunden | **Sekunden**, lokal |
| Wer iteriert | Dave, von Hand | **Agent**, nach Zustandsautomat |
| SMP-Rolle | Build-Motor für alles | **Verpackung und Installation fertiger PTFs** |
| Historie | PTF-Nummern `DSKnnnn` im Source | **Git-Commits**, PTF-IDs erst beim Verpacken |

Was bleibt: das Prinzip. Der Objektcode des laufenden Systems ist die Wahrheit,
der Source muss sich daran messen. Daves Markierungskonventionen (`???`, `!!!`),
sein PTF-Nummernschema und seine `DIFIN`-Idee für tolerierte Differenzen
übernehmen wir unverändert — die haben sich bewährt. Seine Arbeitsreihenfolge aus
der Mail vom 03.07.2024 wird zur Iterationsstrategie des Agenten (Abschnitt 2.3).

---

## 5. Der Vergleichsmaßstab: gegen was genau vergleichen wir?

Deine Frage — *müssten wir nicht eigentlich gegen einen Moseley-Sysgen ohne
PTFs und USERMODs vergleichen?* — trifft den Kern. Die Antwort ist ja. Und es
gibt einen Weg dahin, der **keinen eigenen Sysgen erfordert**.

### Das Problem

Daves gesamter „verifiziert"-Status bezieht sich auf **TK3-Objektcode**. MVS/CE
ist ein anderer Sysgen mit eigener USERMOD-Baseline (Moseleys ~69 USERMODs) und
eigener I/O-Generation. Vergleicht man den wiederhergestellten Source gegen die
**Target-Loadmodule** von MVS/CE, hat jede Differenz mindestens vier mögliche
Erklärungen:

1. Unser Source ist falsch.
2. Ein USERMOD hat das Modul verändert.
3. Sysgen-Parameter sind eingeflossen.
4. Der Linkage-Editor hat umsortiert, reloziert oder anders gepackt.

Vier Erklärungen für einen Befund sind für einen autonomen Agenten eine
schlechte Ausgangslage. Er kann nicht entscheiden, ob er weiterarbeiten oder
aufgeben soll.

### Die Lösung: das DLIB-Objektdeck als primäres Orakel

Ein MVS-System hat zwei Bibliothekssätze. Die **Target Libraries**
(`SYS1.LINKLIB`, `SYS1.LPALIB`, …) enthalten die gelinkten, lauffähigen
Loadmodule. Die **Distribution Libraries** (die `AOS*`-Bibliotheken) enthalten
die **Objektdecks, so wie IBM sie ausgeliefert hat** — vor jedem Sysgen, vor
jedem Link-Edit.

Genau das ist der „saubere Vergleichsstand", nach dem du gefragt hast — und
aller Wahrscheinlichkeit nach liegt er in MVS/CE bereits vor. Kein Sysgen nötig.

> ⚠️ **In M0 zu bestätigen.** Nach Moseleys Sysgen-Prozess liegen die DLIBs auf
> `SMP000`, und `smp000.3350` ist in MVS/CE enthalten — geprüft ist das aber
> nicht. Ein `dasdls` über das Volume klärt es in einer Minute. Falls MVS/CE die
> DLIBs weggelassen hat, ist die Strategie nicht verloren: Die
> Distributionsbänder (`zdlib1.het`) sind öffentlich verfügbar und lassen sich
> separat laden.

Das ist aus drei Gründen der bessere Maßstab:

1. **Keine USERMOD-Schicht** — sofern die USERMODs nur APPLYed und nicht
   ACCEPTed wurden. SMP APPLY verändert die Target Libraries, ACCEPT die DLIBs.
   Welche SYSMODs ACCEPTed sind, steht im SMP-CDS auf `smp000` und ist damit
   **nachschlagbar statt geraten**.
2. **Kein Linkage-Editor dazwischen.** Ein Objektdeck-Vergleich kennt keine
   RLD-Relozierung, keine ESDID-Neunummerierung und kein CSECT-Packing in einem
   mehrteiligen Loadmodul. Die cc370-Roadmap nennt genau diese drei Punkte als
   Grund, warum ein *toleranter* Vergleich nötig ist. Auf OBJ-Ebene entfällt das
   Problem, statt toleriert zu werden.
3. **Gleiches gegen Gleiches.** `as370` erzeugt ein Objektdeck. Ein DLIB-Element
   *ist* ein Objektdeck. Für die Verifikation wird `ld370` gar nicht gebraucht —
   die Schleife wird kürzer und um eine Fehlerquelle ärmer.

### Das Drei-Schichten-Modell

| Schicht | Was | Rolle |
|---|---|---|
| **DLIB-Objektdeck** (`AOS*`) | IBM-Auslieferungsstand | **Primäres Orakel.** `as370`-OBJ direkt dagegen vergleichen |
| **Target-Loadmodul** | Was das System tatsächlich fährt | **Sekundäres Orakel.** Für Module ohne DLIB-Entsprechung und zur Gegenprobe |
| **Die Differenz beider** | Sysgen-Konfiguration plus USERMODs | **Wird gemessen, nicht geraten.** Ergibt die USERMOD-Schicht als Nebenprodukt |

Damit werden aus den vier Erklärungen oben zwei getrennte, jeweils beantwortbare
Fragen: *Reproduziert unser Source den IBM-Objektcode?* (gegen DLIB) und *Was
hat dieses System daraus gemacht?* (Delta DLIB → Target).

**Wichtig zum Einordnen:** Der uns vorliegende Source liegt nicht nur hinter dem
Target-Loadmodul, sondern bereits hinter dem **DLIB-Objektdeck** zurück — der von
IBM ausgelieferte Source war nie mit dem ausgelieferten Objektcode synchron
(siehe [Zusammenfassung](kreiss-projekt.de.md), Abschnitt 2,
„Was genau ist Daves Baseline?"). Genau diese Lücke hat Dave mit seinen
`DSKnnnn`-PTFs geschlossen — sie sind damit für uns kein Beiwerk, sondern
verwertbare Source-Wartung in IEBUPDTE-Form.

Dass das trägt, ist keine Vermutung: Dave hat in seinem `LMDRPT38` genau diese
Trennung eingebaut. Anhang C seiner Dokumentation führt **getrennte Statistiken
für Distribution Libraries und Target Libraries** — 5.126 LMODs / 5.454 CSECTs
auf der DLIB-Seite gegenüber 2.365 / 5.453 auf der Target-Seite.

### Was „DLIB-Stand" genau heißt — und woher er kommt

Der Maßstab ist nicht diffus, sondern **reproduzierbar aus drei geprüfsummten
Banddateien**. `step_03_build_dlibs` in `sysgen.py` baut die DLIBs so:

| Job | Was passiert | Eingabe |
|---|---|---|
| `smpjob01` | Produktelemente in SMP laden (RECEIVE) | `tape/zdlib1.het` (16,1 MB) |
| `smpjob02` | **1.482 PTFs** in die SMP-Datasets kopieren | `tape/ptfs.het` (14,2 MB) |
| `smpjob03` | **`ACCEPT G(fmid)` je FMID** — Funktion **plus** PTFs, in die DLIBs | — |
| `smpjob04` | Jim-Morrison-USERMODs für 3375/3380/3390 | `tape/j90009.het` |
| `smpjob05`–`07` | Aufräumen, ICKDSF, `IFOX00` neu binden | `tape/dz1d02.het` |

`jcl/smpjob03.jcl` trägt den Titel *„ACCEPT FMIDS/PTFS"*. **Der DLIB-Stand ist
also nicht der rohe IBM-Auslieferungsstand, sondern IBM-Basis plus 1.482 PTFs
plus die Morrison-DASD-USERMODs.**

Das ist keine Schwäche des Maßstabs, sondern seine Stärke: Er ist ein **genau
definierter, aus geprüfsummten Eingaben reproduzierbarer Wartungsstand**.
`tape/vs2DistributionTapes.md5sums` liefert die Prüfsummen mit
(`zdlib1.het` = `71c587807a8caf90b02fe7f56ba47303`).

**Für die Basismessung folgt daraus:** Die eigentliche Wahrheit ist nicht das
DLIB-Volume eines installierten Systems, sondern **die Eingabe von Schritt 03**.
Ein Volume ist das Ergebnis eines Laufs und kann später verändert worden sein;
die Bänder sind unveränderlich, öffentlich, geprüfsummt — und **ohne jedes MVS
lesbar**, weil sie schlicht Dateien sind.

### Die These: die DLIBs sind distributionsübergreifend gleich

Alle Turnkey-Systeme — TK3, TK4-, TK5, MVS/CE — gehen auf dieselben
IBM-Distributionsbänder zurück. Was sie unterscheidet, entsteht **nach** den
DLIBs:

| Unterschied | Wirkt auf |
|---|---|
| Sysgen-Parameter (Stage I) | Target Libraries |
| USERMODs per APPLY | Target Libraries |
| Zusatzsoftware, Pakete | eigene Bibliotheken |
| USERMODs per **ACCEPT** | **auch DLIBs** ← die einzige Ausnahme |

Daraus folgt die These: **Die `AOS*`-Bibliotheken sollten über alle
Distributionen hinweg identisch sein**, abgesehen von ACCEPTeten SYSMODs — und
welche das sind, sagt der jeweilige SMP-CDS.

Nach dem vorigen Abschnitt lässt sich das sogar schärfer fassen: Zwei
Distributionen haben genau dann gleiche DLIBs, wenn sie **dieselben drei Bänder
mit derselben Jobfolge** verarbeitet haben. Die Frage „sind die DLIBs gleich?"
wird damit zur Frage „hat TK5 denselben `ptfs.het`-Stand und dieselben
Morrison-USERMODs bekommen wie MVS/CE?" — und die ist beantwortbar.

**Das ist billig zu prüfen und verändert bei Bestätigung die Statik des ganzen
Vorhabens.** Beide Seiten liegen lokal vor: MVS/CE hat `smp000.3350`, TK5 hat mit
`tk5dlb.392` ein eigenes DLIB-Volume.

### Warum das so viel ausmacht

Hält die These, dann ist das Ergebnis dieses Projekts **nicht** „Source für unser
MVS/CE", sondern **Source für MVS 3.8j** — distributionsunabhängig. Konkret:

1. **Die Bezugsversionsfrage löst sich weitgehend auf.** Ob MVS/CE 2.1.4, 3.0.0
   oder 3.0.1: Die DLIBs ändern sich dabei nicht. Wir jagen kein bewegliches
   Ziel mehr.
2. **Daves Ergebnisse tragen doch.** Meine frühere Sorge war, dass sein
   „verifiziert" gegen TK3 für MVS/CE wertlos ist. Auf **Target-Ebene** stimmt
   das. Auf **DLIB-Ebene** nicht — und er hat auch dort gemessen, Anhang C führt
   eine eigene DLIB-Statistik.
3. **Die Target Libraries werden zur Nebensache.** Sie sind das Ergebnis von
   Sysgen und USERMODs, also eine Ableitung. Reproduzieren müssen wir sie nicht.
4. **Das Artefakt wird für andere brauchbar.** Ein Source-Baum auf DLIB-Stand
   ist für jedes MVS-3.8j-System verwendbar, nicht nur für unseres. Das erhöht
   nebenbei das Gewicht der offenen Lizenzfrage.

### Das Zielbild, präzise formuliert

> **Ein Source-Baum, der den DLIB-Stand von MVS 3.8j reproduziert.**
> Das ist der Stamm. Alles Weitere — BREXX-Integration, 3390-Erweiterungen, was
> auch immer — ist eine Entwicklung, die von dort abzweigt.

Damit ist auch der Übergang aus Abschnitt 2.2c genau verortet: Der eingefrorene
`IDENTISCH`-Stand auf DLIB-Ebene ist der Abzweigpunkt. Davor Wiederherstellung
mit beweisbarem Ergebnis, danach eigene Entwicklung.

### Wenn die These nicht hält

Auch dann ist die Messung nützlich, denn ein Unterschied ist nicht diffus,
sondern zuordenbar: Er kommt von ACCEPTeten SYSMODs, und der CDS beider Systeme
sagt, von welchen. Wir bekämen also eine Liste betroffener Elemente statt einer
Unsicherheit — und für alle übrigen gälte die These weiterhin.

### Grenzen, die man kennen muss

- **Sysgen-generierte Module** — Nucleus-Tabellen, konfigurationsabhängige
  Module — haben keine sinnvolle DLIB-Entsprechung. Dort ist das Target-Modul
  das einzige Orakel, und die Sysgen-Parameter gehören zwingend in die Baseline.
- **ACCEPTete SYSMODs** stecken auch in den DLIBs. Der CDS sagt, welche
  Elemente betroffen sind — die Information geht also nicht verloren, sie muss
  nur ausgewertet werden.
- **Die alte Warnung gilt weiter**, jetzt nur an anderer Stelle: Beim
  Zusammenführen von Moseley-Baseline und wiederhergestelltem Source ist jede
  Fremd-USERMOD daraufhin zu prüfen, ob sie ein von uns gebautes Modul
  überschreibt. Genau dort entstehen sonst stille Regressionen.

### Daves Arbeit wiederverwenden — worauf setzt sie auf?

Bevor irgendetwas neu gemacht wird, gehört geklärt, was schon da ist.

**Seine Basis war:**

| | Was |
|---|---|
| Source-Eingang | Der von IBM ausgelieferte MVS-Source von den `SRC*`-Volumes (TK3; auf TK4- aus `source.zip`) |
| Objekt-Orakel | DLIBs **und** Target Libraries des laufenden TK3-Systems |

**Und sein Ergebnis liegt uns vor** — `MVSBLD/` in diesem Repository ist nicht
sein Ausgangsmaterial, sondern sein **Arbeitsstand**, mit seinen Markierungen
darin. Nachgezählt:

| Serie | Bereich | Module |
|---|---|---:|
| `DSK0` | Basis: Makros, Druckbarkeit, Assemblierbarkeit | 235 |
| `DSK1` | NUCLEUS auf TK3-Wartungsstand | 158 |
| `DSK2` | SVCLIB | 32 |
| `DSK3` | JES2 und SMP | 36 |
| `DSK6` | die SMP-Erweiterung 4.48 → 4.49 selbst | 1 |
| `DSK9` | Phase 2, Makro-Modernisierung | 12 |
| `DSKC` | CMDLIB | 203 |
| `DSKK` | LINKLIB (unvollständig) | 61 |
| `DSKL` | LPALIB (unvollständig) | 55 |
| | **bearbeitete Module insgesamt** | **747** |
| | davon mit `???` (Zweck unklar) | 50 |
| | davon mit `!!!` (Kniff für den Vergleich) | 16 |

Von rund 5.500 Modulen hat Dave also **747 angefasst** — etwa 13 %. Der Rest ist
der ausgelieferte Source, unverändert.

### Warum seine Arbeit übertragbar ist

Der entscheidende Punkt: **Seine Deltas sind Textänderungen, keine
Binärpatches.** Die `DSKnnnn`-PTFs sind IEBUPDTE-Updates auf Quelltext. Für die
Wiederverwendung ist deshalb nicht entscheidend, ob TK3 und MVS/CE denselben
Objektstand haben, sondern nur, ob wir von demselben Quelltext ausgehen.

Und selbst das müssen wir nicht vorab klären, denn `MVSBLD/*.ASM` ist bereits
**das Ergebnis**, nicht das Delta. Wir können es direkt in die Werkzeugkette
geben und messen.

> **Daraus folgt die erste und wichtigste Messkampagne:**
> **Daves 747 bearbeitete Module gegen die MVS/CE-DLIBs.**
>
> Das Ergebnis beantwortet unmittelbar, wieviel seiner Arbeit trägt — und ist
> zugleich der Härtetest für die gesamte Werkzeugkette an Material, bei dem wir
> die erwartete Antwort ungefähr kennen.

Drei Ausgänge sind denkbar, und alle drei sind brauchbar:

| Ergebnis | Bedeutung |
|---|---|
| überwiegend `IDENTISCH` | TK3- und MVS/CE-DLIB-Stand sind gleich. Seine Arbeit trägt vollständig, wir setzen darauf auf |
| systematische Restdifferenz | Die beiden DLIB-Stände unterscheiden sich definiert. Die Differenz ist einmal zu bestimmen und gilt dann für alle Module |
| unsystematisch verstreut | Die Stände passen nicht zusammen; dann sind seine Deltas aus `SMP.LIB*` auf unseren Source neu anzuwenden |

Auch der schlechteste Fall bedeutet nicht, seine Arbeit neu zu machen: Die
eigentlichen PTFs liegen als `MVSSRC.BLD.SMP.LIB` bis `.LIB5` auf dem
`BLDMVS.AWS`-Band in diesem Repository — in IEBUPDTE-Form und damit auch außerhalb
von SMP anwendbar.

**Sonderbehandlung verdienen die 66 markierten Module.** Die 50 mit `???` sind
Stellen, an denen Dave selbst nicht rekonstruieren konnte, was der Code tut; die
16 mit `!!!` sind Kunstgriffe, damit der Objektvergleich aufgeht. Beides sind
Stellen, an denen ein Agent nicht eigenmächtig „aufräumen" darf.

### Die Verdikte

| Verdikt | Bedeutung | Konsequenz |
|---|---|---|
| `IDENTISCH` | OBJ ist byte-identisch zum DLIB-Element | fertig, in Git einfrieren |
| `IDENTISCH-ROH` | identisch, aber aus Disassemblat, mit absoluten Offsets | baubar und korrekt, noch nicht lesbar |
| `DIFF-USERMOD` | passt zum DLIB, nicht zum Target — Delta ist die USERMOD-/Sysgen-Schicht | belegt, nicht vermutet; nur auflösen, wenn es blockiert |
| `DIFF-UNBEKANNT` | passt auch nicht zum DLIB | Arbeitsvorrat des Agenten |
| `KEIN-SOURCE` | kein Kandidat vorhanden | Fall D |

Die USERMOD-Frage aus der ursprünglichen Fassung dieses Plans erledigt sich
damit weitgehend von selbst: `DIFF-USERMOD` ist kein Verdacht mehr, sondern eine
Messung.

## 6. Werkzeuge

### Vorhanden

| Werkzeug | Ort | Rolle |
|---|---|---|
| **as370** | `~/repos/mvs/cc370`, installiert unter `~/.local/bin` | **Der entscheidende Baustein.** Assembler-XF-Klon, laut README byte-identisch zu IFOX00 über ein Korpus von 950 Modulen. Macht den lokalen Zyklus möglich. |
| **ld370** | dito | Linkage-Editor-Ersatz, `-xmit`/`-iebcopy` als Transportweg. |
| **file370** | dito | Inspektor für OBJ, LMOD, IEBCOPY-Unload, XMIT. Kennt das ESD-Verzeichnis bereits. |
| **xmit370** | dito | Packt Host-Verzeichnisse als TSO-TRANSMIT. |
| **mvsMF** | `~/repos/mvs/mvsmf` | z/OSMF-REST-API auf MVS 3.8j. **Die Schnittstelle, über die der Agent MVS bedient:** Jobs absetzen, Status pollen, Spool holen, Datasets lesen/schreiben. |
| **Hercules-DASD-Utilities** | Quellen in `~/repos/hyperion` (`dasdls.c`, `dasdpdsu.c`, `dasdseq.c`, `dasdcat.c`), noch nicht gebaut | **Der zweite Schlüssel:** Loadmodule direkt aus den MVS/CE-Volumes lesen, ohne MVS zu starten. |
| **cc370-Formatdoku** | `~/repos/mvs/cc370/docs/` | `load-module-format.md` beschreibt die IDR-Sätze bis auf Byte-Ebene — Quelle für die Versionsermittlung. |

### Zu bauen

| Werkzeug | Zweck | Agent-Anforderung |
|---|---|---|
| **dasm370** | LMOD-CSECT → wieder assemblierbarer Source | Zusätzlich ein **Alignment-Diff-Modus** (Abschnitt 2.3): Einfügungen/Löschungen als solche erkennen, nicht als Byte-Rauschen |
| **cmplmd370** | CSECT-Vergleich mit tolerierten Differenzen | JSON-Ausgabe mit `diff_bytes`, Clustern und Offsets. **Exit-Code 0 nur bei Identität** — das ist das Erfolgssignal des Agenten |
| **idrdump370** | IDR-Sätze und Eyecatcher extrahieren | JSON. Kann `file370`-Modus werden |
| **libobj370** | Gemeinsame Formatbibliothek | **Phase 0 der cc370-Roadmap.** Die drei oben sollen dünne Frontends sein, keine vierte Kopie der Formatlogik |
| **`mvsrec`** (Arbeitstitel) | Der Orchestrator: Queue, Zustandsautomat, Budget, Buchführung, Eskalationsberichte | Das ist das Werkzeug, das den Agenten führt — nicht umgekehrt |

### Lizenzhinweis zu dasm370

`~/repos/Waterloo Disasm/dasm370.c` trägt im Kopf:

> *„Copyright (C) 1985, 1991 by the University of Waterloo, Computer Systems
> Group. All rights reserved. No part of this software may be reproduced in any
> form or by any means […] except with the written permission of the copyright
> owner."*

Als Grundlage für ein zu veröffentlichendes mvslovers-Werkzeug untauglich. Die
cc370-Roadmap schlägt selbst den sauberen Weg vor: **as370s Opcode-Tabellen
invertieren.** Damit gehört der Code uns, und er ist per Konstruktion mit dem
Assembler konsistent — genau die Eigenschaft, auf die es beim Rundlauf ankommt.
Der Waterloo-Code taugt als Referenz zum Nachschlagen, nicht als Codebasis.

### Das Risiko bei as370

as370s Byte-Identität ist über C-Ökosystem-Code nachgewiesen (libc370, rexx370,
HTTPD, UFSD). **MVS-Systemsource ist etwas anderes:** PL/S-generierter
Assembler, schwere System-Makros aus `SYS1.MACLIB` und `AMODGEN`, Sysgen-Makros.
Eine Durchsicht der implementierten Direktiven zeigt:

- **Vorhanden:** `DSECT`, `ORG`, `CNOP`, `PUSH`/`POP`, `PRINT`, `TITLE`,
  `EJECT`, `SPACE`, `EXTRN`/`WXTRN`, `CXD`, `COM`, `LTORG`, Literale,
  Makro-/Conditional-Assembly-Präprozessor mit `AIF`/`AGO`/`SETx`/Attributen.
- **Nicht gefunden:** `START`, `ICTL`, `ISEQ`, `OPSYN`, `PUNCH`, `REPRO`, `DXD`.

`PUNCH` und `REPRO` sind relevant, weil Sysgen-Makros damit Karten erzeugen.
`START` kommt in altem Source häufiger vor als `CSECT`.

**Konsequenz:** Die as370-Lückenanalyse gegen echten Systemsource ist ein früher,
eigener Meilenstein (M2) und ein **Machbarkeits-Gate**. Fällt sie schlecht aus,
gehört der Aufwand zuerst in as370.

---

## 7. Die Tabellen — zugleich die Arbeitsschlange des Agenten

Die beiden Tabellen, die du willst, sind nicht nur Berichtswesen: **Tabelle B
ist die Queue.** Beide entstehen generiert, nicht handgepflegt. Hauptergebnis
von M1.

### Gemeinsames Schema

| Spalte | Inhalt | Quelle |
|---|---|---|
| `LMOD` | Loadmodulname | `dasdls` |
| `CSECT` | CSECT-Name | `file370` ESD |
| `LIB` | Ziellibrary | Dataset des Extrakts |
| `LEN` | CSECT-Länge | ESD |
| `EYECATCHER` | z. B. `IKJCT431 87.344` | Textscan im CSECT |
| `IDR_XLATOR` | Übersetzer-ID und -Datum | Translator-IDR (`load-module-format.md` §10.3) |
| `IDR_LKED` | Link-Edit-Datum | Linkage-Editor-IDR (§10.2) |
| `IDR_ZAP` | ZAP-Historie | HMASPZAP-IDR (§10.1) — **die Spur für PTFs, USERMODs, SYSMODs** |
| `SYSMOD` | Zugeordneter SMP-SYSMOD | SMP-CDS auf `smp000` |
| `SRC_KANDIDAT` | Fundort im Rohmaterial | Index über `MVSBLD/`, `IKJ/`, `www.stben.net/`, `mvssrc/mainframe.eu/`, `NEW.ASM`, `MVT.ASM` |
| `FALL` | `A`/`B`/`C`/`D` | abgeleitet aus erstem Vergleich |
| `VERDIKT` | `IDENTISCH` / `IDENTISCH-ROH` / `DIFF-USERMOD` / `DIFF-UNBEKANNT` / `KEIN-SOURCE` / `ESKALIERT` | `cmplmd370` |
| `DIFF_DLIB` | abweichende Bytes gegen das DLIB-Objektdeck — **das Hauptmaß** | `cmplmd370` |
| `DIFF_TGT` | abweichende Bytes gegen das Target-Loadmodul | `cmplmd370` |
| `ACCEPTED` | ob ein SYSMOD in die DLIB ACCEPTet wurde | SMP-CDS |
| `ITER` | Iterationen bis zum Stand | Orchestrator |
| `STAND` | Datum des letzten Laufs | Orchestrator |

Zur Versionsfrage: Die Version steckt an drei Stellen, und alle drei gehören in
die Tabelle, weil sie Verschiedenes aussagen — Details und die Eyecatcher-Falle
in Abschnitt 2.1. Der **SMP-CDS** auf `smp000.3350` liefert die Gegenrichtung:
welcher SYSMOD welches Element angefasst hat. Beide Seiten zusammen ergeben ein
belastbares Bild.

### Tabelle A — Module mit brauchbarem Source

Verdikt `IDENTISCH`, `IDENTISCH-ROH` oder `DIFF-USERMOD`. Die
Fortschrittsanzeige.

**Erwartete Ausgangslage** aus Daves Angaben — Hypothese, die M1 prüft:

| Bereich | Daves TK3-Stand | Erwartung gegen MVS/CE |
|---|---|---|
| `SYS1.NUCLEUS` | identisch, IPL-getestet | teils `DIFF-USERMOD` — andere I/O-Gen, Moseley-USERMODs |
| `SYS1.SVCLIB` | identisch | überwiegend `IDENTISCH` erwartet |
| JES2 | identisch | `DIFF-USERMOD` |
| SMP | identisch | `DIFF-USERMOD` |
| `SYS1.CMDLIB` | identisch | gute Chance auf breites `IDENTISCH` — **daher der Pilot** |
| Rest | unvollständig | Tabelle B |

### Tabelle B — Fehlende Module, nach Aufwand sortiert

Verdikt `DIFF-UNBEKANNT`, `KEIN-SOURCE` oder `ESKALIERT`. Zusätzlich:

| Spalte | Inhalt |
|---|---|
| `GRUND` | `kein Source` / `Source ≠ Objekt` / `nur disassembliert` / `Dictionary` |
| `AUFWAND` | `S`/`M`/`L`, geschätzt aus `DIFF_BYTES` und CSECT-Länge |
| `PRIO` | ergibt sich aus dem Ziel — TSO/IKJ zuerst |
| `BUDGET` | Iterationsbudget für den Agenten |

Aus Daves IKJEFT-Tabelle ist die Priorisierung für unser eigentliches Ziel schon
ablesbar: `IKJEFT40`, `52`, `53`, `54`, `56` weichen bei gleicher Länge um 2 bis
10 Bytes ab — Fall B, ideale erste Agentenaufgaben. `IKJEFT01`, `02`, `03`, `04`,
`05` weichen um Tausende ab — Fall C, die dicken Brocken.

### Erzeugungspipeline

```
MVS/CE-Volumes ──dasdls──► Inventar Target-Libs UND DLIBs (CSV)
                              │
                 dasdpdsu ────┴──► LMOD- und OBJ-Dateien im Host-Verzeichnis
                                      │
              file370/idrdump370 ─────┴──► CSECT + IDR + Eyecatcher (CSV)
                                             │
Rohmaterial-Ordner ──Index──► Source-Kandidaten (CSV)
                                             │
                                    Join + as370 + cmplmd370
                                             │
                                             ▼
                                 Tabelle A und B (Markdown + CSV)
                                             │
                                             ▼
                                    work/queue.yaml für den Agenten
```

Die Markdown-Tabellen sind generierte Artefakte; die CSVs sind die Wahrheit.

### Vergleichen auf MVS — wenn es doch sein muss

Der Host-Vergleich ist die Regel. Für Zweifelsfälle bleibt Daves Werkzeugkette
als zweite Meinung: `COMPLMD`/`LOADLMD` für den CSECT-Vergleich,
`LMDXRF38`/`LMDRPT38` für den bibliotheksweiten Abgleich mit CSV-Ausgabe, dazu
seine fertigen Jobs `ZCMPNUC*`, `ZCMPSVC`, `ZCMPJES`, `ZCMPSMP` — alle aus
`MVSSRC.BLD.UTILITY.ASM`.

Diese Jobs setzt der Agent über **mvsMF** ab und holt die Ausgabe wieder ab.
Zu den Return-Codes: MVS/CE bringt den JES2-USERMOD `SYZJ201` bereits mit, damit
liefert die REST-API einen `retcode`. Bedingung ist ein `NOTIFY=` in der
Jobkarte — `HASPSSSM` schreibt `JCTCNVRC` nur für Jobs, die einen Notify
angefordert haben. Darum muss sich der Agent nicht kümmern: mvsMF ergänzt
`NOTIFY=$MVSMF` automatisch bei jeder Jobkarte, die keines mitbringt. In M0 ist
nur noch zu bestätigen, dass `SYZJ201` in der Baseline tatsächlich appliziert
ist.

---

## 8. Repo-Layout

Neues, kuratiertes Repo. Vorschlag `mvs38-source-recovery`:

```
mvs38-source-recovery/
├── README.md
├── CLAUDE.md                 # Regeln für den Agenten
├── AGENT.md                  # Der Modul-Arbeitsvertrag (Abschnitt 2)
├── .gitattributes            # KEINE Textnormalisierung, siehe unten
├── baseline/
│   ├── mvsce-v3.0.0.md       # USERMODs, MVP-Pakete, Sysgen-Parameter
│   ├── lmod-inventory.csv    # generiert
│   ├── idr-inventory.csv     # generiert
│   └── checksums.txt         # Prüfsummen der Referenz-Loadmodule
├── src/
│   ├── ikj/                  # nach Zielbibliothek und Präfix
│   ├── cmdlib/
│   └── nucleus/
├── tables/
│   ├── portiert.md           # Tabelle A (generiert)
│   ├── fehlend.md            # Tabelle B (generiert)
│   └── *.csv
├── work/
│   ├── queue.yaml            # die Modulliste für den Agenten
│   └── state/                # Zustand je Modul, wiederaufnehmbar
├── evidence/                 # je Modul: Diffs, Iterationsverlauf, Berichte
├── tools/                    # Pipeline und Orchestrator
├── ptf/                      # SMP-Verpackung: ++PTF/++USERMOD, JCLIN
└── doc/
```

`work/state/` ist wichtig: Der Agent muss einen abgebrochenen Lauf **wieder
aufnehmen** können, ohne von vorn zu beginnen. `evidence/` ist die Beweiskette —
ohne sie sind die Ergebnisse nicht nachprüfbar.

**`.gitattributes` ist hier nicht kosmetisch, sondern kritisch:**

```
* -text
*.asm binary
*.ASM binary
```

Der Source hat 80-Zeichen-Sätze mit Sequenznummern in Spalte 73–80 und CRLF.
Genau diese Bytes sind der Vergleichsgegenstand. Git darf daran nichts
normalisieren — sonst vergleichen wir irgendwann Artefakte unserer eigenen
Werkzeugkette. Dass Diffs in Spalte 73–80 rauschen, ist ein Anzeigeproblem und
wird im Diff-Tool gelöst, nicht in der Ablage.

**Draußen bleiben:** `BLDMVS.AWS` (190 MB), die DASD-Volumes, die Web-Spiegel
(`www.stben.net` 856 MB, `mvssrc/mainframe.eu` 125 MB). Die bleiben in MVSSRC.
Falls doch versioniert: Git LFS.

**Privat**, bis die Lizenzfrage geklärt ist.

---

## 9. Meilensteine

### M0 — Werkbank herstellen

- [ ] Hercules-DASD-Utilities aus `~/repos/hyperion` bauen: `dasdls`, `dasdpdsu`,
      `dasdseq`, `dasdcat`. Prüfen, ob sie die MVS/CE-Volumeformate lesen
      (3350 und 3380/3390 gemischt).
- [ ] MVS/CE v3.0.0 auspacken, IPLen, JES2/TSO/SMP-Rauchtest. Danach
      **unveränderlichen Baseline-Snapshot** der Volumes anlegen, mit Prüfsummen.
- [ ] MVS/CE-Baseline inventarisieren: USERMODs, MVP-Pakete, Sysgen-Parameter,
      I/O-Gen → `baseline/mvsce-v3.0.0.md`.
- [ ] **Bestätigen, dass die Distribution Libraries (`AOS*`) auf `smp000.3350`
      vorhanden sind** — davon hängt der Vergleichsmaßstab aus Abschnitt 5 ab.
      Falls nicht: `zdlib1.het` separat laden.
- [ ] Makrobibliotheken beschaffen: `SYS1.MACLIB`, `SYS1.AMODGEN`,
      `SYS1.APVTMACS` extrahieren; gegen `~/repos/mvs/sys1.maclib` abgleichen.
- [ ] mvsMF gegen MVS/CE zum Laufen bringen; bestätigen, dass `SYZJ201` in der
      Baseline appliziert ist.
- [ ] Neues Repo anlegen, `.gitattributes` setzen, Rohmaterial-Index bauen.
- [ ] Hercules-Webkonsole als Notweg aktivieren (`conf/local/custom.cnf`) und
      das [Runbook](runbook.md) beim ersten Durchlauf von 📄 auf ✅ heben.

**Abnahme:** Ein Loadmodul lässt sich ohne laufendes MVS aus `mvsres.3350`
ziehen, und `file370 -v` zeigt sein ESD-Verzeichnis.

### M1 — Inventar und Tabellen

- [ ] Inventar über alle Systembibliotheken — **Target Libraries und
      Distribution Libraries (`AOS*`)**.
- [ ] CSECT-, IDR- und Eyecatcher-Extraktion.
- [ ] SMP-CDS auswerten: SYSMOD → Element, und **welche SYSMODs ACCEPTed sind**
      (entscheidet, wie sauber die DLIBs als Orakel sind).
- [ ] Index über alle lokalen Source-Bestände, Schlüssel CSECT-Name plus
      Eyecatcher.
- [ ] Join, erste Fassung von Tabelle A und B.

**Abnahme:** Beide Tabellen sind generiert und reproduzierbar. Für jedes CSECT in
MVS/CE ist bekannt, ob ein Source-Kandidat existiert.

### M2 — as370-Lückenanalyse (Machbarkeits-Gate)

- [ ] as370 über einen Querschnitt echten Systemsource laufen lassen:
      `MVSBLD/*.ASM` und `IKJ/*.asm`, mit den echten MACLIBs.
- [ ] Fehler kategorisieren: fehlende Direktive, Makroproblem, Ausdruckssyntax,
      Adressierung, sonstiges.
- [ ] Priorisierte Lückenliste; „häufig und billig" sofort in as370 nachziehen.
- [ ] Gegenprobe: Ein Modul mit vorhandenem Source lokal assemblieren und gegen
      IFOX00 auf MVS prüfen.

**Abnahme:** Belastbare Quote, welcher Anteil des Systemsource lokal
assemblierbar ist. **Gate** — fällt sie schlecht aus, hat as370 Vorrang vor
allem anderen.

### M3 — Vergleichspipeline, Pilot auf CMDLIB

- [ ] `cmplmd370` bauen: `DIFIN`/`DIFOUT`-Semantik, `CLEARRLD`, JSON-Ausgabe,
      Exit-Code 0 nur bei Identität.
- [ ] Pilot: ein von Dave verifiziertes CMDLIB-Modul komplett durch die Kette —
      `as370`-OBJ **gegen das DLIB-Element**, ohne `ld370` dazwischen.
- [ ] Gegenprobe gegen das Target-Loadmodul; das Delta ist die
      USERMOD-/Sysgen-Schicht.
- [ ] Verdikt-Spalten automatisch füllen.
- [ ] Danach **vollständig** über alle Bibliotheken (Entscheidung 11).

**Abnahme:** Für mindestens ein Modul ist der Weg vom Git-Source zum Verdikt
`IDENTISCH` reproduzierbar — vollständig auf dem Host.

### M4 — dasm370 und der Rundlauf

- [ ] `libobj370` aus as370/ld370/file370 extrahieren (cc370-Roadmap Phase 0).
      Validierung: bestehende Werkzeuge erzeugen weiterhin byte-identische
      Ausgabe.
- [ ] `dasm370` v1: LMOD-CSECT → Assembler, den as370 direkt frisst.
- [ ] **Rundlauftest** `dasm370 → as370 → cmplmd370` gegen das Original muss
      `IDENTISCH` ergeben. Das ist der Selbsttest des Disassemblers und die
      Voraussetzung für Fall D.
- [ ] Alignment-Diff-Modus (Abschnitt 2.3) — ohne ihn kann der Agent
      Differenzen nicht klassifizieren.

**Abnahme:** Der Rundlauf schließt sich für eine Auswahl von Modulen
verschiedener Größe.

### M5 — Der Orchestrator

- [ ] `mvsrec`: Queue lesen, Zustandsautomat, Budget, `work/state/`,
      Wiederaufnahme, `evidence/`, Eskalationsberichte.
- [ ] Leitplanken aus Abschnitt 2.4 technisch durchsetzen, nicht nur
      dokumentieren.
- [ ] `AGENT.md` schreiben: der Arbeitsvertrag, den ein Agent zu Beginn liest.
- [ ] Trockenlauf über Fall-A-Module: Der Agent muss dort **ohne jede Iteration**
      zum Verdikt kommen.
- [ ] Erster echter autonomer Lauf über eine kleine Fall-B-Liste.

**Abnahme:** Eine Liste von fünf Fall-B-Modulen wird ohne Eingriff abgearbeitet;
für jedes gibt es entweder `IDENTISCH` oder einen brauchbaren
Eskalationsbericht.

### M6 — Breite herstellen

Ab hier ist es kein gezielter Zugriff mehr, sondern ein systematischer Durchgang.
Das Ziel ist Abdeckung: möglichst viele Module mit Verdikt `IDENTISCH`, damit die
Grundlage trägt.

- [ ] **Von Daves verifizierten Bereichen nach außen arbeiten.** NUCLEUS,
      SVCLIB, JES2, SMP und CMDLIB sind auf DLIB-Ebene die aussichtsreichsten
      Kandidaten — dort liegt seine Arbeit als Source-Wartung bereits vor.
- [ ] **Danach nach Aufwand, nicht nach Thema.** Tabelle B ist nach `DIFF_DLIB`
      sortiert; der Agent arbeitet von unten nach oben. Kleine Differenzen bei
      gleicher Länge zuerst, die dicken Brocken zuletzt.
- [ ] **Fall D im Hintergrund.** Module ohne Source lassen sich mechanisch auf
      `IDENTISCH-ROH` bringen, sobald der Rundlauf steht. Das kann nebenher
      laufen und kostet kaum Aufmerksamkeit.
- [ ] **Als Testgelände weiterhin brauchbar:** die `IKJEFT`-Gruppe. Daves
      CSECT-Vergleich von 2024 nennt dort Module mit 2 bis 10 Byte Differenz bei
      gleicher Länge (`IKJEFT40`, `52`, `53`, `54`, `56`) neben solchen mit
      mehreren tausend (`IKJEFT01`, `02`). Eine fertige Skala von leicht bis
      schwer, an bekannten Zahlen — gut, um den Agenten zu kalibrieren.
- [ ] **Vor der ersten eigenen Änderung einfrieren:** Git-Tag auf den
      `IDENTISCH`-Stand, zugehörige Objekte als Referenz mit ablegen
      (Abschnitt 2.2c). Das ist der Abzweigpunkt zwischen Wiederherstellung und
      Entwicklung.

**Abnahme:** Eine belastbare Abdeckung auf DLIB-Ebene, ein eingefrorener
Referenzpunkt — und damit eine Grundlage, auf der Änderungen am Betriebssystem
überhaupt erst möglich werden.

### M7 — Zurück nach MVS: der SMP-Teil

- [ ] Aus Git-Source SMP-taugliche `++PTF`/`++USERMOD` erzeugen, inklusive
      JCLIN — templatisierbar und damit agententauglich.
- [ ] Transport über `xmit370` und `RECV370`.
- [ ] APPLY/ACCEPT auf einem MVS/CE-**Klon**, gesteuert über mvsMF.
- [ ] IPL- und Funktionstest **autonom auf dem Klon** (Entscheidung 13), nach den
      Prozeduren im [Runbook](runbook.md). Zwingend mit Zeitdeckel: Ein
      hängender IPL äußert sich als Ausbleiben von Meldungen, nicht als Fehler.
      **Bei dir bleibt** die Übernahme in ein anderes als das Klon-System.
- [ ] Beobachten, ob der SMPWRK3-Fehler bei diesen kleinen APPLYs überhaupt
      auftritt. Falls ja: Daves offene Spur verfolgen — SMP-Source lesen, klären,
      ob `STOW` unter MVS 3.8 ein Directory löschen kann.

**Abnahme:** Eine lokal erzeugte Änderung ist über SMP auf MVS/CE installiert und
läuft.

### M8 — MVS/CE aus Source bauen

Die zweite Stufe des Ziels aus Abschnitt 1. Nicht mehr „PTFs in ein bestehendes
System einspielen", sondern „das System aus unserem Source erzeugen".

- [ ] `step_03_build_dlibs` in `sysgen.py` im Detail lesen: Was genau entsteht
      dort, in welcher Form, und woran hängen die Folgeschritte?
- [ ] Aus unserem Source-Baum **DLIB-Inhalt erzeugen** — Objektdecks in der
      Struktur, die Schritt 04 erwartet.
- [ ] Einen Sysgen fahren, bei dem Schritt 03 durch unser Ergebnis ersetzt ist.
- [ ] Das entstandene System IPLen und gegen ein reguläres MVS/CE vergleichen.
- [ ] Den Unterschied benennen: Was ist gleich, was nicht, und warum.

**Abnahme:** Ein IPL-fähiges MVS/CE, dessen DLIBs aus unserem Source stammen.

*Das ist der eigentliche Endzustand.* Alles davor ist Voraussetzung dafür — und
alles danach ist Weiterentwicklung des Betriebssystems, nicht mehr
Wiederherstellung.

---

## 10. Risiken

| Risiko | Wirkung | Umgang |
|---|---|---|
| **as370 verdaut Systemsource nicht** | Der ganze Host-first-Ansatz fällt | M2 ist früh und als Gate ausgelegt |
| **MVS/CE weicht stärker von TK3 ab als erwartet** | Daves „verifiziert" trägt kaum | M1 misst früh; `DIFF-USERMOD` fängt den erklärbaren Teil |
| **Disassembler-Rundlauf schließt sich nicht** | Fall D unmöglich, dasm370 nicht vertrauenswürdig | Rundlauftest ist Abnahmekriterium von M4 |
| **Agent meldet Erfolg, der keiner ist** | Stille Fehler, wertlose Ergebnisse | Erfolg ausschließlich per Exit-Code; Prüfsummen auf den Referenzmodulen; `evidence/` je Iteration |
| **Agent dreht sich im Kreis** | Kosten ohne Fortschritt | Konvergenzregel plus hartes Budget je Modul |
| **Agent optimiert auf den Vergleich statt auf Korrektheit** | Byte-identisch, aber sinnloser Source | Nur Fall D ist davon betroffen; dort ist `IDENTISCH-ROH` ein eigenes Verdikt und kein Endzustand |
| **Falsches Referenzmodul gezogen** | Alles Folgende wertlos | Baseline-Prüfsummen; LMOD-Herkunft im Manifest |
| **Lizenzfrage bleibt offen** | Keine Veröffentlichung | Repo privat; unabhängig davon Dave erneut fragen |
| **SMPWRK3-Bug trifft auch kleine APPLYs** | M7 blockiert | Erst in M7 relevant; bis dahin ist die Wertschöpfung host-seitig |
| **Daves 3390-Mods beschädigen den Freispeicher** | Volume unbrauchbar | Seine Phasen 4/5 enthalten sie. Sein Build läuft ausschließlich auf `mvsce-exp`, nie auf einem System, dessen Volumes zählen ([Runbook](runbook.md)) |
| **Umfang** | 5.500 Module, Projekt versandet | Nicht alle 5.500 sind nötig. MSS, VPSS und vermutlich TCAM braucht niemand. Priorität ist Abdeckung dort, wo das System tatsächlich läuft — nach Aufwand sortiert, nicht nach Thema |

---

## 11. Nächste Schritte

Konkret, in dieser Reihenfolge:

1. Hercules-DASD-Utilities bauen und an einem MVS/CE-Volume ausprobieren.
2. MVS/CE auspacken, IPLen, Baseline-Snapshot mit Prüfsummen ziehen.
3. Neues Repo anlegen, `.gitattributes` setzen.
4. **Ein einziges Loadmodul komplett durchspielen** — von `dasdpdsu` bis
   `file370 -v`.
5. Erst dann M1.

Schritt 4 ist wichtiger, als er aussieht: Er beantwortet früh, ob die
host-seitige Extraktion trägt. Wenn ja, ist der Rest Fleißarbeit. Wenn nein,
planen wir um, bevor Aufwand hineingeflossen ist.

Für die Autonomie gilt dieselbe Logik in groß: **M5 ist der Punkt, an dem sich
entscheidet, ob das Zielbild funktioniert.** Alles davor ist Vorbereitung, alles
danach ist Skalierung.

---

## 12. Offene Fragen an dich

Die Fragen nach Basislinierungstiefe, USERMOD-Behandlung, Iterationsbudget und
M7-Autonomie sind beantwortet und als Entscheidungen 10 bis 13 in Abschnitt 3
eingetragen. Offen bleibt:

1. **MVP-Pakete:** MVS/CE bringt einen Paketmanager mit vielen Zusatzprogrammen.
   Die verändern keine `SYS1`-Module, aber die Baseline sollte festhalten, was
   installiert ist. Reicht eine Liste, oder soll auch deren Inhalt inventarisiert
   werden?
2. **Zeitdeckel** für IPL und für Jobs — ergibt sich vermutlich aus dem ersten
   Lauf, gehört dann ins [Runbook](runbook.md).
3. **Was passiert mit `IDENTISCH-ROH`?** Module aus Fall D sind baubar und
   korrekt, aber mit absoluten Offsets statt DSECT-Bezügen. Bleibt das so, oder
   ist die Lesbarmachung (Daves MACCVT-Ansatz) später ein eigenes Ziel?
