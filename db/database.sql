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
