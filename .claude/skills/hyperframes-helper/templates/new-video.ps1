# new-video.ps1 — Thêm một video mới vào HyperFrames project đã có sẵn
#
# Cách dùng:
#   .\new-video.ps1 my-project-name
#   .\new-video.ps1 my-project-name "Tên Video Mới"
#
# Tạo ra:
#   my-project-name/videos/video-NN/
#   ├── index.html   ← kế thừa brand.css của project
#   └── meta.json

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [string]$VideoTitle = ""
)

$SCRIPT_DIR  = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_DIR = Join-Path (Get-Location) $ProjectName
$VIDEOS_DIR  = Join-Path $PROJECT_DIR "videos"
$COMP_TMPL   = Join-Path $SCRIPT_DIR "composition-template.html"

# ── Guard ────────────────────────────────────────────────────────────────────
if (-not (Test-Path $PROJECT_DIR)) {
    Write-Error "Project '$ProjectName' không tồn tại tại $(Get-Location)."
    exit 1
}
if (-not (Test-Path "$PROJECT_DIR\brand.css")) {
    Write-Error "Không tìm thấy brand.css trong '$ProjectName'. Đây có phải project HyperFrames không?"
    exit 1
}

# ── Tính số thứ tự video tiếp theo ───────────────────────────────────────────
$existing = @(Get-ChildItem $VIDEOS_DIR -Directory -Filter "video-*" -ErrorAction SilentlyContinue)
$nextNum  = $existing.Count + 1
$videoSlug = "video-{0:D2}" -f $nextNum

if (-not $VideoTitle) { $VideoTitle = "Video {0:D2}" -f $nextNum }

$VIDEO_DIR = Join-Path $VIDEOS_DIR $videoSlug

if (Test-Path $VIDEO_DIR) {
    Write-Error "Folder '$videoSlug' đã tồn tại trong project."
    exit 1
}

# ── Tạo thư mục ──────────────────────────────────────────────────────────────
New-Item -ItemType Directory -Path $VIDEO_DIR              | Out-Null
New-Item -ItemType Directory -Path "$VIDEO_DIR\assets"     | Out-Null

# ── index.html ────────────────────────────────────────────────────────────────
if (Test-Path $COMP_TMPL) {
    $html = Get-Content $COMP_TMPL -Raw -Encoding UTF8
    $html = $html -replace 'Your <em>Title</em> Here', $VideoTitle
    Set-Content "$VIDEO_DIR\index.html" $html -Encoding UTF8
} else {
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
  </div>
  <script>
    window.__timelines = window.__timelines || {};
    const tl = gsap.timeline({ paused: true });
    window.__timelines['main'] = tl;
  </script>
</body>
</html>
"@ | Set-Content "$VIDEO_DIR\index.html" -Encoding UTF8
}

# ── meta.json ─────────────────────────────────────────────────────────────────
$videoId = "$ProjectName-$videoSlug"
@"
{
  "id": "$videoId",
  "name": "$VideoTitle"
}
"@ | Set-Content "$VIDEO_DIR\meta.json" -Encoding UTF8

# ── Xong ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Video '$videoSlug' đã được thêm vào project '$ProjectName':" -ForegroundColor Green
Write-Host "  $VIDEO_DIR\" -ForegroundColor White
Write-Host ""
Write-Host "Bước tiếp:" -ForegroundColor Yellow
Write-Host "  cd $ProjectName\videos\$videoSlug"
Write-Host "  npx hyperframes@latest preview"
