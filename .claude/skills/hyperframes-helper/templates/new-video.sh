#!/usr/bin/env bash
# new-video.sh — Thêm một video mới vào HyperFrames project đã có sẵn
#
# Cách dùng:
#   bash new-video.sh my-project-name
#   bash new-video.sh my-project-name "Tên Video Mới"
#
# Tạo ra:
#   my-project-name/videos/video-NN/
#   ├── index.html   ← kế thừa brand.css của project
#   └── meta.json

set -e

PROJECT_NAME="${1:?Thiếu tên project. Ví dụ: bash new-video.sh my-project}"
VIDEO_TITLE="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)/$PROJECT_NAME"
VIDEOS_DIR="$PROJECT_DIR/videos"
COMP_TMPL="$SCRIPT_DIR/composition-template.html"

# ── Guard ────────────────────────────────────────────────────────────────────
if [ ! -d "$PROJECT_DIR" ]; then
  echo "❌  Project '$PROJECT_NAME' không tồn tại tại $(pwd)." >&2; exit 1
fi
if [ ! -f "$PROJECT_DIR/brand.css" ]; then
  echo "❌  Không tìm thấy brand.css trong '$PROJECT_NAME'." >&2; exit 1
fi

# ── Tính số thứ tự video tiếp theo ───────────────────────────────────────────
COUNT=$(find "$VIDEOS_DIR" -maxdepth 1 -type d -name "video-*" | wc -l)
NEXT=$(( COUNT + 1 ))
VIDEO_SLUG=$(printf "video-%02d" "$NEXT")
[ -z "$VIDEO_TITLE" ] && VIDEO_TITLE=$(printf "Video %02d" "$NEXT")

VIDEO_DIR="$VIDEOS_DIR/$VIDEO_SLUG"

if [ -d "$VIDEO_DIR" ]; then
  echo "❌  Folder '$VIDEO_SLUG' đã tồn tại trong project." >&2; exit 1
fi

# ── Tạo thư mục ──────────────────────────────────────────────────────────────
mkdir -p "$VIDEO_DIR/assets"

# ── index.html ────────────────────────────────────────────────────────────────
if [ -f "$COMP_TMPL" ]; then
  sed "s/Your <em>Title<\/em> Here/$VIDEO_TITLE/" \
    "$COMP_TMPL" > "$VIDEO_DIR/index.html"
else
  cat > "$VIDEO_DIR/index.html" << 'HTMLEOF'
<!doctype html><html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=1920, height=1080"/>
  <link rel="stylesheet" href="../../brand.css"/>
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
</head>
<body>
  <div id="root" data-composition-id="main" data-start="0" data-duration="10" data-width="1920" data-height="1080">
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
cat > "$VIDEO_DIR/meta.json" << METAEOF
{
  "id": "${PROJECT_NAME}-${VIDEO_SLUG}",
  "name": "$VIDEO_TITLE"
}
METAEOF

# ── Xong ──────────────────────────────────────────────────────────────────────
echo ""
echo "✅  '$VIDEO_SLUG' đã được thêm vào project '$PROJECT_NAME':"
echo "    $VIDEO_DIR/"
echo ""
echo "Bước tiếp:"
echo "  cd $PROJECT_NAME/videos/$VIDEO_SLUG"
echo "  npx hyperframes@latest preview"
