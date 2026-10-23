# Game Forge

A production-oriented 3D game build pipeline on **Godot 4** with a hard
**5h50m** GitHub Actions cap and automatic continuation runs.

The goal is an AA-scale pipeline: Forward+ rendering, PBR materials, asset and
performance budgets, reproducible exports, and a build that survives GitHub's
6-hour limit by checkpointing and handing off to a new run.

## What this is, and what it is not

This repository gives the agent a real 3D engine, a sample project, export
presets and CI that can build high-end 3D games. It does **not** claim that any
pipeline can guarantee a AAA game with zero glitches or zero frame drops.
Quality comes from the assets, the art direction and profiling; the pipeline
enforces budgets and makes regressions visible.

- **Supported here:** Godot 4.4.1, Forward+ / Mobile renderers, Linux and Web
  exports, headless smoke tests, asset budgets, frame-time budgets.
- **Not supported on GitHub-hosted runners:** Unreal Engine. It requires an
  Epic account and EULA acceptance, roughly 100 GB of engine + derived data,
  far more than the 14 GB runner disk, and a GPU for meaningful profiling.
  See [docs/UNREAL.md](docs/UNREAL.md) for the self-hosted path.

## The 5h50m rule

GitHub cancels a job at 6 hours. Every build here obeys two limits:

| Limit | Value |
| --- | --- |
| job `timeout-minutes` | 350 (5h50m) |
| internal build timeout | 19800 s (5h30m), leaving 20m to checkpoint |

At 5h30m the workflow:

1. writes `build-state.tar.gz` (sources, `.godot/`, `build/`, `.cache/`),
2. uploads it as the `build-state-<run-id>` artifact,
3. dispatches the next `build.yml` run with `previous_run=<run-id>`,
4. the continuation restores the checkpoint, cancels the old run if it is
   still alive, and resumes the same build command.

The build command must be resumable. `make`, `ninja`, SCons, Godot's import
cache and the export step are. A build script that always starts from zero
still works, but it loses the time saved by the checkpoint.

You can prove the mechanism without waiting five hours:

```bash
gh workflow run build.yml --repo mmunki/game-forge \
  -f mode=selftest -f timeout_seconds=5 -f max_attempts=6 \
  -f build_cmd='if [ -f .ci/phase2 ]; then echo COMPLETE; elif [ -f .ci/phase1 ]; then mkdir -p .ci; touch .ci/phase2; sleep 100; else mkdir -p .ci; touch .ci/phase1; sleep 100; fi'
```

The first run times out after 5s with `phase1`, the second with `phase2`, and
the third finishes. Each continuation is a new workflow run.

## Layout

```
project.godot              Godot 4 project (Forward+)
scenes/main.tscn           demo scene: PBR box, lighting, SSAO/SSIL, glow
scripts/spin.gd            small animation script
export_presets.cfg         Linux + Web presets
tools/fetch_godot.sh       pinned editor + export templates
tools/build.sh             import, export, headless smoke test, zip, sha256
tools/validate_assets.py   texture/mesh/audio budget checks
tools/perf_budget.py       frame-time / draw-call / VRAM gates
perf/budget.json           performance budget
docs/OPTIMIZATION.md       rendering, CPU and asset guidelines
docs/UNREAL.md             Unreal Engine on a self-hosted runner
.github/workflows/build.yml  the checkpointed build
```

## Run it locally

```bash
bash tools/fetch_godot.sh        # prints the editor path
export GODOT="$(bash tools/fetch_godot.sh | tail -1)"
bash tools/build.sh
```

The exports land in `build/linux/game-forge.x86_64` and `build/web/`, with
`build/SHA256SUMS`.

## Quality gates

`tools/validate_assets.py --strict` fails on oversized textures, oversized
assets, and long WAV files; it warns about non-power-of-two textures and heavy
meshes. `tools/perf_budget.py` enforces:

| Metric | Budget |
| --- | --- |
| frame time | 16.6 ms |
| p99 frame time | 20 ms |
| draw calls | 2000 |
| triangles | 5,000,000 |
| VRAM | 4096 MB |

GitHub-hosted runners have no GPU, so the frame-time report is only enforced
when a GPU runner writes `perf/report.json` and sets `PERF_REQUIRED=1`. The
asset budgets run everywhere.

## Getting closer to "no lag"

The pipeline cannot create art, but it can keep the frame budget honest:
texture compression, LODs, visibility ranges, occlusion culling, MultiMesh
instancing, draw-call batching, physics layers, object pooling and a real GPU
profiling pass. The concrete checklist is in
[docs/OPTIMIZATION.md](docs/OPTIMIZATION.md).
