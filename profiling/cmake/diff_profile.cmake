# Copyright 2026 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# =====================================================================================
# This script is executed during profiling CTest 'diff' stages via:
#
#   cmake -DEXEC_MODE=... -DIDIFF_TOOL=... -DIMAGE_FILENAME=... \
#         -DTEST_REL_PATH=... -P diff_profile.cmake
#
# It compares a rendered result image against the stored canonical using idiff.
# The WORKING_DIRECTORY of the test must be the directory that contains the
# result image (IMAGE_FILENAME is relative to WORKING_DIRECTORY).
# -------------------------------------------------------------------------------------

# Validate required definitions.
foreach(required_def
    EXEC_MODE        # scalar | vector | xpu | default
    IDIFF_TOOL       # full path to the OpenImageIO 'idiff' command
    IMAGE_FILENAME   # image filename relative to WORKING_DIRECTORY, e.g. scene.exr
    TEST_REL_PATH)   # scene parent path, e.g. bitterli/bedroom
    if(NOT DEFINED ${required_def})
        message(FATAL_ERROR "[ProfileDiff] ${required_def} is undefined")
    endif()
endforeach()

# Require PROFILE_CANONICAL_DIR at runtime (not a CMake cache var).
if(NOT DEFINED ENV{PROFILE_CANONICAL_DIR})
    message(FATAL_ERROR
        "[ProfileDiff] PROFILE_CANONICAL_DIR is not set.\n"
        "Run 'ctest -L profiling -L update' first to generate canonicals, then\n"
        "set PROFILE_CANONICAL_DIR to the directory containing them.")
endif()

set(canonicals_root "$ENV{PROFILE_CANONICAL_DIR}")
cmake_path(NORMAL_PATH canonicals_root)

if(NOT EXISTS "${canonicals_root}")
    message(FATAL_ERROR
        "[ProfileDiff] PROFILE_CANONICAL_DIR '${canonicals_root}' does not exist.")
endif()

set(canonical_image
    "${canonicals_root}/${TEST_REL_PATH}/${EXEC_MODE}/${IMAGE_FILENAME}")

if(NOT EXISTS "${canonical_image}")
    message(FATAL_ERROR
        "[ProfileDiff] Canonical not found: ${canonical_image}\n"
        "Run 'ctest -L profiling -L update' to generate it.")
endif()

if(NOT EXISTS "${IMAGE_FILENAME}")
    message(FATAL_ERROR
        "[ProfileDiff] Result image not found: ${IMAGE_FILENAME}\n"
        "Run 'ctest -L profiling -L render' first.")
endif()

message(STATUS "[ProfileDiff] Comparing:")
message(STATUS "  canonical: ${canonical_image}")
message(STATUS "  result:    ${IMAGE_FILENAME}  (relative to test working dir)")

execute_process(
    COMMAND "${IDIFF_TOOL}" -a -v -abs "${canonical_image}" "${IMAGE_FILENAME}"
    RESULT_VARIABLE idiff_result
)

if(NOT idiff_result EQUAL 0)
    message(FATAL_ERROR
        "[ProfileDiff] Images differ:\n"
        "  canonical: ${canonical_image}\n"
        "  result:    ${IMAGE_FILENAME}")
endif()
