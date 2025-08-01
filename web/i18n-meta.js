(function() {
  // Переводы описания
  const DESCRIPTIONS = {
    en: "dock en test description",
    ru: "dock ru тестовое описание"
  };

  // Определяем язык
  const lang = (navigator.language || navigator.userLanguage).slice(0, 2);
  const desc = DESCRIPTIONS[lang] || DESCRIPTIONS.en;

  // Функция для подстановки content-атрибута
  function setMeta(selector, content) {
    const el = document.querySelector(selector);
    if (el) el.setAttribute('content', content);
  }

  // Подставляем описание в нужные теги
  setMeta('meta[name="description"]',        desc);
  setMeta('meta[property="og:description"]', desc);
  setMeta('meta[name="twitter:description"]',desc);
})();
