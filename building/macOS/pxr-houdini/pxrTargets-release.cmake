#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Modified to use the version of USD with headers in $env{PXR_INCLUDE_PREFIX}
# and libs in $env{PXR_LIB_PREFIX}, with dependencies installed to $env{PXR_DEPS_PREFIX}

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "arch" for configuration "Release"
set_property(TARGET arch APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(arch PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_arch.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_arch.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS arch )
list(APPEND _IMPORT_CHECK_FILES_FOR_arch "${_LIB_PREFIX}/libpxr_arch.dylib" )

# Import target "tf" for configuration "Release"
set_property(TARGET tf APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(tf PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_tf.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_tf.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS tf )
list(APPEND _IMPORT_CHECK_FILES_FOR_tf "${_LIB_PREFIX}/libpxr_tf.dylib" )

# Import target "gf" for configuration "Release"
set_property(TARGET gf APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(gf PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_gf.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_gf.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS gf )
list(APPEND _IMPORT_CHECK_FILES_FOR_gf "${_LIB_PREFIX}/libpxr_gf.dylib" )

# Import target "js" for configuration "Release"
set_property(TARGET js APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(js PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_js.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_js.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS js )
list(APPEND _IMPORT_CHECK_FILES_FOR_js "${_LIB_PREFIX}/libpxr_js.dylib" )

# Import target "trace" for configuration "Release"
set_property(TARGET trace APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(trace PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_trace.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_trace.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS trace )
list(APPEND _IMPORT_CHECK_FILES_FOR_trace "${_LIB_PREFIX}/libpxr_trace.dylib" )

# Import target "work" for configuration "Release"
set_property(TARGET work APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(work PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_work.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_work.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS work )
list(APPEND _IMPORT_CHECK_FILES_FOR_work "${_LIB_PREFIX}/libpxr_work.dylib" )

# Import target "plug" for configuration "Release"
set_property(TARGET plug APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(plug PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_plug.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_plug.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS plug )
list(APPEND _IMPORT_CHECK_FILES_FOR_plug "${_LIB_PREFIX}/libpxr_plug.dylib" )

# Import target "vt" for configuration "Release"
set_property(TARGET vt APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(vt PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_vt.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_vt.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS vt )
list(APPEND _IMPORT_CHECK_FILES_FOR_vt "${_LIB_PREFIX}/libpxr_vt.dylib" )

# Import target "ar" for configuration "Release"
set_property(TARGET ar APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(ar PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_ar.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_ar.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS ar )
list(APPEND _IMPORT_CHECK_FILES_FOR_ar "${_LIB_PREFIX}/libpxr_ar.dylib" )

# Import target "kind" for configuration "Release"
set_property(TARGET kind APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(kind PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_kind.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_kind.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS kind )
list(APPEND _IMPORT_CHECK_FILES_FOR_kind "${_LIB_PREFIX}/libpxr_kind.dylib" )

# Import target "sdf" for configuration "Release"
set_property(TARGET sdf APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(sdf PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_sdf.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_sdf.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS sdf )
list(APPEND _IMPORT_CHECK_FILES_FOR_sdf "${_LIB_PREFIX}/libpxr_sdf.dylib" )

# Import target "ndr" for configuration "Release"
set_property(TARGET ndr APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(ndr PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_ndr.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_ndr.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS ndr )
list(APPEND _IMPORT_CHECK_FILES_FOR_ndr "${_LIB_PREFIX}/libpxr_ndr.dylib" )

# Import target "sdr" for configuration "Release"
set_property(TARGET sdr APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(sdr PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_sdr.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_sdr.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS sdr )
list(APPEND _IMPORT_CHECK_FILES_FOR_sdr "${_LIB_PREFIX}/libpxr_sdr.dylib" )

# Import target "pcp" for configuration "Release"
set_property(TARGET pcp APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(pcp PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_pcp.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_pcp.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS pcp )
list(APPEND _IMPORT_CHECK_FILES_FOR_pcp "${_LIB_PREFIX}/libpxr_pcp.dylib" )

# Import target "usd" for configuration "Release"
set_property(TARGET usd APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usd PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usd.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usd.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usd )
list(APPEND _IMPORT_CHECK_FILES_FOR_usd "${_LIB_PREFIX}/libpxr_usd.dylib" )

# Import target "usdGeom" for configuration "Release"
set_property(TARGET usdGeom APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdGeom PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdGeom.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdGeom.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdGeom )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdGeom "${_LIB_PREFIX}/libpxr_usdGeom.dylib" )

# Import target "usdVol" for configuration "Release"
set_property(TARGET usdVol APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdVol PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdVol.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdVol.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdVol )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdVol "${_LIB_PREFIX}/libpxr_usdVol.dylib" )

# Import target "usdMedia" for configuration "Release"
set_property(TARGET usdMedia APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdMedia PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdMedia.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdMedia.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdMedia )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdMedia "${_LIB_PREFIX}/libpxr_usdMedia.dylib" )

# Import target "usdShade" for configuration "Release"
set_property(TARGET usdShade APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdShade PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdShade.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdShade.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdShade )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdShade "${_LIB_PREFIX}/libpxr_usdShade.dylib" )

# Import target "usdLux" for configuration "Release"
set_property(TARGET usdLux APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdLux PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdLux.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdLux.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdLux )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdLux "${_LIB_PREFIX}/libpxr_usdLux.dylib" )

# Import target "usdRender" for configuration "Release"
set_property(TARGET usdRender APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdRender PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdRender.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdRender.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdRender )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdRender "${_LIB_PREFIX}/libpxr_usdRender.dylib" )

# Import target "usdHydra" for configuration "Release"
set_property(TARGET usdHydra APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdHydra PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdHydra.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdHydra.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdHydra )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdHydra "${_LIB_PREFIX}/libpxr_usdHydra.dylib" )

# Import target "usdRi" for configuration "Release"
set_property(TARGET usdRi APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdRi PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdRi.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdRi.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdRi )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdRi "${_LIB_PREFIX}/libpxr_usdRi.dylib" )

# Import target "usdSkel" for configuration "Release"
set_property(TARGET usdSkel APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdSkel PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdSkel.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdSkel.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdSkel )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdSkel "${_LIB_PREFIX}/libpxr_usdSkel.dylib" )

# Import target "usdUI" for configuration "Release"
set_property(TARGET usdUI APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdUI PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdUI.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdUI.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdUI )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdUI "${_LIB_PREFIX}/libpxr_usdUI.dylib" )

# Import target "usdUtils" for configuration "Release"
set_property(TARGET usdUtils APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdUtils PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdUtils.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdUtils.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdUtils )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdUtils "${_LIB_PREFIX}/libpxr_usdUtils.dylib" )

# Import target "usdPhysics" for configuration "Release"
set_property(TARGET usdPhysics APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdPhysics PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdPhysics.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdPhysics.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdPhysics )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdPhysics "${_LIB_PREFIX}/libpxr_usdPhysics.dylib" )

# Import target "garch" for configuration "Release"
set_property(TARGET garch APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(garch PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_garch.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_garch.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS garch )
list(APPEND _IMPORT_CHECK_FILES_FOR_garch "${_LIB_PREFIX}/libpxr_garch.dylib" )

# Import target "hf" for configuration "Release"
set_property(TARGET hf APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hf PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hf.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hf.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hf )
list(APPEND _IMPORT_CHECK_FILES_FOR_hf "${_LIB_PREFIX}/libpxr_hf.dylib" )

# Import target "hio" for configuration "Release"
set_property(TARGET hio APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hio PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hio.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hio.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hio )
list(APPEND _IMPORT_CHECK_FILES_FOR_hio "${_LIB_PREFIX}/libpxr_hio.dylib" )

# Import target "cameraUtil" for configuration "Release"
set_property(TARGET cameraUtil APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(cameraUtil PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_cameraUtil.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_cameraUtil.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS cameraUtil )
list(APPEND _IMPORT_CHECK_FILES_FOR_cameraUtil "${_LIB_PREFIX}/libpxr_cameraUtil.dylib" )

# Import target "pxOsd" for configuration "Release"
set_property(TARGET pxOsd APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(pxOsd PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_pxOsd.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_pxOsd.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS pxOsd )
list(APPEND _IMPORT_CHECK_FILES_FOR_pxOsd "${_LIB_PREFIX}/libpxr_pxOsd.dylib" )

# Import target "glf" for configuration "Release"
set_property(TARGET glf APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(glf PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_glf.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_glf.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS glf )
list(APPEND _IMPORT_CHECK_FILES_FOR_glf "${_LIB_PREFIX}/libpxr_glf.dylib" )

# Import target "hgi" for configuration "Release"
set_property(TARGET hgi APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hgi PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hgi.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hgi.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hgi )
list(APPEND _IMPORT_CHECK_FILES_FOR_hgi "${_LIB_PREFIX}/libpxr_hgi.dylib" )

# Import target "hgiGL" for configuration "Release"
set_property(TARGET hgiGL APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hgiGL PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hgiGL.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hgiGL.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hgiGL )
list(APPEND _IMPORT_CHECK_FILES_FOR_hgiGL "${_LIB_PREFIX}/libpxr_hgiGL.dylib" )

# Import target "hgiInterop" for configuration "Release"
set_property(TARGET hgiInterop APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hgiInterop PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hgiInterop.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hgiInterop.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hgiInterop )
list(APPEND _IMPORT_CHECK_FILES_FOR_hgiInterop "${_LIB_PREFIX}/libpxr_hgiInterop.dylib" )

# Import target "hd" for configuration "Release"
set_property(TARGET hd APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hd PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hd.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hd.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hd )
list(APPEND _IMPORT_CHECK_FILES_FOR_hd "${_LIB_PREFIX}/libpxr_hd.dylib" )

# Import target "hdSt" for configuration "Release"
set_property(TARGET hdSt APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hdSt PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hdSt.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hdSt.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hdSt )
list(APPEND _IMPORT_CHECK_FILES_FOR_hdSt "${_LIB_PREFIX}/libpxr_hdSt.dylib" )

# Import target "hdx" for configuration "Release"
set_property(TARGET hdx APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hdx PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_hdx.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_hdx.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hdx )
list(APPEND _IMPORT_CHECK_FILES_FOR_hdx "${_LIB_PREFIX}/libpxr_hdx.dylib" )

# Import target "usdImaging" for configuration "Release"
set_property(TARGET usdImaging APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdImaging PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdImaging.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdImaging.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdImaging )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdImaging "${_LIB_PREFIX}/libpxr_usdImaging.dylib" )

# Import target "usdImagingGL" for configuration "Release"
set_property(TARGET usdImagingGL APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdImagingGL PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdImagingGL.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdImagingGL.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdImagingGL )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdImagingGL "${_LIB_PREFIX}/libpxr_usdImagingGL.dylib" )

# Import target "usdRiImaging" for configuration "Release"
set_property(TARGET usdRiImaging APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdRiImaging PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdRiPxrImaging.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdRiPxrImaging.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdRiImaging )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdRiImaging "${_LIB_PREFIX}/libpxr_usdRiPxrImaging.dylib" )

# Import target "usdSkelImaging" for configuration "Release"
set_property(TARGET usdSkelImaging APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdSkelImaging PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdSkelImaging.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdSkelImaging.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdSkelImaging )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdSkelImaging "${_LIB_PREFIX}/libpxr_usdSkelImaging.dylib" )

# Import target "usdVolImaging" for configuration "Release"
set_property(TARGET usdVolImaging APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdVolImaging PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdVolImaging.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdVolImaging.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdVolImaging )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdVolImaging "${_LIB_PREFIX}/libpxr_usdVolImaging.dylib" )

# Import target "usdAppUtils" for configuration "Release"
set_property(TARGET usdAppUtils APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdAppUtils PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdAppUtils.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdAppUtils.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdAppUtils )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdAppUtils "${_LIB_PREFIX}/libpxr_usdAppUtils.dylib" )

# Import target "usdviewq" for configuration "Release"
set_property(TARGET usdviewq APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(usdviewq PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_LIB_PREFIX}/libpxr_usdviewq.dylib"
  IMPORTED_SONAME_RELEASE "libpxr_usdviewq.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS usdviewq )
list(APPEND _IMPORT_CHECK_FILES_FOR_usdviewq "${_LIB_PREFIX}/libpxr_usdviewq.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
