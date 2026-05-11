# OpenMoonRay Houdini 21.0.680 macOS Compatibility Notes

This document records the MoonRay macOS updates required for Houdini `21.0.680`.

## Scope

- Target platform: macOS
- Target DCC: Houdini `21.0.680`
- Goal: build MoonRay against Houdini-owned USD/PXR and Python 3.11

## Tested Environment

- macOS: Tahoe (SDK observed during build: `MacOSX26.4.sdk`)
- Xcode: `26.0.1` (`/Applications/Xcode_26.0.1.app`)
- Houdini validated in this branch: `21.0.680`

## Why These Changes Were Needed

Houdini 21 moved to Python 3.11 and ships USD/PXR libraries inside the Houdini framework layout. MoonRay must consume those paths directly for include/library resolution and avoid building a separate local USD for the Houdini build path.

## Required Compatibility Changes

### 1) [`CMakeMacOSPresets.json`](../CMakeMacOSPresets.json)

- `HOUDINI_INSTALL_DIR` set to:
  - `/Applications/Houdini/Houdini21.0.680`
- `PXR_LIB_PREFIX` set to:
  - `$env{HOUDINI_INSTALL_DIR}/Frameworks/Houdini.framework/Versions/Current/Libraries`
- `PXR_INCLUDE_PREFIX` set to:
  - `$env{HOUDINI_INSTALL_DIR}/Frameworks/Houdini.framework/Versions/Current/Resources/toolkit/include`
- `PXR_BOOST_PYTHON_LIB` set to:
  - `$env{HOUDINI_INSTALL_DIR}/Frameworks/Houdini.framework/Versions/Current/Libraries/libpxr_python.dylib`

Important: in this tested setup, using `libhboost_python311-mt-a64.dylib` did not resolve all expected `pxr_boost::python` references during link, while `libpxr_python.dylib` did.

### 2) [`scripts/macOS/setupHoudini.sh`](../scripts/macOS/setupHoudini.sh)

- `HOUDINI_PATH` updated to Houdini 21.0.680 framework resources path.

### 3) [`building/macOS/pxr-houdini/pxrTargets.cmake`](../building/macOS/pxr-houdini/pxrTargets.cmake)

- `HPYTHONLIB` updated to:
  - `$ENV{HOUDINI_INSTALL_DIR}/Frameworks/Python.framework/Versions/3.11/lib/libpython3.11.dylib`
- `HPYTHONINC` updated to:
  - `$ENV{HOUDINI_INSTALL_DIR}/Frameworks/Python.framework/Versions/3.11/include/python3.11`

### 4) [`building/macOS/pxr-houdini/pxrConfig.cmake`](../building/macOS/pxr-houdini/pxrConfig.cmake)

- PXR version metadata updated to:
  - `PXR_MAJOR_VERSION "0"`
  - `PXR_MINOR_VERSION "25"`
  - `PXR_PATCH_VERSION "5"`
  - `PXR_VERSION "2505"`

### 5) [`building/macOS/CMakeLists.txt`](../building/macOS/CMakeLists.txt)

- Boost source updated to `1.82.0` (`boost_1_82_0.tar.gz`) for Houdini 21 toolchain compatibility.

### 6) [`building/macOS/pxr-houdini/pxrTargets-release.cmake`](../building/macOS/pxr-houdini/pxrTargets-release.cmake)

- Houdini 21 library naming compatibility fix:
  - `libpxr_usdRiImaging.dylib` -> `libpxr_usdRiPxrImaging.dylib`

## Build Procedure Requirements (Houdini Path)

- Build dependencies with Houdini USD mode enabled (skip local USD):
  - `cmake -DNO_USD=1 ../building/macOS`
  - `cmake --build .`
- If dependencies were previously built without `-DNO_USD=1`, clean `build-deps/` and `installs/` before rebuilding to avoid mixed USD linkage.

## Environment-Specific Workarounds

- In this macOS/Xcode environment, full `cmake --build --preset macos-houdini-release` required disabling Xcode code-signing attributes at configure time to avoid dynamic-library signing failures.
- This is an environment workaround, not a Houdini 21 compatibility requirement.

## Validation Summary

- Dependency build completed successfully with `-DNO_USD=1`.
- Main project configure/build completed successfully for Houdini preset.
- Install completed successfully.
- Moonray appears as a selectable renderer in the Solaris viewport.
- Houdini Solaris workflow is the intended runtime verification path.
- `moonray_gui` command-line test requires an active GUI display session; headless runs fail with `Cannot create window: no screens available`.

## Houdini Sanity Reference

- SideFX changelog reference (used as a sanity baseline when evaluating Houdini compatibility context):
  - [SideFX changelog](https://www.sidefx.com/changelog/?categories=52&journal=17.5&show_versions=on)
- Note: this branch has not been tested against production Houdini `21.0.679`; validated test target remains Houdini `21.0.680`.
- Additional context: the Xcode compilation issue language in SideFX notes is generic; direct relevance to MoonRay-specific build/runtime behavior is currently uncertain.

## Out of Scope

- Any separate Houdini shader/HDA UX issues are not addressed by these changes.
- `cmake_modules` contains a local Boost macro adjustment: `cmake/MoonrayDso.cmake` updates `DWA_BOOST_VERSION` from `1073000` to `1082000`. This change is in the submodule working tree and is not part of the parent-repo commits in this branch.

## Cross-Repo Linkage

- Parent repo branch:
  - [`Moonray-Houdini21-macOS`](https://github.com/rolledhand/openmoonray/tree/Moonray-Houdini21-macOS)
- Submodule repo branch:
  - [`boost-1.82-macro-update`](https://github.com/rolledhand/cmake_modules/tree/boost-1.82-macro-update)
