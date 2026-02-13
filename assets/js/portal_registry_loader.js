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

    const groups = new Map();

    for (const it of list) {
      if (!it || !it.title || !it.url) continue;
      const g = (it.group || 'Sonstiges').toString();
      if (!groups.has(g)) groups.set(g, []);
      groups.get(g).push(it);
    }

    const order = ['Fächer', 'Apps', 'Tools', 'Bibliothek', 'Sonstiges'];

    const groupNames = Array.from(groups.keys()).sort((a, b) => {
      const ia = order.indexOf(a);
      const ib = order.indexOf(b);
      if (ia === -1 && ib === -1) return a.localeCompare(b);
      if (ia === -1) return 1;
      if (ib === -1) return -1;
      return ia - ib;
    });

    for (const name of groupNames) {
      const og = document.createElement('optgroup');
      og.label = name;

      const items = groups.get(name)
        .slice()
        .sort((x, y) => (x.title || '').localeCompare(y.title || ''));

      for (const it of items) {
        const opt = document.createElement('option');
        opt.value = it.url;
        opt.textContent = it.title;
        og.appendChild(opt);
      }

      selectEl.appendChild(og);
    }
  }

  function filterOptions(query) {
    const q = norm(query);

    for (const opt of Array.from(selectEl.options)) {
      if (!opt.value) { opt.hidden = false; continue; }
      opt.hidden = q && !norm(opt.textContent).includes(q);
    }

    for (const og of Array.from(selectEl.querySelectorAll('optgroup'))) {
      const visible = Array.from(og.querySelectorAll('option')).some(o => !o.hidden);
      og.hidden = !visible;
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
