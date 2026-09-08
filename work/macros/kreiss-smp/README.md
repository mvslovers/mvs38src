# `kreiss-smp/` — macros with real text, out of Dave Kreiss' SMP packages

**23 macros, lifted from `++MAC` elements on `BLDMVS.AWS` that carry actual macro
source.** Eight of them are on the missing list and cover **36 module–operation
pairs**; the rest were on it once or block something else.

Dave packaged them as SMP usermods of his own — `DSK0049` through `DSK0058` are
the `IOS*` family, each a `++PTF(DSKnnnn)` with
`++MAC( IOSTRAP ) SYSLIB(PVTMAC) DISTLIB(APVTMAC)` and the macro body behind it.
**He had already solved this part and shipped the answer on the tape.**

| macro | modules blocked | package |
|---|---:|---|
| `IOSTRAP` | 8 | `SMP.LIB/DSK0055` |
| `IOSSIO` | 7 | `SMP.LIB/DSK0049` |
| `IOSSCP` | 6 | `SMP.LIB/DSK0050` |
| `IOSCPA` | 6 | `SMP.LIB/DSK0054` |
| `IOSCKVOL` | 3 | `SMP.LIB/DSK0053` |
| `IOSUNSOL` `IOSSENSE` `IOSEOS` | 2 each | `DSK0056` `DSK0058` `DSK0057` |

Also here and not currently on the list: `ILRAIA` (147 lines), `IEAPPNIP` (493),
`IECDCST`, `IECDCHT`, `IECDCPT`, `IKJTSCVT`, `IFCMACS`, `IEEDCCB`, `IHADVCT2`,
`IEFAJCTZ`, `MCHEAD`, `TSABEND`, `IHBCOB`, `SGIKF000` (5,458 lines).

## The count that had to be corrected before it was reported

Dave's SMP libraries declare **2,329 distinct macro names** in `++MAC` elements.
**Only 27 of them carry macro text.** `FDM1133` is the illustration: a
`++FUNCTION` package with 73 `++MAC` declarations, 17 KB in total, and **not one
`MACRO` card** — the element names are declarations and the text lives in the
RELFILEs, which are not on this tape.

That is the difference between an inventory and a library, and the first count —
"Dave ships 2,329 macros" — was the inventory. **391 names not on our macro path
became 22.**

## Not adopted, and not measurable yet

Same standing as `erep-instream/`: these must go on **both** sides at once or the
IFOX00 comparison becomes meaningless, and cc370#39 means `as370` currently emits
nothing for an `MNOTE` — so a macro at the wrong maintenance level would expand,
complain, and be scored as landing cleanly. The adoption measurement waits for
that fix.
