import { translations } from './translations.js';

export const languageOptions = [
  { value: 'en', label: 'English' },
  { value: 'it', label: 'Italiano' },
];

const interpolate = (template, params) =>
  template.replace(/\{(\w+)\}/g, (_match, key) =>
    params[key] !== undefined ? params[key] : '',
  );

const getTranslation = (key, selectedLocale) => {
  const segments = key.split('.');
  let current = translations[selectedLocale];
  for (const segment of segments) {
    if (!current || typeof current !== 'object' || !(segment in current)) {
      return null;
    }
    current = current[segment];
  }
  return typeof current === 'string' ? current : null;
};

export const createI18n = (localeRef) => {
  const t = (key, params = {}) => {
    const selectedLocale = localeRef.value in translations ? localeRef.value : 'en';
    const translation =
      getTranslation(key, selectedLocale) || getTranslation(key, 'en') || key;
    return interpolate(translation, params);
  };

  const formatCount = (count, singularKey, pluralKey) =>
    t(count === 1 ? singularKey : pluralKey, { count });

  const dayCodeLabel = (code) => {
    const normalized = (code || '').toUpperCase();
    const label =
      translations[localeRef.value]?.dayCodes?.[normalized] ||
      translations.en?.dayCodes?.[normalized];
    return label || normalized || t('labels.day');
  };

  const planStatusLabel = (status) => t(`planStatuses.${status}`, { status });

  const formatWeekDayLabel = (week, code) =>
    t('labels.weekDay', { week, day: dayCodeLabel(code) });

  const formatWeekDayTitleLabel = (week, code, title) =>
    title
      ? t('labels.weekDayTitle', { week, day: dayCodeLabel(code), title })
      : formatWeekDayLabel(week, code);

  const updateDocumentLanguage = () => {
    document.documentElement.lang = localeRef.value;
    document.title = t('app.title');
  };

  return {
    t,
    formatCount,
    dayCodeLabel,
    planStatusLabel,
    formatWeekDayLabel,
    formatWeekDayTitleLabel,
    updateDocumentLanguage,
  };
};
