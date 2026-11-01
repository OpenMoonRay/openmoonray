# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

add_subdirectory(hdMoonray)
option(BUILD_MOONRAY_SDR_PLUGINS "Build the legacy MoonRay SDR plugins" ON)
if(BUILD_MOONRAY_SDR_PLUGINS)
    add_subdirectory(moonray_sdr_plugins)
endif()
