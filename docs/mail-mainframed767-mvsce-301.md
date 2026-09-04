# Draft to mainframed767 — MVS/CE 3.0.1 with current package levels

**Status: draft. Not sent.** Review, adjust, then send it yourself — as a GitHub
issue in `MVS-sysgen/sysgen`, or directly, whichever you prefer.

---

## What this is about

⚠️ **Send only after item 1c of [`../TODO.md`](../TODO.md)** — that is, after
libc370 and the four packages have been re-released. Otherwise the request names
versions that are already stale by the time they are read. The version numbers in
the draft below therefore have to be **updated before sending**.

MVS/CE **v3.0.0** was released on 2026-08-01. All four packages that matter to us
have had new releases since — and are about to get another round, because
**libc370**, the base library, picked up fixes every consumer needs a relink for.
Among them: a genuine I/O error used to end the address space with **S001**
instead of being passed up as `ferror()`+`EIO`.

That is the carrying argument. "There are newer versions" is easy to defer; "the
base library had four defects that are in all four packages" is not.

| Package | MVP descriptor (`MVP/desc/*`) | Level on 2026-09-04 | after 1c |
|---|---|---|---|
| HTTPD | 4.0.0 | 4.0.1 (2026-08-25) | *fill in* |
| MVSMF | 1.0.0 | 1.0.0-dev — pre-release only | *fill in* |
| UFSD | 1.0.0 | 1.2.1 (2026-08-23) | *fill in* |
| FTPD | 1.0.0 | 1.0.1 (2026-08-23) | *fill in* |

HTTPD is a special case: the MVP descriptor says 4.0.0, but
`MVS-sysgen/SOFTWARE/HTTPD` still holds `HTTPD330` with a `build.log` dated
**2025-02-13** — i.e. 3.3.0. Which level actually lands in the release cannot be
told from outside. That is not academic, because mvsMF requires
**httpd ≥ 4.0.0-dev** for its console services (the `cgictx` API). With 3.3.0
that part of the API is missing.

On top of that come the two points we wanted to report anyway: `SHUTDOWN.RC` does
not know HTTPD or FTPD, and nothing starts them automatically either.

---

## The draft

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

## Notes on the draft

- **The reason comes first**, and it is substantive rather than formal: not
  "newer" but "the shipped binaries contain four defects from the base library".
  That is the difference between a request that gets deferred and one that gets
  scheduled.
- **The HTTPD point is phrased as a question**, not as a bug report. We looked
  into the repository from outside and may be wrong — the sentence "If I'm
  reading the layout wrong, I'd be glad to be corrected" is deliberate.
- **The version table is still empty.** Deliberately — it gets filled after 1c.
- **The two script points are subordinate.** They are the smaller matter and
  should not dilute the main request.
- **The PR offer is meant seriously.** If it is taken up, we should honour it.
- **No pressure, no deadline.** He does this in his spare time.

## If no answer comes

We are not blocked. HTTPD, mvsMF, UFSD and FTPD can be brought up to date through
MVP ourselves — as a step of our own baseline setup, documented in the
[runbook](runbook.md). Asking for 3.0.1 saves us that step; it does not replace
it as an option.
