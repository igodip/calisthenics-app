-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.day_exercises (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  day_id uuid NOT NULL,
  exercise_id uuid NOT NULL,
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
  trainee_id uuid NOT NULL,
  week integer NOT NULL CHECK (week > 0),
  day_code text NOT NULL,
  title text,
  notes text,
  completed boolean DEFAULT false,
  CONSTRAINT days_pkey PRIMARY KEY (id),
  CONSTRAINT days_trainee_id_fkey FOREIGN KEY (trainee_id) REFERENCES public.trainees(id)
);
CREATE TABLE public.exercises (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  explanation text,
  CONSTRAINT exercises_pkey PRIMARY KEY (id)
);
CREATE TABLE public.max_tests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  exercise text NOT NULL,
  value numeric,
  unit text,
  recorded_at date,
  trainee_id uuid,
  CONSTRAINT max_tests_pkey PRIMARY KEY (id),
  CONSTRAINT max_tests_trainee_id_fkey FOREIGN KEY (trainee_id) REFERENCES public.trainees(id)
);
CREATE TABLE public.trainees (
  id uuid NOT NULL DEFAULT auth.uid(),
  name text NOT NULL,
  paid boolean DEFAULT false,
  weight numeric,
  CONSTRAINT trainees_pkey PRIMARY KEY (id)
);
CREATE TABLE public.workout_plan_days (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  plan_id uuid NOT NULL,
  day_id uuid NOT NULL,
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
  CONSTRAINT workout_plans_pkey PRIMARY KEY (id),
  CONSTRAINT workout_plans_trainee_id_fkey FOREIGN KEY (trainee_id) REFERENCES public.trainees(id)
);