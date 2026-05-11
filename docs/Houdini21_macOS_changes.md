# Houdini 21 macOS Compatibility Changes

## Summary
Adds macOS/Houdini 21 compatibility updates required to build and install OpenMoonRay against Houdini 21 using Houdini-provided USD/PXR and Python 3.11. This includes Boost 1.82 alignment, dependency fetch/build fixes, Houdini USD library naming compatibility, and source-driven Houdini plugin payload installation. This branch validates build/install/selectability in Solaris, but does not resolve native DWA material authoring/render behavior in Houdini 21.

Compatibility and integration improved in this branch. Native DWA authoring/runtime behavior in Solaris remains unresolved.

## Tested Environment
- macOS Tahoe
- Xcode 26.0.1 class toolchain flow
- Houdini 21 series validation target:
- `21.0.680` (original PR target)
- `21.0.671` (current local validation path)

## Build/Dependency Changes
- Boost dependency alignment moved to `1.82.0`.
- Boost patch command made tolerant of already-applied state (`patch ... || true`).
- `log4cplus` dependency fetch moved from git tag checkout to release tarball:
- `https://github.com/log4cplus/log4cplus/releases/download/REL_2_0_5/log4cplus-2.0.5.tar.xz`
- `log4cplus` reproducible build workaround added before configure:
- `touch Makefile.in`
- `touch aclocal.m4 configure config.h.in`

These are build reproducibility fixes, not renderer/material behavior fixes.

## Python 3.11 Alignment
- Houdini 21 Python 3.11 include/lib/executable alignment was applied for USD/PXR integration in this branch.
- `building/macOS/user-config.jam` was moved from Python 3.9 config to Python 3.11 config for this compatibility track.
- Current pathing is validated for local Houdini 21 installs and should be parameterized before upstream hardening.

## Houdini USD/PXR Pathing
- Houdini USD integration uses Houdini-provided PXR paths and library resolution.
- Compatibility mapping included:
- `libpxr_usdRiImaging.dylib` -> `libpxr_usdRiPxrImaging.dylib`
- PXR metadata compatibility updates for Houdini 21 USD packaging were applied in `pxr-houdini` CMake metadata.

## Install Payload Changes
Source-driven install path includes Houdini plugin payload required for this branch validation:
- `otls`
- `soho`
- `python3.11libs`
- `toolbar` (where present in plugin payload layout)
- integration files under Houdini plugin tree

Manual post-install copying is not the intended validation path for this branch.

## Validation Results
- Dependency build: pass
- Main configure/build: pass
- Install: pass
- MoonRay renderer selectable in Solaris viewport: pass

## DWA Material Test Status
Status: unresolved in current build.

Observed behavior in Solaris Material Library / mtlx subnet:
- Native DWA nodes are visible/creatable, but do not reliably drive visible render changes in the simple test.
- Control path through `mtlxstandard_surface` can influence render, but this is not a native DWA workflow fix.

Observed runtime/disconnect signal during simple DWA tests:
- `{dispatcherExit} Message Dispatcher [libcomputation_progmcrt.dylib] : exiting : reason is 'socket was disconnected'`
- `{clientSocketError} SocketPeer::receive: Bad file descriptor`
- `signal ... 15`

## Known Unresolved Issues
- Native DWA material authoring/render influence in Solaris remains unresolved for this branch.
- Some light parameter edits (for example `spread`) require manual IPR refresh and do not always live-update automatically.
- Dome light textured workflow is currently not working in this tested branch state.

## Notes For Reviewers
- This branch should be reviewed as a Houdini 21 macOS build/install compatibility update.
- Do not treat native DWA node visibility/selectability as evidence that native DWA material workflow is fixed.
- No claim is made that MaterialX/native DWA Solaris authoring is production-ready in this branch.

## Future Cleanup / Upstreaming Notes
- Parameterize local Houdini/Python paths before upstream merge hardening.
- Keep compatibility/build fixes separated from shader authoring/runtime behavior work.
- Track native DWA Solaris authoring/runtime closure as a follow-up effort.
