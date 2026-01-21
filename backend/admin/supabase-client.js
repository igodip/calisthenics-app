const SUPABASE_URL = 'https://jrqjysycoqhlnyufhliy.supabase.co';
const SUPABASE_ANON =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpycWp5c3ljb3FobG55dWZobGl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0MzM0NTIsImV4cCI6MjA2ODAwOTQ1Mn0.3BVA-Ar9YtLGGO12Gt6NQkMl2cn18E_b48PGtlFxxCw';

const supabaseLoadMessages = {
  en: 'Supabase library failed to load. Check your network or replace with local copies.',
  it: 'Impossibile caricare la libreria Supabase. Controlla la rete o sostituiscila con copie locali.',
};

export const getBrowserLocale = () =>
  (navigator.language || '').toLowerCase().startsWith('it') ? 'it' : 'en';

export const getSupabaseLoadMessage = (locale) =>
  supabaseLoadMessages[locale] || supabaseLoadMessages.en;

export const createSupabaseClient = () => {
  const g = window;
  const createClient =
    (g.supabase && g.supabase.createClient) ||
    (g.Supabase && g.Supabase.createClient) ||
    g.SUPABASE_CREATE_CLIENT;

  if (!createClient) {
    return {
      supabase: null,
      error: 'Supabase JS failed to load from all CDNs (jsDelivr/ESM).',
    };
  }

  return {
    supabase: createClient(SUPABASE_URL, SUPABASE_ANON),
    error: null,
  };
};
