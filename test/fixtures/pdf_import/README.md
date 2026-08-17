# PDF import fixtures

`bux_app_layout.json` is copied from the website fixture and records the
sanitized expected output for its five-week, four-day workout PDF.

The source layout has seven columns (`ESERCIZI`, five week columns, and
`NOTE`) and only partial horizontal rules. The original PDF is not included
because it contains personal contact information. The Flutter regression test
builds positioned page items from this fixture and checks day codes, slot
counts, notes, and representative programming values. Every exercise slot is
imported into every week, including weeks whose programming box is empty, so
the expected exercise count is 22 slots across 5 weeks (110 exercises).

`igor_6_7_6_8.pdf` is the supplied real regression document, and
`igor_6_7_6_8.json` records its expected import identified by SHA-256. The
fixture covers the alternate eight-column layout where `NOTE` appears before
the week columns, verifies all 20 exercise slots across four weeks plus
`Scarico` (100 exercises), and preserves note text that starts close to the
exercise-column boundary.
