#!/usr/bin/env python3
"""Find SETC assignments whose value exceeds 95 characters -- as370's clip
(cc370#151), where IFOX00 holds 255.  Counts the value the way IFOX does:
literal content with '' folded to ' and && to &, concatenated operands summed.
Continuations at column 72 are joined first, or a long table set across three
cards is counted as three short ones.  Prints  length <TAB> member <TAB> path.
"""
import sys, os, re, glob

def statements(path):
    raw = open(path, 'rb').read().decode('latin-1').replace('\r\n', '\n').split('\n')
    i = 0
    while i < len(raw):
        card = raw[i]; i += 1
        if not card.strip() or card[:1] == '*' or card[:2] == '.*': continue
        body = card[:71]
        while len(card) > 71 and card[71] != ' ':
            if i >= len(raw): break
            card = raw[i]; i += 1
            body += card[15:71]
        yield body

LIT = re.compile(r"'((?:[^']|'')*)'")
def value_len(operand):
    """Sum the literal parts; a substring reference '(a,b)' is not counted."""
    n = 0
    for m in LIT.finditer(operand):
        n += len(m.group(1).replace("''", "'").replace('&&', '&'))
    return n

def scan(path):
    worst = 0
    for body in statements(path):
        f = body.split()
        if len(f) >= 3 and f[1] == 'SETC':
            worst = max(worst, value_len(body.split('SETC', 1)[1]))
    return worst

for root in sys.argv[1:]:
    for p in sorted(glob.glob(os.path.join(root, '*'))):
        if os.path.isdir(p): continue
        try: n = scan(p)
        except Exception: continue
        if n > 95:
            print(f"{n}\t{os.path.basename(p)}\t{root}")
