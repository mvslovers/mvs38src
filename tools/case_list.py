#!/usr/bin/env python3
"""Cut the as370-vs-IFOX00 case list for cc370, ordered so the top of it pays.

A dump of every differing module is not a case list: two thirds of the
differences are the assembly stamp, and a module whose IFOX00 reference came
out of a run IFOX00 itself abandoned is not a statement to be measured against.
This filters both and orders what is left.

    case_list.py <deck-dir> --out cases.tsv

Ordering: modules whose decks have the SAME card count and the FEWEST differing
cards first -- smallest diagnosis, and a small difference in a module nobody has
examined is where a mechanism gets found.
"""
import argparse, csv, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
REF = os.path.join(ROOT, "work/measurements/ifox-run/decks")
TBL = os.path.join(ROOT, "work/measurements/ifox-run/module-table.tsv")
KIND = {b'\xc5\xe2\xc4': 'ESD', b'\xe3\xe7\xe3': 'TXT',
        b'\xd9\xd3\xc4': 'RLD', b'\xc5\xd5\xc4': 'END'}
DATE, TIME = re.compile(r"\d\d/\d\d/\d\d"), re.compile(r"\d\d\.\d\d")


def cards(path):
    d = open(path, "rb").read()
    return [d[i:i + 80] for i in range(0, len(d), 80)]


def kind(c):
    return KIND.get(c[1:4], "OTH")


def masked(c):
    """Columns 1-72 with date and time blanked.

    The mask cannot see a date that straddles a card boundary -- `09/0` on one
    card and `7/26` on the next -- so a residue of one or two cards after
    masking is not automatically a finding. Established on the TK5 probe.
    """
    s = c[:72].decode("cp037", errors="replace")
    return TIME.sub("__.__", DATE.sub("__/__/__", s))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("deckdir")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    tbl = {}
    if os.path.exists(TBL):
        tbl = {r["module"]: r for r in csv.DictReader(open(TBL), delimiter="\t")}

    rows, skipped_stamp, skipped_ref = [], 0, 0
    for f in sorted(os.listdir(a.deckdir)):
        if not f.endswith(".obj"):
            continue
        m = f[:-4]
        rp = os.path.join(REF, f)
        if not os.path.exists(rp):
            continue
        t = tbl.get(m, {})
        # An IFOX00 run that ended above severity 4 is not a reference.
        try:
            if int(t.get("ifox_rc") or 0) > 4:
                skipped_ref += 1
                continue
        except ValueError:
            pass
        ours, ref = cards(os.path.join(a.deckdir, f)), cards(rp)
        same_n = len(ours) == len(ref)
        diff = [i for i, (x, y) in enumerate(zip(ours, ref))
                if masked(x) != masked(y) and kind(x) != "END"]
        if not diff and same_n:
            continue
        raw = [i for i, (x, y) in enumerate(zip(ours, ref))
               if x[:72] != y[:72] and kind(x) != "END"]
        if raw and not diff:
            skipped_stamp += 1
            continue
        first = diff[0] if diff else -1
        rows.append(dict(
            module=m,
            cards_as370=len(ours), cards_ifox=len(ref),
            same_card_count="Y" if same_n else "N",
            differing_cards=len(diff),
            first_card=first,
            first_card_kind=kind(ours[first]) if first >= 0 else "",
            as370_rc=t.get("as370_rc", ""), ifox_rc=t.get("ifox_rc", ""),
            as370_messages=(t.get("as370_messages") or "")[:60],
            ifox_messages=(t.get("ifox_messages") or "")[:60],
        ))

    rows.sort(key=lambda r: (r["same_card_count"] != "Y", r["differing_cards"],
                             r["module"]))
    cols = list(rows[0].keys()) if rows else ["module"]
    with open(a.out, "w", newline="") as fh:
        w = csv.DictWriter(fh, cols, delimiter="\t")
        w.writeheader()
        w.writerows(rows)
    print(f"{len(rows)} cases -> {a.out}")
    print(f"  excluded, stamp only          : {skipped_stamp}")
    print(f"  excluded, IFOX00 rc > 4        : {skipped_ref}")
    same = sum(1 for r in rows if r["same_card_count"] == "Y")
    print(f"  same card count                : {same}")
    if rows:
        print(f"  smallest: " + ", ".join(
            f"{r['module']}({r['differing_cards']})" for r in rows[:8]))


if __name__ == "__main__":
    main()
