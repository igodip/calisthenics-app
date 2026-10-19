# Exercise picture coverage — 19 October 2026

Read-only audit of the linked exercise catalog and distinct plan labels:

- 15 canonical catalog exercises; all receive an exact-slug reference picture.
- 7 distinct catalog exercise IDs are currently used in plans.
- 49 distinct custom plan labels have no catalog ID. Some are variants, vague
  muscle-group labels, or compound movements. They are not automatically mapped
  to a base exercise's picture. Trainer-approved media/catalog mapping is still
  needed for these entries. No training records or assignments were changed.

Pictures appear in Guides and in the expanded training card for linked catalog
exercises. Tap a picture to open full-screen pinch-to-zoom viewing. The gallery
supports multiple pictures per slug; this initial set provides one reference
board per catalog exercise. All images are bundled in the app, with no external
image requests or public URLs. English, Italian and Spanish UI strings are
provided.

Artwork is AI-generated and should be reviewed by a trainer. It does not cover
all tempos, ranges of motion, grips, individualized modifications or progressions.
Use the written instructions and the trainer's specific prescription.

Coverage, missing assets, exact matching, navigation, zoom, missing-image fallback
and small-screen translations are checked by `test/exercise_gallery_test.dart`.
To add new exercises, add their images and stable slug mapping explicitly.
