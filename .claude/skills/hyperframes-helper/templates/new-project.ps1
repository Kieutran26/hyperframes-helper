# new-project.ps1 — Tạo một HyperFrames project mới với brand.css và video đầu tiên
#
# Cách dùng:
#   .\new-project.ps1 my-project-name
#   .\new-project.ps1 my-project-name "My First Video"
#
# Cấu trúc tạo ra:
#   my-project-name/
#   ├── brand.css           ← design tokens riêng cho project này
#   ├── assets/             ← media dùng chung giữa các video
#   └── videos/
#       └── video-01/
#           ├── index.html
#           └── meta.json

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [string]$FirstVideoTitle = "Video 01"
)

# ── Paths ────────────────────────────────────────────────────────────────────
$SCRIPT_DIR  = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_DIR = Join-Path (Get-Location) $ProjectName
$BRANDS_DIR  = Join-Path $SCRIPT_DIR "brands"
$COMP_TMPL   = Join-Path $SCRIPT_DIR "composition-template.html"

# ── Guard ────────────────────────────────────────────────────────────────────
if (Test-Path $PROJECT_DIR) {
    Write-Error "Folder '$ProjectName' đã tồn tại. Chọn tên khác."
    exit 1
}

# ── Tạo cấu trúc thư mục ─────────────────────────────────────────────────────
New-Item -ItemType Directory -Path $PROJECT_DIR                         | Out-Null
New-Item -ItemType Directory -Path "$PROJECT_DIR\assets"                | Out-Null
New-Item -ItemType Directory -Path "$PROJECT_DIR\videos"                | Out-Null
New-Item -ItemType Directory -Path "$PROJECT_DIR\videos\video-01"       | Out-Null
New-Item -ItemType Directory -Path "$PROJECT_DIR\videos\video-01\assets"| Out-Null

# ── Chọn brand.css ────────────────────────────────────────────────────────────
# Nếu có sẵn nhiều file trong brands/, chọn ngẫu nhiên 1 cái.
# Nếu chỉ có 1 cái (hoặc không có), dùng file đó hoặc dùng default inline.
$brandFiles = @(Get-ChildItem -Path $BRANDS_DIR -Filter "*.css" -ErrorAction SilentlyContinue)

if ($brandFiles.Count -gt 0) {
    $chosen = $brandFiles[(Get-Random -Maximum $brandFiles.Count)]
    Copy-Item $chosen.FullName "$PROJECT_DIR\brand.css"
    Write-Host "  brand: $($chosen.Name)" -ForegroundColor Cyan
} else {
    # Fallback — ghi brand.css mặc định inline
    @'
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
'@ | Set-Content "$PROJECT_DIR\brand.css" -Encoding UTF8
    Write-Host "  brand: default (robonuggets)" -ForegroundColor Cyan
}

# ── Tạo index.html cho video-01 ───────────────────────────────────────────────
if (Test-Path $COMP_TMPL) {
    $html = Get-Content $COMP_TMPL -Raw -Encoding UTF8
    # Cập nhật title trong HTML nếu muốn
    $html = $html -replace 'Your <em>Title</em> Here', $FirstVideoTitle
    Set-Content "$PROJECT_DIR\videos\video-01\index.html" $html -Encoding UTF8
} else {
    # Không có template — tạo skeleton tối thiểu
    @"
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
"@ | Set-Content "$PROJECT_DIR\videos\video-01\index.html" -Encoding UTF8
}

# ── meta.json ─────────────────────────────────────────────────────────────────
$videoId = "$ProjectName-video-01"
@"
{
  "id": "$videoId",
  "name": "$FirstVideoTitle"
}
"@ | Set-Content "$PROJECT_DIR\videos\video-01\meta.json" -Encoding UTF8

# ── Xong ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Project '$ProjectName' đã sẵn sàng:" -ForegroundColor Green
Write-Host "  $PROJECT_DIR\" -ForegroundColor White
Write-Host "  ├── brand.css" -ForegroundColor Gray
Write-Host "  ├── assets\" -ForegroundColor Gray
Write-Host "  └── videos\" -ForegroundColor Gray
Write-Host "      └── video-01\  ← $FirstVideoTitle" -ForegroundColor Gray
Write-Host ""
Write-Host "Bước tiếp:" -ForegroundColor Yellow
Write-Host "  cd $ProjectName\videos\video-01"
Write-Host "  npx hyperframes@latest preview"
Write-Host ""
Write-Host "Thêm video mới:" -ForegroundColor Yellow
Write-Host "  .\new-video.ps1 $ProjectName"
