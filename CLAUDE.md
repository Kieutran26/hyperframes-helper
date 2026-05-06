# CLAUDE.md — Hyperframes Helper Kit

This repo is a Claude Code skill kit for [Hyperframes](https://github.com/heygen-com/hyperframes), an open-source HTML-to-MP4 video composition framework.

## Quick start for Claude Code

The skill lives at `.claude/skills/hyperframes-helper/SKILL.md`. Read it first — it covers three levels of effort (website-to-video, storyboards, fully guided videos) plus all the lint gotchas, multi-clip cut-editing patterns, and copy-paste recipes.

When the user asks for a Hyperframes video, motion graphics for a recording, or anything that mentions HTML-to-MP4, invoke the skill before doing anything else.

## What's in the skill

- `SKILL.md` — three-level workflow + 16 lint gotchas + the multi-clip cut-editing pattern + Studio editing limits + render quality recipe
- `templates/composition-template.html` — scaffold for a new composition with design tokens, hex mesh background, GSAP scaffolding, watermark
- `templates/storyboard-template.html` — Level 2 starter, 5 scene cards with scaled layout previews
- `templates/recipes.md` — 10 copy-paste patterns: liquid glass, pulse border, white-glow text, curved underline, chroma key, multi-clip pattern, pulsing rings, corner notes, D3 globe, pixel-art icon row
- `templates/silence-cut.sh` — Step 01 Pass A — ffmpeg silencedetect → keep ranges → re-encode with 1s GOP
- `templates/transcribe-whisper.py` — Step 01 Pass B — faster-whisper word-level transcription (Windows-safe, no torchaudio)
- `templates/cut-retakes.py` — Step 01 Pass C — last-take-rule retake removal

## Behavior rules

- Never modify Hyperframes core. This kit is a layer on top.
- Always run `npx hyperframes@latest lint` before claiming a composition is done. It must come back with 0 errors.
- For paid generation steps (e.g. Kling-rendered Claude flip videos), quote cost + wait for explicit go before any API call.
- When the user wants Studio-draggable cuts, default to the multi-clip `data-media-start` pattern. When they just want a final render, single-clip is simpler.
