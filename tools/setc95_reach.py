#!/usr/bin/env python3
"""How far can cc370#151 reach?  A module is exposed if it can arrive at a SETC
value over 95 characters -- and it can arrive there two ways, which is the whole
point of BLSR3270:

  calls   module -> macro -> ... -> a member holding a long SETC
  global  a member sets a long value into a GBLC; any other member declaring
          that same GBLC sees it, with no call between them

BLSR3270 reaches &TR3270 the second way and no call graph would ever show it.
Prints the module counts and writes setc95-reach.tsv.
"""
import os, glob, re, sys
from collections import defaultdict

SRC = "/Users/mike/repos/MVSSRC/Dave Kreiss - MVS from Source/MVSBLD"
M   = os.environ['HOME'] + '/repos/mvs/mvs38src/work/macros'
LIBS = [f'{M}/mvsce-2.1.4-dlib/{d}' for d in
        ('AMACLIB','AMODGEN','AGENLIB','ATSOMAC','ATCAMMAC','APVTMACS')] + [f'{M}/tape', f'{M}/mirror']

sys.argv = ['x']
exec(open('setc95.py').read().split('for root in sys.argv')[0].split('"""', 2)[2])

macro_path = {}
for lib in LIBS:                                   # first -I on the gate's list wins
    for p in glob.glob(os.path.join(lib, '*')):
        if not os.path.isdir(p): macro_path.setdefault(os.path.basename(p), p)

GBL = re.compile(r'^GBL[ABC]$')
def profile(path):
    """(macros called, globals declared, globals set long)"""
    calls, gbls, longset = set(), set(), set()
    for body in statements(path):
        f = body.split()
        if not f: continue
        op, rest = (f[0], f[1:]) if body[:1] not in (' ', '\t') else ((f[0], f[1:]) if False else (f[0], f[1:]))
        if body[:1] in (' ', '\t'): name, op, args = '', f[0], f[1:]
        else: name, op, args = f[0], (f[1] if len(f) > 1 else ''), f[2:]
        if GBL.match(op):
            for a in ' '.join(args).split(','): gbls.add(a.strip().split('(')[0])
        elif op == 'SETC':
            if value_len(body.split('SETC', 1)[1]) > 95: longset.add(name.split('(')[0])
        elif op in macro_path: calls.add(op)
    return calls, gbls, longset

prof = {n: profile(p) for n, p in macro_path.items()}
long_members = {n for n, (c, g, l) in prof.items() if l}
long_globals = {v for n, (c, g, l) in prof.items() for v in l if v in g}

# transitive closure over macro calls
reach = {}
def reaches(n, seen=None):
    if n in reach: return reach[n]
    seen = seen or set()
    if n in seen or n not in prof: return False
    seen.add(n)
    c, g, l = prof[n]
    r = bool(l) or bool(g & long_globals) or any(reaches(k, seen) for k in c)
    if not seen - {n}: reach[n] = r
    return r

exposed_macros = {n for n in prof if reaches(n)}
print(f"macro members holding a long SETC:            {len(long_members)}")
print(f"of those, setting it into a GBLC:             {len(long_globals)}  {sorted(long_globals)}")
print(f"macro members that can reach one:             {len(exposed_macros)}")

rows = []
for p in sorted(glob.glob(os.path.join(SRC, '*.ASM'))):
    m = os.path.basename(p)[:-4]
    calls, gbls, longset = profile(p)
    why = []
    if longset: why.append('own')
    if gbls & long_globals: why.append('global')
    hit = sorted(calls & exposed_macros)
    if hit: why.append('calls:' + ','.join(hit[:4]))
    if why: rows.append((m, ';'.join(why)))
open('setc95-reach.tsv', 'w').write('\n'.join(f'{m}\t{w}' for m, w in rows) + '\n')
print(f"\nMVSBLD modules that can reach a long SETC:    {len(rows)}")
for k in ('own', 'global', 'calls'):
    print(f"  via {k:7} {sum(1 for _, w in rows if k in w)}")
