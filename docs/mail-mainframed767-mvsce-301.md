# Entwurf an mainframed767 — MVS/CE 3.0.1 mit aktuellen Paketständen

**Status: Entwurf. Nicht versendet.** Durchlesen, anpassen, dann selbst
abschicken — als GitHub-Issue in `MVS-sysgen/sysgen` oder direkt, je nachdem,
was dir lieber ist.

---

## Worum es geht

⚠️ **Erst nach Punkt 1c der [TODO.md](../TODO.md) abschicken** — also nachdem
libc370 und die vier Pakete neu releast sind. Sonst nennt die Anfrage Versionen,
die beim Lesen schon überholt sind. Die Versionsnummern im Entwurf unten sind
entsprechend **vor dem Versand zu aktualisieren**.

MVS/CE **v3.0.0** ist am 01.08.2026 erschienen. Alle vier Pakete, die für uns
zählen, haben danach neue Releases bekommen — und bekommen gerade noch einmal
neue, weil **libc370** als Basisbibliothek Korrekturen erhalten hat, die jeder
Konsument relinkt braucht. Darunter: ein echter E/A-Fehler beendete den
Adressraum mit **S001**, statt als `ferror()`+`EIO` durchgereicht zu werden.

Das ist das tragende Argument der Anfrage. „Es gibt neuere Versionen" ist leicht
zu vertagen; „die Basisbibliothek hatte vier Fehler, die in jedem der vier
Pakete stecken" nicht.

| Paket | MVP-Deskriptor (`MVP/desc/*`) | Stand 04.09.2026 | nach 1c |
|---|---|---|---|
| HTTPD | 4.0.0 | 4.0.1 (25.08.2026) | *nachtragen* |
| MVSMF | 1.0.0 | 1.0.0-dev — nur Pre-Release | *nachtragen* |
| UFSD | 1.0.0 | 1.2.1 (23.08.2026) | *nachtragen* |
| FTPD | 1.0.0 | 1.0.1 (23.08.2026) | *nachtragen* |

Ein Sonderfall ist HTTPD: Der MVP-Deskriptor nennt 4.0.0, aber in
`MVS-sysgen/SOFTWARE/HTTPD` liegt weiterhin `HTTPD330` mit einem `build.log` vom
**13.02.2025** — also 3.3.0. Welcher Stand tatsächlich im Release landet, ist von
außen nicht erkennbar. Das ist deshalb nicht akademisch, weil mvsMF für seine
Konsolendienste laut eigenem README **httpd ≥ 4.0.0-dev** braucht (die
`cgictx`-API). Mit 3.3.0 fehlt dieser Teil der API.

Dazu kommen die beiden Punkte, die wir ohnehin melden wollten: `SHUTDOWN.RC`
kennt HTTPD und FTPD nicht, und gestartet wird auch nichts automatisch.

---

## Der Entwurf

```text
Betreff: MVS/CE 3.0.1 with current UFSD / FTPD / HTTPD / MVSMF?

Hi,

first off — thanks for MVS/CE, and for adding UFSD, FTPD, HTTPD and MVSMF to
customize.jcl. Having them in the base system makes a real difference for what
we're doing.

Some context on why I care about the package levels: I'm restarting Dave
Kreiss' "build MVS from source" work, and this time most of it runs on the host
with the cc370 toolchain (as370/ld370). MVS/CE is the reference system, and
mvsMF is how the automation talks to it — submit a job, poll it, fetch the
spool. So the HTTPD/mvsMF level is fairly load-bearing for us.

Would you consider a 3.0.1 built with the current package releases? All four
have just been rebuilt and re-released, and the reason is worth a sentence,
because it is not "there is a newer version".

libc370 is the base library all four link against, and it picked up four fixes
that every consumer needs a relink for. The one that matters most: a genuine I/O
error on the BSAM DCBs used to take the address space down with an S001 instead
of surfacing as ferror()+EIO. The others are a stdio locking split, an fclose()
teardown ordering bug, and DEQ dropping its scope bits so sysunlock() could never
release. Those defects are in the binaries currently shipping with MVS/CE.

  <VERSIONSTABELLE VOR DEM VERSAND EINSETZEN>
  HTTPD   MVP desc says 4.0.0, upstream is now ...
  MVSMF   MVP desc says 1.0.0, upstream is now ...
  UFSD    MVP desc says 1.0.0, upstream is now ...
  FTPD    MVP desc says 1.0.0, upstream is now ...

One thing I could not work out from the outside: which HTTPD actually ends up in
the build. MVP/desc/HTTPD says Version 4.0.0, but MVS-sysgen/SOFTWARE/HTTPD
still holds HTTPD330 with a build.log dated 2025-02-13. If the 3.3.0 payload is
the one being installed, mvsMF's console services can't work — its README
requires httpd >= 4.0.0-dev for the cgictx API. If I'm reading the layout wrong,
I'd be glad to be corrected.

Two smaller things I noticed while reading the repo, both in the same area:

1. SCRIPTS/SHUTDOWN.RC doesn't stop HTTPD or FTPD. The packages are installed by
   default now, but the shutdown script doesn't mention them, so they get run
   over by the quiesce. A /P HTTPD and /P FTPD before the rest would cover it.

2. Nothing starts them either. There's no "S HTTPD" anywhere in the repo, and
   COMMND00 only has S NET plus the JES2 parms. I realise "installed but not
   started" is deliberate — but for HTTPD in particular it means that right
   after an IPL the only way in is the Hercules console, since mvsMF runs as CGI
   under HTTPD. A COMMND00 entry, or a hao rule in the style SHUTDOWN.RC already
   uses, would remove that chicken-and-egg.

Happy to send pull requests for either or both if you'd rather not spend the
time — they're small changes and I don't want to make work for you.

Thanks again,
Mike
```

---

## Anmerkungen zum Entwurf

- **Der Grund steht vorne**, und er ist inhaltlich, nicht formal: nicht „neuer",
  sondern „in den ausgelieferten Binaries stecken vier Fehler der
  Basisbibliothek". Das ist der Unterschied zwischen einer Bitte, die man
  vertagt, und einer, die man einplant.
- **Die Versionstabelle ist noch leer.** Bewusst — sie wird erst nach 1c
  gefüllt.
- **Die HTTPD-Frage ist als Frage formuliert**, nicht als Fehlermeldung. Wir
  haben von außen ins Repository geschaut und können uns irren — der Satz „If I'm
  reading the layout wrong, I'd be glad to be corrected" steht bewusst da.
- **Die beiden Skript-Punkte sind nachgeordnet.** Sie sind das kleinere Anliegen
  und sollen die Hauptbitte nicht verwässern.
- **Das PR-Angebot ist ernst gemeint.** Wenn es angenommen wird, sollten wir es
  auch einlösen.
- **Kein Druck, kein Termin.** Er macht das in seiner Freizeit.

## Falls keine Antwort kommt

Wir sind nicht blockiert. HTTPD, mvsMF, UFSD und FTPD lassen sich über MVP auch
selbst auf den aktuellen Stand bringen — dann eben als eigener Schritt in unserer
Baseline-Einrichtung, dokumentiert im [RUNBOOK.md](runbook.md). Die Bitte um
3.0.1 spart uns diesen Schritt, ersetzt ihn aber nicht als Möglichkeit.
