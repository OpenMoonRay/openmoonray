# Houdini 22 macOS alignment notes

This document records the changes and validation performed on the
`test/houdini22-clean-build` branch. The work started from
`OpenMoonRay/openmoonray` `main` at `b9b0ac2` and targets Houdini 22.0.408 on
Apple Silicon.

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
