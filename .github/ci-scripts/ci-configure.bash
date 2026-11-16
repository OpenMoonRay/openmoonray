#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the MoonRay Project.

# Configures the build for one CI variant. Expects CMAKE_PRESET to be set
# (the cmake preset name from CMakeCIPresets.json). Can also be run locally
# inside an aswf/ci-moonray container to reproduce a CI configure step.
set -ex

: "${CMAKE_PRESET:?CMAKE_PRESET must be set}"

# Unity builds (CMAKE_UNITY_BUILD=ON) were tried here to speed up CI, but
# reverted: this codebase has multiple anonymous-namespace symbols with
# colliding names across .cc files in the same target (e.g. USER_AGENT in
# arras4_core/arras4_client/lib/sdk), which unity builds merge into one
# translation unit and fail to compile. Fixing those name collisions would
# be real source-code surgery, not a CI config change.

cmake --preset "$CMAKE_PRESET" \
      -DCMAKE_C_COMPILER_LAUNCHER=ccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
      -DBUILD_MATERIALX_SHADERS=ON
