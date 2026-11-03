# Copyright 2023-2025 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

add_subdirectory(hydra)
add_subdirectory(mcrt_denoise)
add_subdirectory(moonray)
add_subdirectory(moonray_arras)
add_subdirectory(moonray_dcc_plugins)
add_subdirectory(moonshine)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/moonshine_dwa)
    add_subdirectory(moonshine_dwa)
endif()
add_subdirectory(moonshine_usd)
add_subdirectory(render_profile_viewer)
# scene_rdl2 must be added before materialx_shaders: materialx_shaders'
# Python codegen step checks for scene_rdl2's build directory at configure
# time to locate its Python bindings, which requires scene_rdl2's
# add_subdirectory() to have already run.
add_subdirectory(scene_rdl2)
if (BUILD_MATERIALX_SHADERS)
    add_subdirectory(materialx_shaders)
endif()

if (${BUILD_QT_APPS})
    add_subdirectory(moonray_gui)
endif()
