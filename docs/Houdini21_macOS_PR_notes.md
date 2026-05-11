# PR Notes: Houdini 21 macOS Compatibility

## Reviewer Summary
Adds macOS/Houdini 21 compatibility updates required to build and install OpenMoonRay against Houdini 21 using Houdini-provided USD/PXR and Python 3.11. This includes Boost 1.82 alignment, dependency fetch/build fixes, Houdini USD library naming compatibility, and source-driven Houdini plugin payload installation. This branch validates build/install/selectability in Solaris, but does not resolve native DWA material authoring/render behavior in Houdini 21.

## Scope
- Build/dependency/install compatibility for Houdini 21 on macOS.
- No intended look/scene/rendering behavior change claim.
- No claim that native DWA Solaris authoring is fixed.

## Validated vs Not Resolved
| Area | Status | Notes |
|---|---|---|
| Dependency build | Validated | Build path completes with current compatibility adjustments. |
| Main configure/build | Validated | Houdini-target integration build path succeeds. |
| Install | Validated | Install path completes and plugin payload is install-driven. |
| Solaris renderer selectability | Validated | MoonRay selectable in Solaris viewport. |
| Native DWA material influence in Material Library / mtlx subnet | Not resolved | Native DWA nodes do not reliably drive visible render changes in simple test. |
| Light live-update behavior (`spread` example) | Not resolved | Manual IPR update required in observed tests. |
| Dome light with texture | Not resolved | Not working in current tested branch state. |

## Temporary Dependency Note
This branch may temporarily depend on a `moonray_dcc_plugins` fork/branch for Houdini 21 Python 3.11 payload alignment.
Current local kickoff pointer:
- branch: `houdini21-py311-kickoff`
- base commit: `eda4e57` (before additional fork commits)

Current intent for that fork is minimal:
- install-driven `python3.11libs` payload support
- required Houdini plugin payload continuity (`otls`, `soho`, `toolbar`, integration files)
- no broad OTL/authoring semantic rewrite

This fork kickoff is not fully stable as a native DWA workflow fix. Native DWA material behavior remains unresolved.

## Runtime Observation Captured During Simple DWA Test
- `{dispatcherExit} Message Dispatcher [libcomputation_progmcrt.dylib] : exiting : reason is 'socket was disconnected'`
- `{clientSocketError} SocketPeer::receive: Bad file descriptor`
- `signal ... 15`

## Reviewer Guidance
- Evaluate this PR primarily as compatibility/build/install integration work.
- Treat native DWA Solaris authoring/runtime issues as follow-up work outside this PR closure.
