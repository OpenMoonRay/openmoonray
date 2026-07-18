# Copyright 2026 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

list(APPEND CMAKE_MESSAGE_CONTEXT ProfilingTest)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(ProfileTest)
add_profile_tests()
