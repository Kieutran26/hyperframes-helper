#!/usr/bin/env bash
# new-project.sh — Tạo một HyperFrames project mới với brand.css và video đầu tiên
#
# Cách dùng:
#   bash new-project.sh my-project-name
#   bash new-project.sh my-project-name "My First Video"
#
# Cấu trúc tạo ra:
#   my-project-name/
#   ├── brand.css           ← design tokens riêng cho project này
#   ├── assets/
#   └── videos/
#       └── video-01/
#           ├── index.html
#           └── meta.json

set -e

PROJECT_NAME="${1:?Thiếu tên project. Ví dụ: bash new-project.sh my-project}"
FIRST_VIDEO_TITLE="${2:-Video 01}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)/$PROJECT_NAME"
BRANDS_DIR="$SCRIPT_DIR/brands"
COMP_TMPL="$SCRIPT_DIR/composition-template.html"

# ── Guard ────────────────────────────────────────────────────────────────────
if [ -d "$PROJECT_DIR" ]; then
  echo "❌  Folder '$PROJECT_NAME' đã tồn tại. Chọn tên khác." >&2; exit 1
fi

# ── Tạo cấu trúc thư mục ─────────────────────────────────────────────────────
mkdir -p "$PROJECT_DIR/assets"
mkdir -p "$PROJECT_DIR/videos/video-01/assets"

# ── Chọn brand.css ────────────────────────────────────────────────────────────
BRAND_FILES=( "$BRANDS_DIR"/*.css )
if [ -f "${BRAND_FILES[0]}" ]; then
  # Chọn ngẫu nhiên trong danh sách brands
  RAND_IDX=$(( RANDOM % ${#BRAND_FILES[@]} ))
  CHOSEN="${BRAND_FILES[$RAND_IDX]}"
  cp "$CHOSEN" "$PROJECT_DIR/brand.css"
  echo "  brand: $(basename "$CHOSEN")"
else
  # Fallback inline
  cat > "$PROJECT_DIR/brand.css" << 'BRANDEOF'
@import url('https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Outfit:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;700&display=swap');
:root {
  --bg: #000; --surface: #0a0a0a; --card: #14161f;
  --border: #1f2230; --border-2: #2e3244;
  --text: #e0e0e0; --text-paper: #f1ece0; --text-dim: #888; --muted: #9aa0b0;
  --accent: #ff6b1a; --accent-rgb: 255,107,26; --accent-2: #ff9040;
  --teal: #50e3c2; --amber: #f5a623; --violet: #8b5cf6; --cyan: #22d3ee; --pink: #f472b6;
  --font-display: 'Instrument Serif', Georgia, serif;
  --font-body:    'Outfit', system-ui, sans-serif;
  --font-mono:    'JetBrains Mono', monospace;
  --mesh-stroke: rgba(255,255,255,0.085);
  --vignette-a: rgba(255,107,26,0.04); --vignette-b: rgba(139,92,246,0.05);
}
*, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
html, body { width:1920px; height:1080px; overflow:hidden; background:var(--bg); color:var(--text); font-family:var(--font-body); }
#root { position:relative; width:1920px; height:1080px; }
BRANDEOF
  echo "  brand: default (robonuggets)"
fi

# ── Tạo index.html cho video-01 ───────────────────────────────────────────────
if [ -f "$COMP_TMPL" ]; then
  sed "s/Your <em>Title<\/em> Here/$FIRST_VIDEO_TITLE/" \
    "$COMP_TMPL" > "$PROJECT_DIR/videos/video-01/index.html"
else
  cat > "$PROJECT_DIR/videos/video-01/index.html" << 'HTMLEOF'
<!doctype html><html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=1920, height=1080"/>
  <link rel="stylesheet" href="../../brand.css"/>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
</head>
<body>
  <div id="root" data-composition-id="main" data-start="0" data-duration="10" data-width="1920" data-height="1080">
    <!-- TODO: add clips here -->
  </div>
  <script>
    window.__timelines = window.__timelines || {};
    const tl = gsap.timeline({ paused: true });
    window.__timelines['main'] = tl;
  </script>
</body>
</html>
HTMLEOF
fi

# ── meta.json ─────────────────────────────────────────────────────────────────
cat > "$PROJECT_DIR/videos/video-01/meta.json" << METAEOF
{
  "id": "${PROJECT_NAME}-video-01",
  "name": "$FIRST_VIDEO_TITLE"
}
METAEOF

# ── Xong ──────────────────────────────────────────────────────────────────────
echo ""
echo "✅  Project '$PROJECT_NAME' đã sẵn sàng:"
echo "    $PROJECT_DIR/"
echo "    ├── brand.css"
echo "    ├── assets/"
echo "    └── videos/"
echo "        └── video-01/  ← $FIRST_VIDEO_TITLE"
echo ""
echo "Bước tiếp:"
echo "  cd $PROJECT_NAME/videos/video-01"
echo "  npx hyperframes@latest preview"
echo ""
echo "Thêm video mới:"
echo "  bash new-video.sh $PROJECT_NAME"
