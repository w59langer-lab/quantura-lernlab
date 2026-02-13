(async function () {
  const selectEl = document.getElementById('topicSelect');
  const searchEl = document.getElementById('topicSearch');
  if (!selectEl) return;

  const REGISTRY_URL = 'assets/data/portal_registry.json';
  const norm = (s) => (s || '').toString().toLowerCase().trim();

  async function loadRegistry() {
    const res = await fetch(REGISTRY_URL, { cache: 'no-store' });
    if (!res.ok) throw new Error(`Registry load failed: ${res.status} ${res.statusText}`);
    return res.json();
  }

  function buildOptions(list) {
    selectEl.innerHTML = '';
    const opt0 = document.createElement('option');
    opt0.value = '';
    opt0.textContent = 'Thema wählen …';
    selectEl.appendChild(opt0);

    for (const it of list) {
      if (!it || !it.title || !it.url) continue;
      const opt = document.createElement('option');
      opt.value = it.url;
      opt.textContent = it.title;
      selectEl.appendChild(opt);
    }
  }

  function filterOptions(query) {
    const q = norm(query);
    for (const opt of Array.from(selectEl.options)) {
      if (!opt.value) { opt.hidden = false; continue; }
      opt.hidden = q && !norm(opt.textContent).includes(q);
    }
  }

  try {
    const reg = await loadRegistry();
    const list = Array.isArray(reg.topics) ? reg.topics
               : Array.isArray(reg.items)  ? reg.items
               : [];
    buildOptions(list);

    if (searchEl) {
      searchEl.addEventListener('input', () => filterOptions(searchEl.value));
    }

    selectEl.addEventListener('change', () => {
      const href = selectEl.value;
      if (href) window.location.href = href;
    });

  } catch (e) {
    console.error(e);
  }
})();
