-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admins (
  id uuid NOT NULL,
  name text,
  can_assign_trainers boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT admins_pkey PRIMARY KEY (id),
  CONSTRAINT admins_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.exercises (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  slug text NOT NULL,
  name text NOT NULL,
  difficulty text NOT NULL DEFAULT 'beginner'::text,
  sort_order integer NOT NULL DEFAULT 1,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT exercises_pkey PRIMARY KEY (id),
  CONSTRAINT exercises_slug_key UNIQUE (slug),
  CONSTRAINT exercises_name_key UNIQUE (name)
);
CREATE TABLE public.terminology (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  term_key text NOT NULL,
  locale text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  sort_order integer NOT NULL DEFAULT 1,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT terminology_pkey PRIMARY KEY (id),
  CONSTRAINT terminology_unique UNIQUE (term_key, locale)
);
INSERT INTO public.terminology (term_key, locale, title, description, sort_order) VALUES
  ('reps', 'en', 'Reps', 'Number of times you perform an exercise consecutively.', 1),
  ('set', 'en', 'Set', 'A group of repetitions. For example: 3 sets of 10 reps means 30 repetitions total divided into 3 groups.', 2),
  ('rt', 'en', 'RT', 'Total Repetitions: perform all the reps with your preferred sets, reps, and tempo (if not specified).', 3),
  ('amrap', 'en', 'AMRAP', 'As Many Reps As Possible: perform as many reps as you can in a given time.', 4),
  ('emom', 'en', 'EMOM', 'Every Minute on the Minute: start a set every minute. Rest during the remaining time.', 5),
  ('ramping', 'en', 'Ramping', 'Method where the load increases with each set.', 6),
  ('mav', 'en', 'MAV', 'Massima Alzata Veloce: perform as many reps as possible with a load while keeping control and good speed.', 7),
  ('isokinetic', 'en', 'Isokinetic', 'Exercises performed at a constant speed.', 8),
  ('tut', 'en', 'TUT', 'Indicates how long a repetition should last. You can manage the duration of each phase.', 9),
  ('iso', 'en', 'ISO', 'Indicates a pause at a specific point of the repetition.', 10),
  ('som', 'en', 'SOM', 'Indicates the duration of each phase of the repetition.', 11),
  ('deload', 'en', 'Deload', 'Last week of the program to prepare for max attempts.', 12),
  ('reps', 'it', 'Reps (Ripetizioni)', 'Numero di volte che esegui un esercizio consecutivamente.', 1),
  ('set', 'it', 'Set (Serie)', 'Un gruppo di ripetizioni. Es: 3 serie da 10 reps significa 30 ripetizioni totali, divise in 3 gruppi.', 2),
  ('rt', 'it', 'RT', 'Ripetizioni Totali: indica che devi fare tutte quelle reps, con libera scelta di serie, ripetizioni e tempo (se non indicato).', 3),
  ('amrap', 'it', 'AMRAP', 'As Many Reps As Possible: esegui quante più ripetizioni possibili in un tempo determinato.', 4),
  ('emom', 'it', 'EMOM', 'Every Minute On Minute: inizi un set ogni minuto. Il tempo restante serve per riposare.', 5),
  ('ramping', 'it', 'Ramping', 'Metodo che prevede un incremento del peso ad ogni serie', 6),
  ('mav', 'it', 'MAV', 'Massima Alzata Veloce: si riferisce a una metodologia in cui si cerca di eseguire il maggior numero di ripetizioni possibili con un carico, mantenendo sempre il controllo del movimento e una buona velocità di esecuzione.', 7),
  ('isokinetic', 'it', 'Isocinetici', 'Esercizi svolti a velocità costante.', 8),
  ('tut', 'it', 'TUT', 'Indica quanto deve durare una ripetizione. Puoi gestire tu la durata di ogni fase della rep.', 9),
  ('iso', 'it', 'ISO', 'Indica il fermo a un punto specifico dell''esecuzione della rep', 10),
  ('som', 'it', 'SOM', 'Indica la durata di ogni fase della ripetizione.', 11),
  ('deload', 'it', 'Scarico', 'Ultima settimana della scheda per prepararsi ai massimali.', 12);
CREATE TABLE public.trainee_exercise_unlocks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainee_id uuid NOT NULL,
  exercise_id uuid NOT NULL,
  unlocked_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT trainee_exercise_unlocks_pkey PRIMARY KEY (id),
  CONSTRAINT trainee_exercise_unlocks_trainee_id_fkey FOREIGN KEY (trainee_id) REFERENCES public.trainees(id),
  CONSTRAINT trainee_exercise_unlocks_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercises(id),
  CONSTRAINT trainee_exercise_unlocks_unique UNIQUE (trainee_id, exercise_id)
);
CREATE TABLE public.day_exercises (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  day_id uuid NOT NULL,
  exercise_id uuid NOT NULL,
  exercise text NOT NULL,
  position integer NOT NULL DEFAULT 1,
  notes text,
  trainee_notes text,
  completed boolean,
  CONSTRAINT day_exercises_pkey PRIMARY KEY (id),
  CONSTRAINT day_exercises_day_id_fkey FOREIGN KEY (day_id) REFERENCES public.days(id),
  CONSTRAINT day_exercises_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercises(id)
);
CREATE TABLE public.days (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  week integer NOT NULL CHECK (week > 0),
  day_code text NOT NULL,
  title text,
  notes text,
  completed boolean DEFAULT false,
  completed_at timestamp with time zone,
  CONSTRAINT days_pkey PRIMARY KEY (id)
);
CREATE TABLE public.max_tests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  exercise text NOT NULL,
  value numeric,
  unit text,
  recorded_at date,
  trainee_id uuid,
  CONSTRAINT max_tests_pkey PRIMARY KEY (id)
);
CREATE TABLE public.trainee_feedbacks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainee_id uuid NOT NULL,
  message text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  read_at timestamp with time zone,
  CONSTRAINT trainee_feedbacks_pkey PRIMARY KEY (id),
  CONSTRAINT trainee_feedbacks_trainee_id_fkey FOREIGN KEY (trainee_id) REFERENCES public.trainees(id)
);
CREATE TABLE public.trainee_monthly_payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainee_id uuid NOT NULL,
  month_start date NOT NULL,
  paid boolean NOT NULL DEFAULT false,
  paid_at timestamp with time zone,
  amount numeric,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT trainee_monthly_payments_pkey PRIMARY KEY (id),
  CONSTRAINT trainee_monthly_payments_trainee_id_fkey FOREIGN KEY (trainee_id) REFERENCES public.trainees(id)
);
CREATE TABLE public.trainee_trainers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainee_id uuid NOT NULL,
  trainer_id uuid NOT NULL,
  assigned_at timestamp with time zone NOT NULL DEFAULT now(),
  coach_tip text,
  CONSTRAINT trainee_trainers_pkey PRIMARY KEY (id),
  CONSTRAINT trainee_trainers_trainee_id_fkey FOREIGN KEY (trainee_id) REFERENCES public.trainees(id),
  CONSTRAINT trainee_trainers_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.trainers(id)
);
CREATE TABLE public.trainees (
  id uuid NOT NULL,
  name text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  weight numeric,
  CONSTRAINT trainees_pkey PRIMARY KEY (id),
  CONSTRAINT trainees_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.trainers (
  id uuid NOT NULL,
  name text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT trainers_pkey PRIMARY KEY (id),
  CONSTRAINT trainers_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.workout_plan_days (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  plan_id uuid NOT NULL,
  day_id uuid NOT NULL UNIQUE,
  position integer NOT NULL DEFAULT 1,
  CONSTRAINT workout_plan_days_pkey PRIMARY KEY (id),
  CONSTRAINT workout_plan_days_day_id_fkey FOREIGN KEY (day_id) REFERENCES public.days(id),
  CONSTRAINT workout_plan_days_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.workout_plans(id)
);
CREATE TABLE public.workout_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trainee_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  starts_on date,
  status text NOT NULL DEFAULT 'active'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  notes text,
  CONSTRAINT workout_plans_pkey PRIMARY KEY (id)
);
