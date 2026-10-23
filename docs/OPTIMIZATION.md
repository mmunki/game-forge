# Optimization checklist

A 60 fps budget is 16.6 ms per frame. Pick the target device first, then keep
the frame inside the budget. The numbers below are the defaults used by
`perf/budget.json`; lower them for mobile.

## Rendering

- Use **Forward+** for desktop and **Mobile** for phones. Do not ship Forward+
  to a low-end mobile GPU.
- Enable **MSAA 2x** instead of 4x/8x when using SSAO or glow; resolve cost
  grows quickly.
- Prefer **baked lightmaps + ReflectionProbes** over real-time SDFGI for large
  static worlds. SDFGI is expensive and should be reserved for a showcase
  scene.
- Add **LODs** and `visibility_range_begin/end` to every hero mesh. A 2M
  triangle mesh with no LOD will dominate the frame.
- Use **MultiMeshInstance3D** for repeated props (trees, rocks, bullets,
  debris). One draw call instead of hundreds.
- Enable **occlusion culling** for indoor scenes and bake the occluder mesh.
- Cap **shadow maps**: `directional_shadow_max_distance` around 80–120 m and
  2 or 3 splits; disable shadows on fill lights.
- Compress textures: BC7/BC5 on desktop, ASTC on mobile. Keep UI at 1x/2x
  resolution, not 4K.
- Keep the **shader variant** count small. Every unique material permutation
  is a pipeline compile and a state change.
- Batch by material and texture; sort transparent surfaces; avoid full-screen
  transparency layers.

## CPU

- Profile before optimizing. The Godot **Profiler** and **Monitor** tabs show
  script, physics and render times; use RenderDoc for GPU passes.
- Avoid allocations in `_process`/`_physics_process`. Reuse `Vector3`,
  arrays and dictionaries.
- Use `Timer`/`await` instead of polling every frame; use signals for events.
- Put static geometry and props on separate **physics layers**; disable
  collisions that never matter.
- Pool bullets, particles and enemies; `queue_free()` is not free.
- Use `WorkerThreadPool` / `Thread` for pathfinding, terrain generation and
  asset decoding, never for scene-tree mutation.
- Set a fixed physics tick (60 Hz is usually enough) and interpolate visuals.

## Assets

- Texture: max 4096 px, square, power-of-two when mipmapping. UI atlases
  should be 2048 or smaller.
- Mesh: budget by screen size. A hero character is 30k–80k triangles; a
  background prop is 500–5k; use imposter/LOD beyond that.
- Audio: Ogg Vorbis for music and long SFX; WAV only for short, latency-
  critical sounds. Keep WAV under 30 s (the CI enforces this).
- Use texture arrays or atlases for UI and decals; avoid one material per
  sprite.
- Keep the project's `.godot/imported` cache in the checkpoint; reimporting
  thousands of assets is the most common reason a build exceeds the limit.

## CI gates

```bash
python3 tools/validate_assets.py --strict
PERF_REQUIRED=1 python3 tools/perf_budget.py
```

A GPU runner should run the benchmark scene, write `perf/report.json`, and set
`PERF_REQUIRED=1`. Hosted runners can only run the asset and smoke checks.

## Definition of done for a graphics milestone

1. 60 fps average and p99 under 20 ms on the target device.
2. Draw calls under 2000, triangles under 5M, VRAM under 4 GB.
3. No shader compile hitch during the first 30 seconds of gameplay.
4. No per-frame allocations in steady state.
5. A profiling capture (Godot profiler + RenderDoc) is attached to the
   milestone issue.
