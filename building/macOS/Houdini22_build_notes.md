# Houdini 22 macOS alignment notes

This document records the changes and validation performed on the
`test/houdini22-clean-build` branch. The work started from
`OpenMoonRay/openmoonray` `main` at `b9b0ac2` and targets Houdini 22.0.408 on
Apple Silicon. Later sections explicitly identify follow-up validation on
Houdini 22.0.440; those results do not replace the original build baseline.

This is a validation branch, not a statement of upstream support for every
Houdini 22 production workflow.

## Validated platform

- Houdini 22.0.408
- Houdini USD 26.05
- Houdini Python 3.13.10
- AppleClang arm64 with C++20
- macOS Tahoe on Apple Silicon
- Qt applications disabled
- MaterialX shader DSOs and Houdini nodes enabled
- Houdini's USD, Python, Vulkan headers, and Vulkan library used by the build
- MoonRay Embree generation retained at Embree 4
- Metal accelerator compatibility retained, while `MOONRAY_USE_METAL` remains
  disabled in the validation preset

## Dependency alignment

The macOS dependency build was refreshed without building a second USD copy.
The Houdini build uses `NO_USD=1` and links against Houdini's USD 26.05.

| Dependency | Version |
| --- | --- |
| Boost | 1.88.0 |
| OpenSubdiv | 3.7.0 |
| Imath | 3.2.2 |
| OpenEXR | 3.4.3 |
| oneTBB | 2022.1.0 |
| OpenVDB | 13.0.0 |
| OpenColorIO | 2.5.0 |
| OpenImageIO | 2.5.18.0 |
| MaterialX | 1.39.5 |
| OpenImageDenoise | 2.3.3 |
| Embree | 4.2.0 |

The dependency work also:

- builds standalone Imath before OpenEXR 3;
- uses oneTBB's CMake build and install flow;
- removes OIDN's bundled TBB libraries so the dependency tree uses one TBB;
- disables Boost.NumPy, which is not required and did not build against the
  Houdini Python configuration;
- uses Houdini Python 3.13 for Boost.Python and OpenImageIO;
- installs MaterialX independently instead of relying on Houdini's private copy;
- disables Qt and GUI applications for this build;
- isolates dependency discovery from Homebrew to avoid accidental ABI mixing;
- supplies CMake 4 policy compatibility to older dependency projects.

## Houdini USD 26.05 integration

The local PXR imported-target shim was regenerated for Houdini 22. The target
set follows the libraries shipped by Houdini 22.0.408, including `hdsi`,
`usdRi`, and `usdviewq`. Obsolete targets not shipped by this USD build, such as
`ndr` and `usdRiImaging`, are not synthesized. `usdRiPxrImaging` is also not
invented when Houdini does not ship that library.

The shim uses Houdini's Python 3.13 framework and
`libhboost_python313-mt-a64.dylib`. A small Boost.Asio compatibility header is
provided for USD code that still includes the removed `io_service.hpp` path.

The root preset now uses:

- `CMAKE_CXX_STANDARD=20`;
- Houdini's Python executable and Python 3.13 module paths;
- Houdini's Vulkan include directory and library;
- Unix Makefiles for the Houdini configuration;
- `BUILD_MATERIALX_SHADERS=ON`;
- `BUILD_QT_APPS=OFF`;
- `BUILD_MOONRAY_SDR_PLUGINS=OFF` for the legacy SDR plugin path.

## Submodule alignment and compatibility work

The branch intentionally pins coordinated submodule revisions. The effective
changes are summarized below.

### hdMoonray

- starts from Rob's Hydra 2.0 `hdm_10` work;
- adapts renderer plugin entry points for USD 26;
- adds C++20 and Houdini 22 integer-value compatibility;
- retains the Apple Silicon half-float AOV allocation fix;
- keeps the internal `HdMoonray_Light` class name—this is a C++ implementation
  name, not a Hydra prim token;
- recognizes Houdini 22's `houdini:viewport` setting as an interactive client;
- keeps an active Render Settings prim on the interactive Solaris render-pass
  path instead of switching IPR to the one-shot disk-product path;
- invalidates completed offline product renders when their Render Settings or
  scene changes.

Houdini's generic Light LOP is expected to produce a Hydra `SphereLight` with
`moonray:class=PointLight`. Its default position is the origin; if the test
sphere is also at the origin, the point light is inside the sphere and the
outside initially appears black.

### MoonRay, scene_rdl2, and Moonshine

- replaces the Metal GPU accelerator map's legacy `tbb::atomic` use with
  `std::atomic`;
- adds the remaining USD 26 and oneTBB source compatibility needed by the
  H22 build;
- fixes ARM half conversion in MoonRay render-output writing and scene_rdl2
  tile packing;
- adjusts macOS compiler, Python framework loading, and signing compatibility;
- fixes a C++20 attribute lookup in Moonshine's DwaBase material path.

### MaterialX and Houdini DCC plugins

- builds MaterialX shaders against the standalone MaterialX 1.39.5 package;
- updates MaterialX source compatibility for Houdini 22/C++20;
- uses Nick's updated DCC plugin work as the plugin base;
- supports MaterialX HDA generation with USD 26;
- installs the Houdini startup hook in the Python 3.13 location;
- installs renderer `.ds` files and HDAs beneath the OpenMoonRay Houdini plugin
  directory.

### Artist-facing Solaris tools

The H22 DCC payload includes an editable **MoonRay Material Builder** shelf
tool. Create it inside a Solaris Material Library; it creates a native
`DwaBaseMaterial` and `NormalDisplacement` network and publishes `surface` and
`displacement` through Houdini 22's `suboutput` node. The builder is a plain
editable subnet, so additional MoonRay VOPs can be inserted without editing a
locked asset.

The Light Filter Library includes the MoonRay filter HDAs supplied by the DCC
plugin (`IntensityLightFilter`, `DecayLightFilter`, `CookieLightFilter`,
`BarnDoorLightFilter`, `ColorRampLightFilter`, `CombineLightFilter`,
`RodLightFilter`, and `VdbLightFilter`). These are intended to be created
inside a Solaris Light Filter Library rather than a regular material network.

Render Geometry already exposes MoonRay mesh tessellation controls in
`HdMoonrayRendererPlugin_Geometry.ds`. Set the control mode to **Set or Create**
before editing **Mesh Resolution** or **Adaptive Error**; their default
**Do Nothing** mode intentionally leaves existing scene-authored primvars
untouched.

### MoonRay RenderVars and Hydra AOVs (Houdini 22.0.440)

The DCC integration now contains one **MoonRay RenderVars** Solaris HDA,
`DW_MOONRAY::moonrayrendervars::1`, with grouped AOV toggles. The asset authors
standard USD RenderVars through standard Render Var LOPs, with native MoonRay
overrides. Its default root is `/Render/Vars`; all built-in outputs start
disabled. This work adds no custom ROP or render-settings HDA and no
DisplayFilter graph construction.

The authoring contract follows [PR #228](https://github.com/OpenMoonRay/openmoonray/pull/228),
while transport validation uses the current H22 Hydra scene-index delegate.
Beauty remains `sourceName=color`, `dataType=color4f`, and
`driver:parameters:aov:format=color4f`. Its float RGBA buffer format is fixed
to avoid the earlier RGB packing failure. Native result and expression fields
are authored explicitly as `parameters:moonray:*`, rather than assuming the
current delegate recognizes every preset alias.

Presets include beauty, alpha, depth, Z, N, Ng, P, Wp, St, weight, state-variable
derivatives, motion vectors, heatmap, wireframe, denoise albedo/normal, and
material albedo/emission/normal/roughness/PBR validity/color/matte. `Z` selects
the native camera-distance state variable; `depth` uses Hydra depth semantics.
There is no user-facing `cameraDepth` preset. Custom entries support primitive
attributes, material expressions, LPEs, visibility and Extra AOV user events.
Names must be valid unique USD identifiers and required expressions must be
present. Outputs use float precision and native default math filters; tested
RGB/XYZ outputs also offer half precision.

**Set Up AOV Preview** optionally creates or reuses a separate branch of standard
Render Product, Render Settings and Configure Layer LOPs. The product is raster;
its live RenderVar list puts enabled beauty first, then the remaining variables
by path. Configure Layer activates the settings, and the button displays the
final node and selects the production MoonRay delegate in available Solaris
viewers. It creates no output destination or render launcher. Re-running the
button updates the generated branch without replacing other downstream nodes.
Disk rendering continues to use standard products and the USD Render ROP/husk.

The delegate declares `aovsupport=true`. A narrow render-pass fix keeps clients
with explicit AOV bindings on the existing buffer route, even with active
Render Settings. Previously, husk saved its unfilled buffers over MoonRay's
direct product image. Batch buffer rendering also applies the active MoonRay
settings, including deep-ID configuration.

The H22 compatibility layer also carries the narrowly scoped conversions proven
by the earlier AOV work. `SdfAssetPath` values convert to every MoonRay string
attribute, using the resolved path when available and the authored path as a
fallback. Token and string ramp interpolation values convert to MoonRay's
`IntVector` representation; Houdini spellings such as `hermite`, `smoothstep`,
`bezier` and B-spline map to the supported smooth mode. Default `AttributeMap`
requests named `P` and `N` select MoonRay's built-in position and shading-normal
modes, while an explicitly authored `map_type` is preserved. Invalid shader
connections remain errors.

Hydra display refinement now affects MoonRay `mesh_resolution` only for
subdivision surfaces. Polygon meshes, including subdivision scheme `none`, use
resolution 1 unless `moonray:mesh_resolution` is explicitly authored. This
prevents a high global refine level from expanding an already dense displaced
polygon mesh into an unbounded tessellation while preserving artist overrides.

MaterialX shader DSOs need a platform-specific install RPATH on macOS. They now
use `@loader_path` and `@loader_path/../lib`; Linux retains `$ORIGIN`. This lets
installed `ND_texcoord_vector2` and `ND_image_vector3` DSOs locate the sibling
`libmoonray_mtlx_map.dylib`.

Arras `stopped`/`stopping` status and exhausted connection retries now mark a
failed frame complete, clear the active update and preserve the stop reason.
Hydra therefore ends its convergence wait instead of leaving husk idle at low
CPU. Houdini 22.0.440 does not propagate this as a nonzero husk exit status and
can write a small empty EXR, so validation must inspect the log and pixels.

| Check | Classification | Evidence / limit |
| --- | --- | --- |
| HDA authoring | PROVEN | Preset toggles, root changes, duplicate names, missing expressions, custom entries and save/reopen checked. |
| Preview setup and ordering | PROVEN / OBSERVED | Standard USD product/settings relationships, beauty-first ordering, repeated clicks and recooks pass automated checks. User confirmed the live AOV menu works; the final beauty-first GUI order remains unconfirmed. |
| Production Hydra render/readback | PROVEN for tested outputs | Individual and combined fixtures exercised `HdMoonrayRendererPlugin`; a combined 38-part EXR contains scene-dependent native, material, denoise and custom outputs. Copernicus reads all layers and their expected component counts. |
| Numerical values | PROVEN for fixture | Custom scalar attribute is exactly 0.375; emission retains linear values 0.1/0.02/0.01; safe RGB/XYZ half outputs match float within tested tolerance. |
| Render completion | OBSERVED | Of 40 fixtures, 30 exit cleanly, 8 abort during shutdown after writing filled EXRs, and 2 auxiliary-only fixtures crash without an EXR. Written pixels do not classify aborts as clean passes. |
| Renderer failure termination | PROVEN / constrained | A production-scene MCRT crash ends the wait in about 22 seconds and reports `Arras session stopped: ... signal 11`; husk still returns zero and writes an empty EXR. |
| Saved production scene | PROVEN output / shutdown constrained | Without scene edits, the 1,046,074-triangle displaced polygon mesh renders a finite 40x23 RGBA EXR. The generated RDL uses `mesh_resolution=1`; the previous refine-level value 256 caused a vector-length failure and downstream MCRT crash. The known post-output `Pure virtual function called` shutdown abort remains. |
| Cryptomatte / adaptive auxiliary outputs | UNSUPPORTED in tested buffer route | Cryptomatte is zero with no usable coverage/manifest; auxiliary outputs are zero in the combined fixture and crash alone. |
| Material radius / factor | EXPERIMENTAL | Radius is zero without a subsurface proof scene. Factor is finite and nonzero (fixture maximum 3.8276417), but has no known reference result. |

Scalar/UV and wireframe half readback produced corruption or NaNs in this runtime.
Their presets stay float, and custom scalar/UV half requests produce a node error.
This is distinct from the historical ARM half-conversion fix already present in
the source; the precise loss point is not established. The unrestricted-half
reproducer and render/EXR logs are retained under
`runtime-fixtures/moonray_rendervars`. Shutdown failures report
`Pure virtual function called` and remain unresolved.

Cryptomatte, beauty/alpha auxiliary and material radius/factor controls are
explicitly labeled **Experimental** and remain disabled by default. They are
available for investigation, not production-supported outputs. Promotion requires
clean individual and combined production Hydra renders, correct component and
channel readback, and Solaris toggle/recook/save/reopen checks. Cryptomatte also
needs usable ID coverage, manifest metadata and compositor extraction; auxiliary
outputs need a generating adaptive-buffer fixture and resolution of their
crashes; radius/factor need known nonzero material proof scenes. These criteria
are recorded in the node guide linked below. Marking these controls experimental
does not resolve the separate renderer shutdown failures.

Implementation lives in `moonray/moonray_dcc_plugins/scripts/build_moonray_rendervars.py`
and `houdini/otls/Lop::DW_MOONRAY::moonrayrendervars::1.hda` within that submodule.
The generator embeds its PythonModule and requires no Arnold dependency or
external startup module. Builds use a temporary directory to keep intermediate
HDA backups out of the source tree. CMake installs the asset, generator and
node-specific guide. Full preset mappings and usage are in
[`moonray_rendervars.md`](../../moonray/moonray_dcc_plugins/houdini/docs/moonray_rendervars.md).

Validation scripts in the DCC submodule's `houdini/tests` are
`validate_moonray_rendervars.py` (authoring and USD fixtures),
`validate_moonray_preview.py` (standard preview relationships and ordering),
`render_moonray_rendervars.py` (production husk and OpenImageIO statistics), and
`read_moonray_rendervars.py` (Copernicus). Existing Hydra primvar-sampling and
render-pass compatibility/convergence checks pass (3/3).

The clean-build validation environment was Houdini 22.0.440 with
`HdMoonrayRendererPlugin` from `/Applications/MoonRay/installs/openmoonray`.
The focused commands were:

```sh
cmake --build /Applications/MoonRay/build --target \
  hydramoonray hd_moonray hd_moonray_debug \
  hdmoonray_compatibility_test hdmoonray_renderpass_convergence_test \
  hdmoonray_primvar_sampling_test -j8

env \
  DYLD_LIBRARY_PATH=/Applications/MoonRay/build/moonray/hydra/hdMoonray/lib/hydramoonray:/Applications/Houdini/Houdini22.0.440/Frameworks/Python.framework/Versions/3.13:/Applications/Houdini/Houdini22.0.440/Frameworks/Houdini.framework/Versions/Current/Libraries:/Applications/MoonRay/installs/openmoonray/lib:/Applications/MoonRay/installs/lib \
  RDL2_DSO_PATH=/Applications/MoonRay/installs/openmoonray/rdl2dso.proxy:/Applications/MoonRay/installs/openmoonray/rdl2dso \
  ctest --test-dir /Applications/MoonRay/build/moonray/hydra/hdMoonray/tests \
    --output-on-failure \
    -R '^hdmoonray_(compatibility|renderpass_convergence|primvar_sampling)$'

source /Applications/MoonRay/installs/openmoonray/scripts/macOS/setupHoudini.sh
/Applications/Houdini/Houdini22.0.440/Frameworks/Houdini.framework/Versions/Current/Resources/bin/husk \
  -R HdMoonrayRendererPlugin --headlight none --no-mplay \
  --make-output-path --fast-exit 1 --settings /Render/Settings -f 1 \
  /Applications/MoonRay/runtime-fixtures/moonray_rendervars/combined.usda
oiiotool --info -v -a \
  /Applications/MoonRay/runtime-fixtures/moonray_rendervars/combined.exr
```

### Arras and IPR lifecycle

The apparent scene-update starvation had two independent causes.

First, Athena UDP telemetry was called inline from Arras message delivery. A
blocking `sendto()` to an unavailable local syslog target could stop the client
before scene updates were delivered. The socket is now non-blocking and logging
is best-effort.

Second, hdm10 treated every active Render Settings prim as an offline product
render. In Solaris this latched `mProductRenderComplete` after one execution and
prevented later IPR changes. Houdini 22 viewport detection and render-pass
routing now keep that path interactive.

Temporary full-scene reload, renderer pausing, client-message serialization,
and deferred-MCRT queue workarounds were tested and reverted after transport
and render-pass tracing identified the actual causes. Investigation-only frame
and queue logging was also removed from the final state.

### Timeline animation updates (Houdini 22.0.440)

The subsequent timeline fix is recorded in hdMoonray commit `930e5b2`, pinned
by superproject commit `5335e20`. This validation used Houdini 22.0.440 rather
than the original 22.0.408 build described elsewhere in this document.

The baseline trace identified an attribute type mismatch during animated
points synchronization: `vertex_list_0` expected `Vec3fVector` but received
`Vec3f`. In `HdMoonray_GeometryBase::setVec3fPrimvarMb()` in
`lib/hydramoonray/primvars.cc`, both motion samples were incorrectly assigned
their first vertex instead of the complete array. The caught exception left
previous geometry in place, explaining why the viewport stayed on an earlier
animation frame even though scene synchronization occurred.

The minimal fix passes `firstSample` and `secondSample` directly to the two
RDL attributes. It does not change AOVs, convergence, final-image presentation,
viewport/product classification, Arras sessions, or the transport protocol.
No generation-lifecycle architecture or full-snapshot workaround is included.
Temporary diagnostic instrumentation was removed before committing.

With `BUILD_TESTING=ON`, run the focused regression and shading tests from the
build directory using the configured Houdini runtime library environment:

```bash
ctest -R '^(hdmoonray_primvar_sampling|moonray_rendering_shading_tests)$' --output-on-failure
```

The regression exercises the production points dispatch for `1 -> 10 -> 1`,
verifies every vertex in both motion samples, and checks empty arrays. It
fails against the previous implementation; both tests pass with the fix.

Validation used the installed normal Arras-backed **Moonray** delegate, not
**Moonray (debug)**:

- `1 -> 10 -> 1` and rapid scrubbing followed by a settled frame update geometry;
- selecting the same frame again does not restart rendering;
- a reversible light exposure edit updates IPR;
- a representative installed-delegate USD render produces non-black pixels;
- the test-created MCRT process exits after delegate teardown.

The Houdini project was not saved, the temporary light edit was undone, and
the original frame was restored. Only the shared Hydra library, normal plugin,
and regression target needed rebuilding; Houdini was restarted to load the
installed binaries. A documentation-only update requires no rebuild.

### Lighting update fix (Houdini 22.0.440)

Implemented in hdMoonray commit `9fdd0be` and validated on 2026-09-18.

The lighting-variations project exposed two update hazards independently of
AOV definitions. A focused regression reproduces the first against the
baseline: after final-image completion is cached, `IsConverged()` still returns
true when a subsequent scene edit is pending. The pending-update check now
precedes both completion shortcuts, clears their cached state, and returns
false so Hydra can execute and submit the edit. The two-query final-image
presentation workaround is retained.

The baseline rig-switch trace also shows replacement lights synchronizing and
an Arras delta being submitted without subsequent geometry synchronization.
Geometry's category tokens can remain unchanged while their light membership
changes, leaving Layer assignments pointing at disabled lights. Membership
changes are now recorded under the category mutex and consumed once before
render submission. Existing geometry/part assignments are refreshed from
current categories on both Hydra paths, without forcing geometry rebuilds or
session recreation. Duplicate category registrations do not trigger refreshes.

Regression coverage checks pending edits after convergence, repeated queries,
new-frame completion and final presentation, and actual Layer LightSets through
an A/B/A light replacement. Run:

```bash
ctest -R '^(hdmoonray_renderpass_convergence|hdmoonray_primvar_sampling|moonray_rendering_shading_tests)$' --output-on-failure
```

These tests pass against the installed build. The normal Arras delegate also
produces non-black pixels for the representative two-triangle USD and its test
computation exits. A preliminary path-specific refresh still produced a black
rig-switch capture, so the final refresh handles both Hydra paths.

Final live acceptance used normal **Moonray** in a fresh Houdini Indie 22.0.440
process with the lighting-variations project. Native viewport screenshots
confirmed visible updates for exposure, intensity, color and transform edits,
the `0 -> 4 -> 0` return switch, and rapid `4 -> 2 -> 4 -> 0` switching. The
trace recorded eleven updates over one Arras connection, using the same MCRT
process throughout; the count remained unchanged while the scene was idle.
After restoring every tested parameter (including its expression/keyframes)
and the original frame, the validation process was closed without saving the
project and its MCRT child exited. The existing window's unsaved edits were
left intact and its temporary renderer pause was restored.

The project has an additional artist-facing trap: `WINDOW_KEY` exposure uses
`10 + ch("../CTRL_LIGHTING_LOOK/exposure_trim")`. Numeric edits that leave this
expression in place do not change its evaluated exposure. Change the controller
trim, or deliberately replace the expression, before diagnosing such an edit
as renderer staleness. Acceptance changed the evaluated values and restored
the original expressions afterward.

No visibility-only patch was made without a demonstrated failure. Public
settings, AOVs, transport and color management remain unchanged. Both plugins
were rebuilt for the internal delegate-layout change, but **Moonray (Debug)**
was not used for acceptance. Restart existing Houdini processes after install;
they retain the previously loaded library until exit.

## Clean build procedure

The paths below match the checked-in validation preset. Change the Houdini
installation path in `CMakeMacOSPresets.json`, `building/macOS/CMakeLists.txt`,
and `building/macOS/user-config.jam` when testing another Houdini build.

From a clean checkout with recursively initialized submodules:

```bash
mkdir -p /Applications/MoonRay/{build,build-deps,installs}

cmake \
  -S /Applications/MoonRay/source/openmoonray/building/macOS \
  -B /Applications/MoonRay/build-deps \
  -DNO_USD=1 \
  -DNO_QT=1
cmake --build /Applications/MoonRay/build-deps --parallel

cmake \
  --preset macos-houdini-release \
  -S /Applications/MoonRay/source/openmoonray
cmake --build --preset macos-houdini-release --parallel
```

The install prefix is `/Applications/MoonRay/installs/openmoonray`.

## Houdini plugin and HDA refresh

The normal root install copies the plugin. To regenerate HDAs after changing
RDL2 proxy definitions:

```bash
cd /Applications/Houdini/Houdini22.0.408/Frameworks/Houdini.framework/Versions/Current/Resources
source ./houdini_setup
source /Applications/MoonRay/installs/openmoonray/scripts/macOS/setupHoudini.sh

cd /Applications/MoonRay/source/openmoonray/moonray/moonray_dcc_plugins
hython scripts/update_hdas.py --output-dir ./houdini
cmake --install /Applications/MoonRay/build
```

This flow generated standard nodes such as `VdbVolume` and `DwaBaseMaterial`
and MaterialX `ND_*` nodes from the fresh proxy libraries.

## Launch command

Start Houdini from a terminal so its USD and Python environment is established
before the OpenMoonRay setup is applied:

```bash
cd /Applications/Houdini/Houdini22.0.408/Frameworks/Houdini.framework/Versions/Current/Resources
source ./houdini_setup
source /Applications/MoonRay/installs/openmoonray/scripts/macOS/setupHoudini.sh
houdini
```

## Validation performed

The final installed Release and Debug delegates were loaded in a fresh Houdini
22.0.408 process. Validation covered:

- MoonRay renderer discovery in the Solaris viewport;
- a sphere rendered with the generic Houdini Light LOP resolved as
  `SphereLight` plus `moonray:class=PointLight`;
- repeated PointLight intensity edits with distinct completed framebuffers;
- an active `/Render/rendersettings` prim;
- live `pixel_samples` changes with new Arras synchronization IDs and distinct
  completed framebuffers;
- MaterialX shader DSO and `ND_*` node generation;
- ARM half-float framebuffer/AOV paths;
- successful compilation and installation of `hd_moonray`,
  `hd_moonray_debug`, and `computation_progmcrt`.

The install step may print duplicate `LC_RPATH` warnings when reinstalling over
an existing tree. They did not prevent the rebuilt binaries from being
installed or loaded during this validation.

## Remaining scope

- The preset is intentionally pinned to Houdini 22.0.408 paths.
- Qt applications and the MoonRay GUI were not part of this validation.
- Metal rendering is disabled in the preset; only the source compatibility fix
  is included.
- The branch contains coordinated submodule revisions and should be reviewed as
  an integration branch rather than as one isolated library update.
