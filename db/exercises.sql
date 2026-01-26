-- Exercise seed data for Supabase

INSERT INTO public.exercises (slug, name, difficulty, sort_order)
VALUES
  ('pull-up', 'Pull-up', 'intermediate', 1),
  ('chin-up', 'Chin-up', 'intermediate', 2),
  ('push-up', 'Push-up', 'beginner', 3),
  ('bodyweight-squat', 'Bodyweight squat', 'beginner', 4),
  ('glute-bridge', 'Glute bridge', 'beginner', 5),
  ('hanging-leg-raise', 'Hanging leg raise', 'intermediate', 6),
  ('muscle-up', 'Muscle-up', 'advanced', 7),
  ('straight-bar-dip', 'Straight bar dip', 'intermediate', 8),
  ('dips', 'Dips', 'intermediate', 9),
  ('australian-row', 'Australian row', 'beginner', 10),
  ('pike-push-up', 'Pike push-up', 'intermediate', 11),
  ('hollow-body-hold', 'Hollow body hold', 'beginner', 12),
  ('plank', 'Plank', 'beginner', 13),
  ('l-sit', 'L-sit', 'intermediate', 14),
  ('handstand-hold', 'Handstand hold', 'advanced', 15);

INSERT INTO public.exercise_guides
  (slug, difficulty, default_unlocked, accent, sort_order)
VALUES
  ('pullup', 'intermediate', false, '#2196F3', 1),
  ('chinup', 'intermediate', false, '#03A9F4', 2),
  ('pushup', 'beginner', true, '#FF9800', 3),
  ('bodyweight-squat', 'beginner', true, '#4CAF50', 4),
  ('glute-bridge', 'beginner', true, '#8BC34A', 5),
  ('hanging-leg-raise', 'intermediate', false, '#9C27B0', 6),
  ('muscle-up', 'advanced', false, '#009688', 7),
  ('straight-bar-dip', 'intermediate', false, '#FF5722', 8),
  ('dips', 'intermediate', false, '#F44336', 9),
  ('australian-row', 'beginner', true, '#3F51B5', 10),
  ('pike-pushup', 'intermediate', false, '#FFC107', 11),
  ('hollow-hold', 'beginner', true, '#795548', 12),
  ('plank', 'beginner', true, '#607D8B', 13),
  ('l-sit', 'intermediate', false, '#03A9F4', 14),
  ('handstand', 'advanced', false, '#673AB7', 15);
