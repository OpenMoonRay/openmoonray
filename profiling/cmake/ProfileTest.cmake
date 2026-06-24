# Copyright 2026 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# ----------------------------------------------------------------------------
# PROFILE_SCENES_DIR
#
# Path to a directory of profiling scenes (e.g. a local clone of
# dwanim/example-scenes).  When not set, no profile tests are registered.
# May also be supplied via the PROFILE_SCENES_DIR environment variable at
# cmake-configure time; the cmake cache variable takes precedence.
# ----------------------------------------------------------------------------
set(PROFILE_SCENES_DIR "" CACHE PATH
    "Path to a directory of profiling scenes (e.g. a clone of \
dwanim/example-scenes). When empty, no profile tests are added.")

if(NOT PROFILE_SCENES_DIR AND DEFINED ENV{PROFILE_SCENES_DIR})
    set(PROFILE_SCENES_DIR "$ENV{PROFILE_SCENES_DIR}" CACHE PATH
        "Path to a directory of profiling scenes." FORCE)
endif()

# ----------------------------------------------------------------------------
# PROFILE_OUTPUT_DIR
#
# Directory where rendered images and logs are written.  Defaults to
# <build-dir>/profiling/profile when empty.
# May also be supplied via the PROFILE_OUTPUT_DIR environment variable at
# cmake-configure time; the cmake cache variable takes precedence.
# ----------------------------------------------------------------------------
set(PROFILE_OUTPUT_DIR "" CACHE PATH
    "Directory for profile render output (images and logs). \
Defaults to <build-dir>/profiling/profile when empty.")

if(NOT PROFILE_OUTPUT_DIR AND DEFINED ENV{PROFILE_OUTPUT_DIR})
    set(PROFILE_OUTPUT_DIR "$ENV{PROFILE_OUTPUT_DIR}" CACHE PATH
        "Directory for profile render output." FORCE)
endif()

# ----------------------------------------------------------------------------
# PROFILE_VERSION
#
# Optional version tag embedded in output filenames. May also be supplied via
# the PROFILE_VERSION environment variable. See profiling/README.md for details.
# ----------------------------------------------------------------------------
set(PROFILE_VERSION "" CACHE STRING
    "Version tag embedded in output filenames (e.g. 1). Omitted when empty.")

if(DEFINED ENV{PROFILE_VERSION})
    set(PROFILE_VERSION "$ENV{PROFILE_VERSION}" CACHE STRING
        "Version tag embedded in output filenames." FORCE)
endif()

# ----------------------------------------------------------------------------
# add_profile_tests()
#
# Scans PROFILE_SCENES_DIR recursively for scene files and registers the
# profiling CTests (labeled 'profiling'). This function is a no-op when
# PROFILE_SCENES_DIR is unset or empty. See profiling/README.md for the
# supported scene types, output layout, test labels, and naming conventions.
# ----------------------------------------------------------------------------
function(add_profile_tests)
    if(NOT PROFILE_SCENES_DIR)
        message(STATUS "PROFILE_SCENES_DIR is not set; skipping profile tests.")
        return()
    endif()

    if(NOT IS_DIRECTORY "${PROFILE_SCENES_DIR}")
        message(WARNING "PROFILE_SCENES_DIR='${PROFILE_SCENES_DIR}' \
is not a valid directory; skipping profile tests.")
        return()
    endif()

    # Python and idiff are only required when profiling tests are actually being
    # registered (PROFILE_SCENES_DIR is set).  Placing the calls here avoids
    # making them hard configure-time dependencies for every build.
    find_package(Python REQUIRED COMPONENTS Interpreter)
    find_program(IDIFF idiff QUIET)

    cmake_path(NATIVE_PATH PROFILE_SCENES_DIR NORMALIZE scenes_dir)

    if(PROFILE_OUTPUT_DIR)
        set(output_dir "${PROFILE_OUTPUT_DIR}")
    else()
        set(output_dir "${CMAKE_CURRENT_BINARY_DIR}/profile")
    endif()
    file(MAKE_DIRECTORY "${output_dir}")

    # profile_render.py is the profiling-specific wrapper that captures the
    # renderer's output to a log file alongside the rendered image.
    set(_render_script "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/profile_render.py")
    set(_update_script "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/update_profile_canonical.py")

    set(_total 0)

    # Compute a CTest name following the same convention as RaTS:
    #   render-<mode>-<parent-dir-of-scene>
    # e.g.  bitterli/bedroom/scene.rdla  ->  render-sca-bitterli/bedroom
    # The 'profiling' label (not the name) is what distinguishes these from
    # RaTS tests when filtering with ctest -L.
    macro(_profile_test_name mode rel_path out_var)
        cmake_path(GET rel_path PARENT_PATH _ptn_parent)
        set(${out_var} "render-${mode}-${_ptn_parent}")
    endmacro()

    # Guard against two scenes that map to the same sanitized test name.
    macro(_profile_check_unique tname)
        if(TEST "${tname}")
            message(FATAL_ERROR "Duplicate test name '${tname}'. \
Two scenes in PROFILE_SCENES_DIR produce the same sanitized test name.")
        endif()
    endmacro()

    # --- moonray (.rdla) scenes -------------------------------------------
    file(GLOB_RECURSE _rdla_scenes CONFIGURE_DEPENDS "${scenes_dir}/*.rdla")
    foreach(scene_path ${_rdla_scenes})
        cmake_path(RELATIVE_PATH scene_path
            BASE_DIRECTORY "${scenes_dir}"
            OUTPUT_VARIABLE rel_path)

        cmake_path(GET scene_path PARENT_PATH scene_dir)

        # Build the list of -in args: the .rdla file first, then any .rdlb
        # files in the same directory (sorted for a deterministic order).
        # Moonray scenes commonly split across multiple files, e.g.
        #   scene.rdla  +  scene.rdlb
        set(_in_args -in "${scene_path}")
        file(GLOB _rdlb_files CONFIGURE_DEPENDS "${scene_dir}/*.rdlb")
        list(SORT _rdlb_files)
        foreach(_rdlb ${_rdlb_files})
            list(APPEND _in_args -in "${_rdlb}")
        endforeach()

        # Output subdir = the scene's parent directory relative to scenes_dir.
        # The scene stem is passed separately and incorporated into the filename
        # so that multiple scenes in the same directory remain distinct.
        cmake_path(GET rel_path PARENT_PATH _scene_parent_subpath)
        cmake_path(GET rel_path STEM _scene_stem)
        if(_scene_parent_subpath)
            set(_test_output_dir "${output_dir}/${_scene_parent_subpath}")
        else()
            set(_test_output_dir "${output_dir}")
        endif()

        # Register one test per execution mode.
        # Abbreviations match the RaTS convention: sca / vec / xpu.
        foreach(_exec_mode IN ITEMS scalar vector xpu)
            if(_exec_mode STREQUAL "scalar")
                set(_abbrev "sca")
            elseif(_exec_mode STREQUAL "vector")
                set(_abbrev "vec")
            else()
                set(_abbrev "${_exec_mode}")  # xpu
            endif()
            _profile_test_name("${_abbrev}" "${rel_path}" tname)
            _profile_check_unique("${tname}")

            # Per-mode render dir: holds the fixed-name result image that the
            # diff stage compares against the canonical.
            set(_render_dir
                "${CMAKE_CURRENT_BINARY_DIR}/render/${_scene_parent_subpath}/${_exec_mode}")
            file(MAKE_DIRECTORY "${_render_dir}")
            set(_result_image "${_render_dir}/${_scene_stem}.exr")
            set(_result_image_args --result-image "${_result_image}")

            add_test(NAME "${tname}"
                COMMAND ${Python_EXECUTABLE} "${_render_script}"
                        --output-dir "${_test_output_dir}"
                        --scene-name "${_scene_stem}"
                        --mode "${_abbrev}"
                        --version-tag "${PROFILE_VERSION}"
                        ${_result_image_args}
                        moonray
                        ${_in_args}
                        -exec_mode ${_exec_mode}
                        -info
                WORKING_DIRECTORY "${scene_dir}"
            )
            set_tests_properties("${tname}" PROPERTIES
                LABELS      "profiling;render;moonray;${_abbrev}"
                TIMEOUT     3600
                ENVIRONMENT "PYTHONPATH=$ENV{PYTHONPATH}:$ENV{OIIO_PYTHON}"
            )

            # The update (canonical generation) and diff (image comparison)
            # stages both require idiff, so register them together.
            if(IDIFF)
                # update test: render once and save as the canonical image.
                set(_update_tname "update-${_abbrev}-${_scene_parent_subpath}")
                _profile_check_unique("${_update_tname}")
                add_test(NAME "${_update_tname}"
                    COMMAND ${Python_EXECUTABLE} "${_update_script}"
                            --exec-mode "${_exec_mode}"
                            --test-rel-path "${_scene_parent_subpath}"
                            --image-name "${_scene_stem}.exr"
                            moonray
                            ${_in_args}
                            -exec_mode ${_exec_mode}
                            -info
                    WORKING_DIRECTORY "${scene_dir}"
                )
                set_tests_properties("${_update_tname}" PROPERTIES
                    LABELS      "profiling;update;moonray;${_abbrev}"
                    TIMEOUT     3600
                    ENVIRONMENT "PYTHONPATH=$ENV{PYTHONPATH}:$ENV{OIIO_PYTHON}"
                )

                # diff test: compare result against canonical.
                set(_diff_tname "diff-${_abbrev}-${_scene_parent_subpath}-${_scene_stem}.exr")
                _profile_check_unique("${_diff_tname}")
                add_test(NAME "${_diff_tname}"
                    WORKING_DIRECTORY "${_render_dir}"
                    COMMAND ${CMAKE_COMMAND}
                            "-DEXEC_MODE=${_exec_mode}"
                            "-DIDIFF_TOOL=${IDIFF}"
                            "-DIMAGE_FILENAME=${_scene_stem}.exr"
                            "-DTEST_REL_PATH=${_scene_parent_subpath}"
                            -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/diff_profile.cmake"
                )
                set_tests_properties("${_diff_tname}" PROPERTIES
                    LABELS      "profiling;diff;moonray;${_abbrev}"
                    DEPENDS     "${tname}"
                    TIMEOUT     300
                    ENVIRONMENT "PYTHONPATH=$ENV{PYTHONPATH}:$ENV{OIIO_PYTHON}"
                )
            endif()

            math(EXPR _total "${_total} + 1")
        endforeach()
    endforeach()

    # --- hd_render (.usd / .usdc / .usda) scenes --------------------------
    file(GLOB_RECURSE _usd_scenes CONFIGURE_DEPENDS
        "${scenes_dir}/*.usd"
        "${scenes_dir}/*.usdc"
        "${scenes_dir}/*.usda"
    )
    foreach(scene_path ${_usd_scenes})
        cmake_path(RELATIVE_PATH scene_path
            BASE_DIRECTORY "${scenes_dir}"
            OUTPUT_VARIABLE rel_path)
        _profile_test_name("hd" "${rel_path}" tname)
        _profile_check_unique("${tname}")

        cmake_path(GET scene_path PARENT_PATH scene_dir)

        cmake_path(GET rel_path PARENT_PATH _scene_parent_subpath)
        cmake_path(GET rel_path STEM _scene_stem)
        if(_scene_parent_subpath)
            set(_test_output_dir "${output_dir}/${_scene_parent_subpath}")
        else()
            set(_test_output_dir "${output_dir}")
        endif()

        # Per-mode render dir: holds the fixed-name result image that the
        # diff stage compares against the canonical.
        set(_render_dir
            "${CMAKE_CURRENT_BINARY_DIR}/render/${_scene_parent_subpath}/default")
        file(MAKE_DIRECTORY "${_render_dir}")
        set(_result_image "${_render_dir}/${_scene_stem}.exr")
        set(_result_image_args --result-image "${_result_image}")

        add_test(NAME "${tname}"
            COMMAND ${Python_EXECUTABLE} "${_render_script}"
                    --output-dir "${_test_output_dir}"
                    --scene-name "${_scene_stem}"
                    --mode "hd"
                    --version-tag "${PROFILE_VERSION}"
                    ${_result_image_args}
                    hd_render
                    -in "${scene_path}"
            WORKING_DIRECTORY "${scene_dir}"
        )
        set_tests_properties("${tname}" PROPERTIES
            LABELS      "profiling;render;hd_render"
            TIMEOUT     3600
            ENVIRONMENT "PYTHONPATH=$ENV{PYTHONPATH}:$ENV{OIIO_PYTHON}"
        )

        # The update (canonical generation) and diff (image comparison)
        # stages both require idiff, so register them together.
        if(IDIFF)
            # update test: render once and save as the canonical image.
            set(_update_tname "update-hd-${_scene_parent_subpath}")
            _profile_check_unique("${_update_tname}")
            add_test(NAME "${_update_tname}"
                COMMAND ${Python_EXECUTABLE} "${_update_script}"
                        --exec-mode "default"
                        --test-rel-path "${_scene_parent_subpath}"
                        --image-name "${_scene_stem}.exr"
                        hd_render
                        -in "${scene_path}"
                WORKING_DIRECTORY "${scene_dir}"
            )
            set_tests_properties("${_update_tname}" PROPERTIES
                LABELS      "profiling;update;hd_render"
                TIMEOUT     3600
                ENVIRONMENT "PYTHONPATH=$ENV{PYTHONPATH}:$ENV{OIIO_PYTHON}"
            )

            # diff test: compare result against canonical.
            set(_diff_tname "diff-hd-${_scene_parent_subpath}-${_scene_stem}.exr")
            _profile_check_unique("${_diff_tname}")
            add_test(NAME "${_diff_tname}"
                WORKING_DIRECTORY "${_render_dir}"
                COMMAND ${CMAKE_COMMAND}
                        "-DEXEC_MODE=default"
                        "-DIDIFF_TOOL=${IDIFF}"
                        "-DIMAGE_FILENAME=${_scene_stem}.exr"
                        "-DTEST_REL_PATH=${_scene_parent_subpath}"
                        -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/diff_profile.cmake"
            )
            set_tests_properties("${_diff_tname}" PROPERTIES
                LABELS      "profiling;diff;hd_render"
                DEPENDS     "${tname}"
                TIMEOUT     300
                ENVIRONMENT "PYTHONPATH=$ENV{PYTHONPATH}:$ENV{OIIO_PYTHON}"
            )
        endif()

        math(EXPR _total "${_total} + 1")
    endforeach()

    if(_total EQUAL 0)
        message(FATAL_ERROR "No scene files (.rdla, .usd, .usdc, .usda) \
found in '${PROFILE_SCENES_DIR}'. Ensure the scenes repository was cloned correctly \
and PROFILE_SCENES_DIR points to the right directory.")
    endif()
    message(STATUS "Registered ${_total} profile test(s) from: ${PROFILE_SCENES_DIR}")
endfunction()
