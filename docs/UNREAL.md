# Unreal Engine

Unreal Engine is not installable on GitHub-hosted runners:

- The engine source and derived data are roughly 100 GB; a hosted runner has
  about 14 GB of free disk.
- Access requires an Epic Games account and acceptance of the Unreal Engine
  EULA. The engine cannot be redistributed in a public repository.
- Shader compilation and cooking need many cores and RAM; a 2-core hosted
  runner will not finish a real project in 6 hours.
- Meaningful rendering profiles need a GPU. Hosted runners are CPU-only.

## Supported path: self-hosted runner

Use a self-hosted runner with:

- 16+ cores, 32–64 GB RAM, 200 GB free SSD
- a GPU (for profiling; cooking works without one)
- the Epic account logged in once, engine installed at a fixed path

Register it with a label, for example `self-hosted, linux, unreal`, and target
that label from the workflow. The same 5h50m checkpoint rule applies: save
`DerivedDataCache/`, `Intermediate/`, `Saved/` and `Binaries/`, then hand off.

Typical build command:

```bash
"$UE_ROOT/Engine/Build/BatchFiles/RunUAT.sh" BuildCookRun \
  -project="$PWD/MyGame.uproject" -noP4 -platform=Linux \
  -clientconfig=Shipping -cook -build -stage -pak -archive \
  -archivedirectory="$PWD/build"
```

Packaging for Windows/Android from Linux needs the corresponding toolchains;
run those platforms on a Windows/Android runner instead.

## Licensing

- Do not commit engine source, derived data or paid marketplace assets.
- Keep the Epic credentials in a secret or on the self-hosted machine, never
  in the repository.
- Publish only your game binaries and your own source, not Epic's.

## Quality

The same rules as [OPTIMIZATION.md](OPTIMIZATION.md) apply: LODs, Nanite only
where it pays off, virtual shadow maps budgeted, shader permutations limited,
and a real GPU profiling pass. A successful cook is not a performance result.
