# Profile render suite

The profiling suite renders a collection of scenes from a scenes repo such as: 
[dwanim/example-scenes](https://github.com/dwanim/example-scenes) repository
using MoonRay.  It tracks rendering performance across builds
and, when canonical images have been generated, also validates visual
correctness via an image-diff step — similar to [RATS](../rats/README.md).

The suite is built on [CTest](https://cmake.org/cmake/help/book/mastering-cmake/chapter/Testing%20With%20CMake%20and%20CTest.html)
and is driven by the `ProfileTest.cmake` module found in `cmake/`.  At
configure time CMake scans `PROFILE_SCENES_DIR` for scene files and
registers up to three CTests per scene (`update`, `render`, `diff`).  If
`PROFILE_SCENES_DIR` is not set, no profile tests are registered.

## Test stages

Each scene produces three CTest stages (mirroring RATS):

| Stage | Label | Purpose |
|---|---|---|
| `update` | `profiling;update` | Renders once and saves the result as the canonical reference image in `PROFILE_CANONICAL_DIR`. |
| `render` | `profiling;render` | Renders the scene for profiling; saves a timestamped image+log and a fixed `<stem>.exr` used by the diff stage. |
| `diff` | `profiling;diff` | Runs `idiff` to compare the latest render result against the canonical. Requires `PROFILE_CANONICAL_DIR` at runtime. |

> **Note:** `update` and `diff` tests are only registered when `idiff` is
> found at CMake configure time.  The `render` test always runs regardless.

## Quick start

```bash
# 1. Clone the scene repo next to (or anywhere near) your source tree.
git clone git@github.com:dwanim/example-scenes.git /path/to/example-scenes

# 2. Export the scene location so CMake picks it up automatically.
export PROFILE_SCENES_DIR=/path/to/example-scenes

# Optional: override where images and logs are written (defaults to build tree).
export PROFILE_OUTPUT_DIR=/path/to/output

# Optional: version tag embedded in output filenames (e.g. 1).
export PROFILE_VERSION=1

# Optional: directory where canonical images are stored (required for update/diff).
export PROFILE_CANONICAL_DIR=/path/to/canonicals

# 3. Build as normal — no extra cmake flags needed.
rez-env buildtools -c "rez-build -i --variants 0"

# 4. Run the profile tests from the build directory.
cd build/<variant-path>
source ../../installs/openmoonray/scripts/setup.sh
ctest -L profiling -j $(nproc)
```

## Setting PROFILE_CANONICAL_DIR

`PROFILE_CANONICAL_DIR` is the directory where canonical (reference) images
are stored.  It is a **runtime** env var — checked at test time, not at
configure time — so there is no corresponding CMake cache variable.

```bash
export PROFILE_CANONICAL_DIR=/path/to/canonicals
```

Canonical images are organized as:
```
<PROFILE_CANONICAL_DIR>/<scene-parent-path>/<exec-mode>/<stem>.exr
# e.g. /path/to/canonicals/bitterli/bedroom/scalar/scene.exr
```

To generate canonicals for the first time, run the `update` stage:
```bash
ctest -L profiling -L update
```

Subsequently, the `diff` stage compares every new render against these
canonicals:
```bash
ctest -L profiling -L diff
```

## Setting PROFILE_SCENES_DIR

`PROFILE_SCENES_DIR` can be supplied in two equivalent ways:

| Method | Example |
|---|---|
| Shell environment variable (recommended) | `export PROFILE_SCENES_DIR=/path/to/example-scenes` |
| CMake cache variable | `rez-build -i -- -DPROFILE_SCENES_DIR=/path/to/example-scenes` |

The environment variable is read at cmake-configure time by
`profiling/cmake/ProfileTest.cmake` and stored in the CMake cache, so
it only needs to be set when running `rez-build` (not when running `ctest`).

## Setting PROFILE_OUTPUT_DIR

`PROFILE_OUTPUT_DIR` controls where rendered images and log files are written.
When not set, output lands in `<build-dir>/profiling/profile/`.

| Method | Example |
|---|---|
| Shell environment variable | `export PROFILE_OUTPUT_DIR=/path/to/output` |
| CMake cache variable | `rez-build -i -- -DPROFILE_OUTPUT_DIR=/path/to/output` |

Like `PROFILE_SCENES_DIR`, this only needs to be set at `rez-build` time.

## Setting PROFILE_VERSION

`PROFILE_VERSION` is an optional version tag embedded in output filenames.
When set to `1`, output files look like `2026-06-03_1_sca_scene.txt`.
When empty (the default), the version field is omitted: `2026-06-03_sca_scene.txt`.

Use `PROFILE_VERSION` to distinguish multiple runs performed on the same date
(e.g. `PROFILE_VERSION=1`, `PROFILE_VERSION=2`, …) so that earlier results are
not overwritten.

| Method | Example |
|---|---|
| Shell environment variable | `export PROFILE_VERSION=1` |
| CMake cache variable | `rez-build -i -- -DPROFILE_VERSION=1` |

## Supported scene types

| Extension | Renderer |
|---|---|
| `.rdla` | `moonray` — three tests per scene: `sca`, `vec`, and `xpu` exec modes |

All scene files found recursively under `PROFILE_SCENES_DIR` are included.

## Test labels

Every profile CTest is tagged with the following labels:

| Label | Meaning |
|---|---|
| `profiling` | Selects all profile tests: `ctest -L profiling` |
| `update` | Selects only the update (canonical generation) stage |
| `render` | Selects only the render (profiling + result image) stage |
| `diff` | Selects only the diff (image comparison) stage |
| `moonray` | Selects by renderer: `ctest -L profiling -L moonray` |
| `sca`, `vec`, `xpu` | Selects by moonray exec mode: `ctest -L profiling -L sca` |

## Test names

Tests follow the same naming convention as RaTS:

```
<stage>-<mode>-<parent-directory-of-scene>[.<image>]
```

where `<stage>` is `update`, `render`, or `diff`; `<mode>` is `sca`, `vec`,
`xpu` (moonray); and `<parent-directory-of-scene>` is
the scene file's parent directory relative to `PROFILE_SCENES_DIR`.
`diff` tests also include the image filename suffix.  For example:

```
bitterli/bedroom/scene.rdla  ->
  update-sca-bitterli/bedroom
  render-sca-bitterli/bedroom
  diff-sca-bitterli/bedroom-scene.exr
  update-vec-bitterli/bedroom
  render-vec-bitterli/bedroom
  diff-vec-bitterli/bedroom-scene.exr
  ...

bitterli/coffee_maker/scene.usdc  ->
  update-hd-bitterli/coffee_maker
  render-hd-bitterli/coffee_maker
  diff-hd-bitterli/coffee_maker-scene.exr
```

The `profiling` label distinguishes these from RaTS tests when filtering
with `ctest -L`.

Use `ctest -N -L profiling` to list all registered profile tests without
running them.

## Output files

Each scene gets its own output directory matching its test name path under
`PROFILE_OUTPUT_DIR` (or the build tree when unset).  Files within that
directory are named with the date, optional version tag, mode, and scene stem
so that successive runs accumulate and can be compared over time:

```
<output_dir>/
  bitterli/
    bedroom/
      2026-06-03_1_sca_scene.exr
      2026-06-03_1_sca_scene.txt
      2026-06-03_1_vec_scene.exr
      2026-06-03_1_vec_scene.txt
      2026-06-03_1_xpu_scene.exr
      2026-06-03_1_xpu_scene.txt
    coffee_maker/
      2026-06-03_1_sca_scene.exr
      ...
```

| File | Contents |
|---|---|
| `<date>[_version]_<mode>_<stem>.exr` | Rendered image |
| `<date>[_version]_<mode>_<stem>.txt` | Combined stdout/stderr from the renderer |

## Running a subset of tests

```bash
# Run only the render stage (profiling, no diff)
ctest -L profiling -L render

# Generate canonicals (first time or after a known-good build)
ctest -L profiling -L update

# Run only the diff stage to check image quality
ctest -L profiling -L diff

# Run only moonray profile tests
ctest -L profiling -L moonray

# Run a single scene by name (supports regex)
ctest -R render-sca-bitterli/bedroom

# Dry-run: list matching tests without executing them
ctest -N -L profiling
```

## GitHub Actions

The `CI/Profile - Rocky9/Cobalt` workflow lives in the
[dwanim/openmoonray_dwa](https://github.com/dwanim/openmoonray_dwa) repository
at `.github/workflows/run_CI_Profile.yml`.  It automates the full cycle on a
self-hosted runner:

1. Clones `openmoonray_dwa` (with submodules, including this repo).
2. Clones the configured scenes repo (default `dwanim/example-scenes`) to
   `example_scenes/`.
3. Validates that at least one scene file was found.
4. Calls `openmoonray_dwa/.github/workflows/scripts/build_profile.sh` which
   exports `PROFILE_SCENES_DIR` and runs `rez-build`, then writes
   `PROFILE_TEST_PACKAGE`, `PROFILE_VARIANT`, and `PROFILE_BUILD_DIR` to
   `$GITHUB_ENV` for subsequent steps.
5. Calls `openmoonray_dwa/.github/workflows/scripts/run_profile.sh` which runs
   `ctest` directly (bypassing `rez-test`) so that the label filter
   `-L profiling -L <stage>` can be applied at runtime.

The workflow is triggered manually via **workflow_dispatch** with the
following inputs:

| Input | Default | Description |
|---|---|---|
| `output_dir` | _(build tree)_ | Directory on the runner where images and logs are saved |
| `version_tag` | `1` | Version tag embedded in output filenames (e.g. `1`) |
| `scenes_repo` | `dwanim/example-scenes` | Example-scenes repository in `owner/repo` format |
| `scenes_ref` | `main` | Branch, tag, or SHA of the example-scenes repo to clone |
| `run_render` | `true` | Run the render tests (`ctest` label: `render`) |
| `run_update` | `false` | Run the update/canonical-generation tests (`ctest` label: `update`) |
| `run_diff` | `false` | Run the diff/image-comparison tests (`ctest` label: `diff`) |
| `canonical_dir` | _(empty)_ | Directory containing (or to write) canonical reference images; required when `run_update` or `run_diff` is true |
| `machine_type` | `cobalt` | Runner label / EF resource class |
| `borrow_from_EF` | `true` | Whether to borrow a render host from EF |
| `variant` | `0` | `package.py` variant index to build and profile |

> **Note:** At least one of `run_render`, `run_update`, or `run_diff` must
> be enabled; the workflow fails fast if all three are false.
