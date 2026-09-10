# Offene Entscheidungen

Stand 11.09.2026, nach der Nachtschicht. Alles hier braucht Mike, nicht mich —
entweder weil es sein Rechner ist, weil es nach außen wirkt, oder weil es eine
Richtungsfrage ist. Sortiert nach dem, was am meisten blockiert.

## 1. Referenzsystem festnageln — blockiert Stufe 1

`MVSCE-LAB` hat seinen Referenzwert verloren: `SYS1.AMACLIB(IHADVCT)` steht dort
auf dem Stand **vor** APAR `@ZA40405`, während die 5.528 Referenzdecks beweisen,
dass IFOX00 den gewarteten gelesen hat. Ein erneuter Orakel-Lauf auf LAB
reproduziert den Korpus nicht. Belege in `docs/missing-macros.md`.

`MVSTK5-REF` ist der vorgesehene Nachfolger und steht in `tools/systems.json` auf
`submit: false`, `oracle: false`. Solange kein System `oracle: true` trägt, ist
**kein** Orakel-Lauf möglich — das ist Absicht, fail-closed.

Was daran hängt:

* Stufe 1 des Fahrplans, der Korpuslauf über 5.528 Module
* das eine Referenzdeck aus Punkt 2
* die geparkte Frage von cc370, ob eine leere `CSECT`-Karte den Zähler
  fortsetzt oder neu beginnt — dafür braucht es genau eine saubere Fixture
  durch ein festgenageltes Orakel

**Zu entscheiden:** Wird `MVSTK5-REF` das Orakel? Und wenn ja: einfrieren, wie?
Ein Snapshot der Bibliotheken, bevor irgendetwas darauf schreibt, wäre das
Mindeste — sonst driftet es wie LAB.

## 2. cc370 PR #359 — Variante A oder B

cc370 hat in der Nacht ein Orakel-Deck auf `mvsdev.lan:8080` erzeugt. Das ist
`MVSCE-DEV`, deine Entwicklungskiste. **Der Fehler war meiner**: ich habe cc370
gesagt, welche Systeme tabu sind, und nie, welcher Port welches System ist.
cc370 hat es von sich aus gemeldet, bevor gemergt wurde.

Fußabdruck laut cc370, **von mir nicht nachgeprüft** — ich habe DEV nicht
angefasst: zwei Spool-Einträge (`ASMORCL` JOB00220/00221, MSGCLASS=H), ein
`IFOX00`-Lauf gegen `SYS1.MACLIB` mit `DISP=SHR`, `IBMUSER.CC370.ORACLE.OBJ` in
beiden Fällen wieder gelöscht. Nichts katalogisiert.

| | |
|---|---|
| **A** | Deck und Listing aus `#359` entfernen. Der Fix bleibt grün, aber der byte-exakte Abnahmetest für `#290` fällt weg. |
| **B** | beides drin lassen, als vorläufig markiert, und auf dem festgenagelten Orakel neu aufnehmen. |

cc370 und ich tendieren beide zu **B**, und zwar aus demselben Grund: das Deck
ist mit hoher Wahrscheinlichkeit korrekt, also zahlt A einen Abnahmetest für
eine Herkunftsfrage, die ein einziger Job klärt. Keiner von uns hat die Branches
angefasst.

Daneben: `#290` ist implementiert, `IECVHDET` byte-identisch, und der
Private-Code-Fix bringt **+3** ohne Verlust. Parität damit **5.431 von 5.528**
bei cc370s Branch. Beide warten auf einen Merge von Hand.

## 3. Kennungen in versionierten Dateien — Konvention, nicht Offenlegung

Neun versionierte Dateien in diesem Repo tragen `HERC01/CUL8TR` oder
`IBMUSER:SYS1` — vier Dokumente, fünf Werkzeuge, alle älter als gestern.

Sachlage: das sind die **veröffentlichten Standardkennungen** von TK5 und MVS/CE
auf einem LAN-lokalen Emulator. Es ist nichts offengelegt, was ein Leser nicht in
der Dokumentation der Distributionen nachschlagen kann. Kein Vorfall.

Trotzdem offen, weil `CLAUDE.md` `.env` aus gutem Grund ignoriert, die
Veröffentlichung dieses Repos noch an der Lizenzfrage hängt, und die Historie die
Zeichenketten behält, was ein späterer Commit auch tut.

**Zu entscheiden:** Herausziehen in eine ignorierte `.env` (fünf Werkzeuge, vier
Dokumente anfassen) — oder stehenlassen mit der Begründung, dass es Standardwerte
sind. Ich habe es nicht von mir aus gemacht, weil es Konvention und nicht
Dringlichkeit ist, und weil fünf Werkzeuge mitten in einem Bau umzubauen der Weg
ist, auf dem ein laufender Bau stehenbleibt.

## 4. Kleinigkeiten

* **Zwei Spool-Einträge auf DEV** aus Punkt 2, falls du sie weghaben willst.
* **`bldrun.py` liegt jetzt im Repo** (`eb3a73e`) — vorher existierte es nur auf
  mvsdev. Der FTP-Ausweichweg (`da807f2`) ist getestet, aber noch **nicht
  ausgerollt**; das mache ich, sobald die Kette durch ist.
* **`$02ASM` und `$08STG1A`** bleiben mit `CC 0024` bzw. `CC 0020` stehen. Beide
  sind nachweislich folgenlos, Begründung in `docs/dave-install-log.md`. Ich
  schlage vor, sie so zu lassen: der eine baut ein Werkzeug, das niemand
  benutzt, der andere repariert sich neun Jobs später selbst.
