# Shape 2 has nothing to attribute with — measured 2026-09-17

`cc370#385` shape 2 is *"`dasm370` emits the object-side facts, and your side
attributes each divergence to a card."* Measured against what this side actually
has:

```
macroattr.py covers   1,042 modules
for-aligndiff covers    832 modules
intersection                0
```

**Exactly zero**, and it is structural rather than accidental:

```
macroattr's population   tgt_c = differs 651, holes 299, not-in-target 92
                         -- EQUAL-LENGTH modules with byte differences
--align-diff's           tgt_c = len-differs 747, not-in-target 85
                         -- the LENGTH-DIFFERING ones
```

`macroattr.py` attributes clusters in modules whose lengths match. `--align-diff`
exists **because** `cmplmd370` reports nothing when lengths differ. The two tools
were built for the two halves of the corpus and they have never met.

## What that means for the decision

**The 120,163 findings are on a population this side has no attribution map for at
all.** Shape 2 does not hand them to a weak map — it hands them to no map. Building
one is new work here whichever shape is chosen, and building it the only way
available today means **scraping a listing**, which is precisely what shape 1's
`as370` statement export exists to remove and what `cc370#397` removed once
already.

So the honest statement of the choice:

| | |
|---|---|
| **shape 1** | one `as370` issue, then `#385` is a translator and this side needs no listing scraper |
| **shape 2** | `#385` ships, and this side must then build a listing scraper for 832 modules to consume it |

**Shape 2 is not the cheaper half of the work. It is the same work, moved here, in
the form the project already decided against.**

## And the map that does exist was answering without evidence

Separately, on its own population: `macroattr.py`'s `owner()` was attributing
**5,674 clusters** it could not reach, and **664 of its 1,042 modules** were making
a claim with no basis ([`TODO.md`](../../TODO.md)). Fixed the same day, published
figure unmoved. So even on the half it covers, the map was weaker than it looked —
which is an argument for the export and not against it.
