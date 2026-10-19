# Max-test tracking

Both roles use the same responsive exercise dashboard. The entire screen scrolls,
including the search, period filter and category controls; there is no fixed-height
header compressing the records into a small inner list.

## Trainees

Open **Max test tracking** from Home navigation (or the existing progress shortcut).
Choose Pull, Push, Legs, Core, Skills or Other and/or search for an exercise.
Each exercise/measurement card shows its latest result, highest recorded value,
change from the previous attempt and a chronological trend. Expand **Full history**
for every recorded attempt, including regressions and repeated values.

Period filters apply to summaries, charts and history. The best-value and history
labels explicitly identify a selected period; clear the filter for all-time data.
Trainees cannot insert, edit or delete records and never request trainer notes.

## Trainers

Athlete cards in the trainer dashboard and athlete list have a **Max tests** shortcut
that opens the correct tab directly. The program toolbar also has a trophy shortcut;
tabs scroll on narrow displays.

Use **Add max test** for a new movement, or the button in an exercise card to prefill
that movement and unit. Search the catalog or choose **Other** for a custom exercise.
Results accept comma or decimal-point input. Date selection follows the app locale.
The trainer can add private notes at creation, edit/clear them from an exercise card
or historical attempt, and delete an attempt after confirmation. Notes remain in
`max_test_trainer_notes`, with the existing assigned-trainer RLS unchanged.

## Grouping and integrity

- Catalog UUIDs, slugs and known localized names resolve to the same exercise.
- Custom movements are retained under Other unless their stable slug is known.
- Different measurement units are never compared. Explicit spelling aliases
  (`s`/`seconds`, `rep`/`reps`, etc.) normalize to the same unit; minutes and seconds
  remain separate series rather than silently converting historical records.
- Same-day server order (`recorded_at`, `created_at`, `id`, newest first) is preserved.
- A change is a numeric comparison, not a claim that more is better for every test.
- A catalog outage does not block records/history; failed record loading offers retry.
- No database migrations or historical-data rewrites are required for this redesign.

Regression coverage: `max_test_series_test.dart`, `max_tests_dashboard_test.dart`,
`max_tests_trainer_flow_test.dart` and existing trainer/model tests. Layout checks
include 320px phones, landscape, tablets, doubled text and IT/EN/ES translations.
