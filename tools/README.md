# tools

Small host-side helpers. Nothing here is a substitute for the cc370 tools —
these exist because they were needed before those landed.

| Script | What it does |
|---|---|
| `awsread.py` | Walks an AWS tape image and yields its files and logical records. `python3 awsread.py TAPE.AWS` prints the structure — standard labels, data files, record counts |
| `ebcdic2text.py` | Turns `dasdpdsu` output (raw EBCDIC, fixed-length records) into host text. Read its docstring before using it; both traps it handles are silent ones |

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
