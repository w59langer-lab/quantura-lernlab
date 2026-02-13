#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-}"
shift || true

die(){ echo "ERROR: $*" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

REG="assets/data/portal_registry.json"

ensure_registry() {
  [[ -f "$REG" ]] || die "Registry not found: $REG"
}

group() {
  ensure_registry
  python3 - <<'PY'
import json
from pathlib import Path

p = Path("assets/data/portal_registry.json")
data = json.loads(p.read_text(encoding="utf-8"))

lst = data.get("topics") or data.get("items") or []
for it in lst:
  url = (it.get("url") or "").strip()
  if not url: 
    continue
  if url.startswith("pages/faecher/"):
    it["group"] = "Fächer"
  elif "/tools/" in url:
    it["group"] = "Tools"
  elif url.startswith("pages/language_lab/apps/"):
    it["group"] = "Apps"
  elif url.startswith("pages/bibliothek/"):
    it["group"] = "Bibliothek"
  else:
    it["group"] = it.get("group") or "Sonstiges"

data["topics"] = lst
p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("OK: group() updated", len(lst), "topics")
PY
}

add_topic() {
  ensure_registry
  local title="${1:-}"; local url="${2:-}"; local grp="${3:-Sonstiges}"
  [[ -n "$title" && -n "$url" ]] || die 'Usage: ./codex.sh add-topic "Title" "url" "Group"'
  python3 - <<PY
import json
from pathlib import Path
p = Path("$REG")
data = json.loads(p.read_text(encoding="utf-8"))
lst = data.get("topics") or data.get("items") or []
lst.append({"title": "$title", "url": "$url", "group": "$grp"})
data["topics"] = lst
p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\\n", encoding="utf-8")
print("OK: added topic:", "$title")
PY
}

fix_links() {
  ensure_registry
  python3 - <<'PY'
import json
from pathlib import Path

p = Path("assets/data/portal_registry.json")
data = json.loads(p.read_text(encoding="utf-8"))
lst = data.get("topics") or []

for it in lst:
  if (it.get("title","").strip() == "Bibliothek & Ressourcen"):
    it["url"] = "pages/bibliothek/index.html"
    it["group"] = "Bibliothek"

data["topics"] = lst
p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("OK: fix-links() done")
PY
}

deploy() {
  # commits all current changes and pushes
  git add -A
  if git diff --cached --quiet; then
    echo "OK: nothing to commit"
    exit 0
  fi
  git commit -m "codex: update"
  git push
  echo "OK: deploy done"
}

case "$cmd" in
  group) group ;;
  add-topic) add_topic "$@" ;;
  fix-links) fix_links ;;
  deploy) deploy ;;
  ""|help|-h|--help)
    cat <<'HELP'
Usage:
  ./codex.sh group
  ./codex.sh add-topic "Title" "url" "Group"
  ./codex.sh fix-links
  ./codex.sh deploy
HELP
    ;;
  *) die "Unknown command: $cmd" ;;
esac
