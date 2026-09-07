#!/usr/bin/env python3
"""Scan MVSBLD for conditional-assembly constructs in OPEN CODE.

Open code is everything outside a MACRO/MEND pair. The cards are fixed 80
columns: column 1 '*' is a comment, '.*' is a macro comment, and a non-blank
column 72 continues the statement on the next card -- a scan without
continuation handling misses operands that spill over, which is how BLSR3270
was missed once already.

  --mode set    the operation is SETA / SETB / SETC          (cc370#141 as filed)
  --mode emit   a variable symbol stands in the name, operation or operand
                field of a statement that is not itself a conditional-assembly
                directive -- i.e. one that emits.  Remarks are excluded:
                IFOX's FEVAL60 does not substitute there.
  --mode cond   AIF / AGO / ACTR / ANOP / MEXIT (the count held back in TODO)

Prints one module name per line.
"""
import sys, os, re, glob

SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
CA = {'SETA','SETB','SETC','AIF','AGO','ACTR','ANOP','AREAD','MEXIT','MNOTE',
      'LCLA','LCLB','LCLC','GBLA','GBLB','GBLC','MACRO','MEND','MEXIT'}
SET = {'SETA','SETB','SETC'}
COND = {'AIF','AGO','ACTR','ANOP','MEXIT'}
VAR = re.compile(r'&[A-Za-z@#$][A-Za-z0-9@#$_]*')

def statements(path):
    """Yield (name, op, operand) for every non-comment statement, with the
    MACRO/MEND depth in effect, continuations already joined."""
    raw = open(path, 'rb').read().decode('latin-1').replace('\r\n', '\n').split('\n')
    depth = 0
    i = 0
    while i < len(raw):
        card = raw[i]
        i += 1
        if not card.strip() or card[:1] == '*' or card[:2] == '.*':
            continue
        body = card[:71]
        while len(card) > 71 and card[71] not in (' ', ''):      # column 72 continues
            if i >= len(raw): break
            card = raw[i]; i += 1
            body += card[15:71]                                   # continuation starts in col 16
        f = body.split()
        if not f: continue
        if body[:1] in (' ', '\t'):
            name, rest = '', f
        else:
            name, rest = f[0], f[1:]
        op = rest[0] if rest else ''
        operand = rest[1] if len(rest) > 1 else ''
        yield depth, name, op, operand, body
        # six modules write MACRO/MEND from column 1, where it parses as a name
        eff = op if op in ('MACRO', 'MEND') else (name if name in ('MACRO', 'MEND') and not op else op)
        if eff == 'MACRO': depth += 1
        elif eff == 'MEND' and depth: depth -= 1

def hit(mode, name, op, operand, body):
    if mode == 'set':  return op in SET
    if mode == 'cond': return op in COND
    if mode == 'emit':
        if op in CA or op == '': return False
        return bool(VAR.search(name) or VAR.search(op) or VAR.search(operand))
    raise SystemExit('bad mode')

mode = sys.argv[sys.argv.index('--mode') + 1]
out = []
for p in sorted(glob.glob(os.path.join(SRC, '*.ASM'))):
    m = os.path.basename(p)[:-4]
    try:
        if any(hit(mode, n, o, a, b) for d, n, o, a, b in statements(p) if d == 0):
            out.append(m)
    except Exception as e:
        print(f'{m}: {e}', file=sys.stderr)
print('\n'.join(out))
