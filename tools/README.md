# tools

Small host-side helpers. Nothing here is a substitute for the cc370 tools —
these exist because they were needed before those landed.

| Script | What it does |
|---|---|
| `awstape.py` | Walks an AWS tape image and yields its files and logical records. `python3 awstape.py TAPE.AWS` prints the structure — standard labels, data files, record counts |
| `pdsunload.py` | Reads an IEBCOPY unload off such a tape **member by member**, directory included. Does what `file370` cannot yet (cc370#113) |
| `measure-as370.sh` | Assembles a fixed sample with as370 and counts the clean ones, one line per module so two runs can be joined for regressions |
| `gate.sh` + `gate-worker.sh` | Assembles all 5,528 MVSBLD modules, records the **return code** and keeps the deck whatever that code is, then hashes it. The gate for measuring what an `as370` change is worth |
| `hashdecks.sh` | Hashes object decks with the `END` card excluded — it carries the assembly date, so without this every deck differs between two days |
| `opencode_scan.py` | Finds conditional-assembly constructs in **open code** (outside `MACRO`/`MEND`), continuations joined: `--mode set`, `--mode emit`, `--mode cond` |
| `ebcdic2text.py` | Turns `dasdpdsu` output (raw EBCDIC, fixed-length records) into host text. Read its docstring before using it; both traps it handles are silent ones |

`awstape.py` replaces `awsread.py`, which had the AWS record flags backwards —
`0x80` is the start of a record and `0x20` the end, not the other way round. The
old reader still found the file boundaries and its byte stream was intact, so
findings made by searching the flat stream hold; every record boundary it
printed was wrong.

## Reading Dave Kreiss' tape

```sh
python3 tools/awstape.py "…/BLDMVS/BLDMVS.AWS"     # 15 files, labels in between
```

The data files are numbered 2, 5, 8, 11, 14, … — the odd ones are labels. So
`SMP.JCL` is tape file 1 but index 2 here, `SMP.LIB` index 5, `NEW.ASM` index 8,
`MVT.ASM` index 11, `UTL.ASM` index 14.

```python
from pdsunload import members
for name, cards in members('…/BLDMVS.AWS', 14):    # UTL.ASM, 64 members
    open(name + '.asm', 'wb').write(
        ''.join(c + '\r\n' for c in cards).encode('latin-1'))
```

## Extracting from MVS/CE

Hercules lives on `mvsdev` (`/usr/local/hercules/bin`); it cannot be built on the
Mac (arm64 — the external packages ship for x86 only). So extraction runs there
and the artifacts come back.

```sh
ssh mvsdev
export PATH=/usr/local/hercules/bin:$PATH
cd ~/tmp/mvs38src-work/MVSCE/DASD        # a pristine release, never a running instance

dasdls   smp000.3350                     # what is on the volume
mkdir -p ~/tmp/out && cd ~/tmp/out
dasdpdsu ../mvs38src-work/MVSCE/DASD/smp000.3350 SYS1.AMODGEN
```

Then on the Mac:

```sh
scp -r mvsdev:~/tmp/out ./raw
python3 tools/ebcdic2text.py raw text
```

⚠️ Read volumes only with Hercules shut down, and never those of a running
instance.

## Measuring an as370 change

```sh
export ASMDATE=09/07/26 ASMTIME=12.00   # or 381 decks differ on the clock alone
tools/gate.sh /path/to/as370-before pre
tools/gate.sh /path/to/as370-after  post
```

Build the binaries from **`git worktree` checkouts**, never by checking out a
branch in `~/repos/mvs/cc370` — that tree belongs to a live session. Gate the
branch **one commit at a time**: on `fix/as370-open-code-setc` the end-to-end
figure hid which of two fixes carried the yield, and it was not the one the
branch is named after. See [`docs/opencode-gate.md`](../docs/opencode-gate.md).
