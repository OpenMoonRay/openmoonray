#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright Contributors to the MoonRay Project.

# Builds the configured preset for one CI variant. Expects CMAKE_PRESET to
# be set. Can also be run locally inside an aswf/ci-moonray container, after
# ci-configure.bash, to reproduce a CI build step.
set -ex

: "${CMAKE_PRESET:?CMAKE_PRESET must be set}"

cmake --build --preset "$CMAKE_PRESET" -- -j"$(nproc)"
ccache --show-stats || true
