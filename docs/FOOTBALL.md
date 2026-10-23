# Football game — scope and engine decision

Status: **proposal, blocked on one owner decision** (engine / size target).

Goal: a complete, original football game with eFootball-like *gameplay feel*,
sound effects, menus, teams, a stadium, and a reproducible 5h50m-safe build.

It cannot use eFootball, Konami assets, real club badges, real player
likenesses or licensed music. All names, kits, logos and audio must be
original or properly licensed.

## The hard conflict: Unreal Engine vs 10–30 MB

These two requirements cannot both be met:

| | Unreal Engine 5 | 10–30 MB target |
| --- | --- | --- |
| Minimum shipping build | typically 150–300+ MB for a tiny project | 10–30 MB total |
| Build environment | Epic account + EULA, ~100 GB engine/DerivedDataCache | any |
| GitHub-hosted runner | impossible (14 GB disk, 6 h, no GPU) | possible |
| Fidelity | eFootball-adjacent is realistic with enough art | stylized/low-poly, not eFootball |

A 10–30 MB package is achievable with **Godot 4** (or a custom WebGL engine)
using low-poly players, one stadium, shared materials, compressed textures and
Ogg audio — but it will look stylized, not photoreal.

## Track A — Unreal Engine (requested engine)

- Self-hosted runner: 16+ cores, 32–64 GB RAM, 200 GB SSD, GPU for profiling.
- Engine installed locally under the Epic EULA; never committed.
- Size budget must be relaxed to **150–400 MB** (or a custom trimmed build,
  which is a large engineering project on its own).
- Build with `RunUAT BuildCookRun`, cook only the assets the match needs,
  disable unused plugins, use ASTC/BC, compress audio, strip debug symbols.
- CI: `docs/UNREAL.md` in this repo.

## Track B — 10–30 MB (requested size)

- **Godot 4.4.1**, Forward+ for desktop, Mobile renderer for phones/Web.
- One stadium, 8 original teams (shared base meshes + kit textures), 11v11.
- Low-poly players (3k–8k tris), 2 LODs, imposters for the crowd.
- Textures: 1024 kits, 2048 pitch, BC7/ASTC; crowd as one atlas.
- Audio: Ogg Vorbis 64–96 kbps; crowd loop, chants, kicks, whistle, net, UI.
- Web export is the primary 10–30 MB target; Linux/Windows desktop builds are
  optional and larger due to the runtime.

## MVP scope (both tracks)

- Quick match: 2 × 6 minutes, 11v11, 3 difficulty levels, 4 formations.
- Controls: move, pass (short/long), through ball, shoot (power/curve), sprint,
  tackle, slide, switch player, goalkeeper rush; keyboard + gamepad.
- AI: formation shape, marking, pressing, support runs, goalkeeper positioning.
- Rules: goals, out of play, corners, goal kicks, throw-ins, offside (optional
  for MVP), fouls/cards (optional).
- Presentation: menu, team select, HUD, pause, settings, replay of goals.
- Audio: crowd ambience reacting to danger/goals, commentary stingers (original
  voice or text-to-speech), UI, whistle, net, kick impacts, music loop.
- Graphics: day/night, PBR kits, baked lighting, SSAO/SSIL, glow, LODs,
  occlusion culling, 60 fps desktop / 30 fps mobile target.

## Performance and size budgets

| Metric | Desktop | Mobile/Web |
| --- | --- | --- |
| Frame time | 16.6 ms | 33.3 ms |
| Draw calls | 2000 | 800 |
| Triangles | 5M | 1.5M |
| VRAM | 4 GB | 1 GB |
| Package | 10–30 MB (Track B) | 10–30 MB |

## Build and delivery

- Every build runs in the checkpointed workflow: 5h30m internal timeout,
  checkpoint upload, continuation run, previous run cancelled.
- Every release contains the game package, `SHA256SUMS`, and the source
  archive.
- CI must be green: asset validation, headless smoke test, and (on a GPU
  runner) the frame-time budget.
- A playtest checklist and a profiling capture are required before calling a
  milestone "done".

## Owner decisions needed

1. **Engine / size:** Track A (Unreal, 150–400 MB) or Track B (Godot,
   10–30 MB)?
2. If Track A: who provides the Unreal license and the self-hosted runner?
3. Target platform first: Web, Linux, Windows or Android?
4. Art direction and original team/competition names.
5. Is photoreal fidelity required, or is a stylized look acceptable?

Until 1 and 2 are answered, the build cannot start: Unreal is not available on
the hosted runners, and 10–30 MB with Unreal is not physically possible.
