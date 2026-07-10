# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# These ExternalProject targets can be used to download, build and
# install many of the Moonray dependencies.
# The targets are chained using dependencies so that they run
# serially.

cmake_minimum_required (VERSION 3.23.1)
project(openmoonray_third_party)

include(ExternalProject)
cmake_policy(SET CMP0135 NEW)

include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
  set(JOBS_ARG -j${N})
endif()

file(REAL_PATH ${CMAKE_SOURCE_DIR} rootSrcDir)
set(THIS_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# User configurable settings
set(InstallRoot ${rootSrcDir}/../../../../installs CACHE FILEPATH "Install root for dependencies")
set(PythonVer 3.11 CACHE STRING "Python version (n.m), e.g. 3.6")
set(PythonRoot /usr CACHE FILEPATH "Location of Python install")
if(DEFINED ENV{HOUDINI_INSTALL_DIR})
    set(_defaultHoudiniInstallDir "$ENV{HOUDINI_INSTALL_DIR}")
elseif(DEFINED ENV{HFS})
    file(REAL_PATH "$ENV{HFS}/../../../../.." _defaultHoudiniInstallDir)
else()
    set(_defaultHoudiniInstallDir "/Applications/Houdini/Houdini20.5.684")
endif()
set(HOUDINI_INSTALL_DIR "${_defaultHoudiniInstallDir}" CACHE PATH "Houdini install root")
set(HoudiniPythonRoot "${HOUDINI_INSTALL_DIR}/Frameworks/Python.framework/Versions/${PythonVer}")

ExternalProject_Add(Blosc
    GIT_REPOSITORY https://github.com/Blosc/c-blosc
    GIT_TAG 616f4b7 # 1.21.6 # macOS 26 Tahoe
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
)
set(CHAIN Blosc)

ExternalProject_Add(Boost
    URL https://sourceforge.net/projects/boost/files/boost/1.82.0/boost_1_82_0.tar.gz
    UPDATE_COMMAND ./bootstrap.sh --prefix=${InstallRoot}  --with-toolset=clang linkflags="-arch ${BOOST_ARCH}"
    CONFIGURE_COMMAND ""
    PATCH_COMMAND patch -p3 -N < ${THIS_DIR}/Boost.patch || true
    BUILD_COMMAND ./b2 install ${JOBS_ARG} --user-config=${THIS_DIR}/user-config.jam --with-python python=${PythonVer} variant=release link=shared threading=multi architecture=arm address-model=64 define=BOOST_UNORDERED_HAVE_PIECEWISE_CONSTRUCT=0
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    DEPENDS ${CHAIN}
)
set(CHAIN Boost)

ExternalProject_Add(JsonCpp
    GIT_REPOSITORY https://github.com/open-source-parsers/jsoncpp.git
    GIT_TAG 5defb4ed1a4293b8e2bf641e16b156fb9de498cc # 1.9.5
    INSTALL_DIR ${InstallRoot}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DJSONCPP_LIB_BUILD_SHARED:BOOL=ON
    DEPENDS ${CHAIN}
)
set(CHAIN JsonCpp)

ExternalProject_Add(Lua
    URL https://www.lua.org/ftp/lua-5.4.4.tar.gz
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make ${JOBS_ARG} generic MYCFLAGS=-fPIC MYLIBS=-ldl
    INSTALL_COMMAND cp src/lua src/luac ${InstallRoot}/bin
            COMMAND cp src/lua.h src/luaconf.h src/lualib.h src/lauxlib.h src/lua.hpp ${InstallRoot}/include
            COMMAND cp src/liblua.a ${InstallRoot}/lib
    DEPENDS ${CHAIN}
)
set(CHAIN Lua)

ExternalProject_Add(MicroHttpd
    URL https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.72.tar.gz
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure --prefix ${InstallRoot}
    BUILD_COMMAND make ${JOBS_ARG}
    DEPENDS ${CHAIN}
)
set(CHAIN MicroHttpd)

ExternalProject_Add(OpenSubdiv
    GIT_REPOSITORY https://github.com/PixarAnimationStudios/OpenSubdiv
    GIT_TAG 8ffa2b6566be10209529d7a0d1db02a0796b160c # v3_5_0
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DCMAKE_BUILD_TYPE=Release
        -DNO_PTEX=1 -DNO_OMP=1 -DNO_TBB=1 -DNO_CUDA=1 -DNO_GLFW_X11=1
        -DNO_OPENCL=1 -DNO_CLEW=1 -DNO_REGRESSION=1 -DNO_EXAMPLES=1 -DNO_TUTORIALS=1
    DEPENDS ${CHAIN}
)
set(CHAIN OpenSubdiv)

ExternalProject_Add(OpenEXR
    GIT_REPOSITORY https://github.com/AcademySoftwareFoundation/openexr
    GIT_TAG 8bc3741131db146ad08a5b83af9e6e48f0e94a03 # v2.5.7
    PATCH_COMMAND patch IlmBase/Half/CMakeLists.txt ${THIS_DIR}/../Imath_include_paths.patch
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DBoost_ROOT=${InstallRoot}
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DBUILD_SHARED_LIBS=OFF
    DEPENDS ${CHAIN}
)
set(CHAIN OpenEXR)

ExternalProject_Add(TBB
    URL https://github.com/oneapi-src/oneTBB/archive/2020_U3.tar.gz
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make ${JOBS_ARG} arch=arm64
    INSTALL_COMMAND bash -c "cp build/*_release/libtbb*.* ${InstallRoot}/lib"
            COMMAND bash -c "cp -r include/tbb ${InstallRoot}/include"
    DEPENDS ${CHAIN}
)
set(CHAIN TBB)

ExternalProject_Add(OpenVDB
    GIT_REPOSITORY https://github.com/AcademySoftwareFoundation/openvdb
    GIT_TAG ab935574cdb25c3df66b068fce2a3b0a74281c54 # v9.1.0
    PATCH_COMMAND patch -p1 -N < ${THIS_DIR}/OpenVDB.patch || true
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DBlosc_ROOT=${InstallRoot}
        -DBoost_ROOT=${InstallRoot}
        -DTBB_ROOT=${InstallRoot}
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
    DEPENDS ${CHAIN}
)
set(CHAIN OpenVDB)

ExternalProject_Add(Log4CPlus
    URL https://github.com/log4cplus/log4cplus/releases/download/REL_2_0_5/log4cplus-2.0.5.tar.xz
    PATCH_COMMAND patch -p1 -N < ${THIS_DIR}/log4plus-limit-threads.patch || true
            COMMAND find . -name "Makefile.in" -exec touch {} +
            COMMAND touch aclocal.m4 configure config.h.in
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure --prefix ${InstallRoot}
    BUILD_COMMAND make
    INSTALL_COMMAND make install
    DEPENDS ${CHAIN}
)
set(CHAIN Log4CPlus)

ExternalProject_Add(CppUnit
    URL http://dev-www.libreoffice.org/src/cppunit-1.15.1.tar.gz
    BUILD_IN_SOURCE 1
    PATCH_COMMAND find . -name "Makefile.in" -exec touch {} + # prevent make from thinking these files are stale
    CONFIGURE_COMMAND ./configure --prefix ${InstallRoot}
    BUILD_COMMAND make ${JOBS_ARG}
    INSTALL_COMMAND make install
    DEPENDS ${CHAIN}
)
set(CHAIN CppUnit)

ExternalProject_Add(Random123
    GIT_REPOSITORY https://github.com/DEShawResearch/random123
    GIT_TAG 726a093cd9a73f3ec3c8d7a70ff10ed8efec8d13 # v1.14.0
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make ${JOBS_ARG}
    INSTALL_COMMAND bash -c "cp -r include/Random123 ${InstallRoot}/include"
    DEPENDS ${CHAIN}
)
set(CHAIN Random123)

ExternalProject_Add(ISPC
    URL https://github.com/ispc/ispc/releases/download/v1.20.0/ispc-v1.20.0-macOS.arm64.tar.gz
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND cp bin/ispc ${InstallRoot}/bin
    DEPENDS ${CHAIN}
)
set(CHAIN ISPC)

ExternalProject_Add(embree
    GIT_REPOSITORY https://github.com/embree/embree
    GIT_TAG 341ef8c45d1ae072ead1ab65cd76e88b03d9302c # v4.2.0
    PATCH_COMMAND patch -p1 -N < ${THIS_DIR}/Embree.patch || true
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DEMBREE_ISPC_EXECUTABLE=${InstallRoot}/bin/ispc
        -DEMBREE_ISPC_SUPPORT=ON
        -DEMBREE_TBB_ROOT=${InstallRoot}
        -DEMBREE_IGNORE_INVALID_RAYS=ON
        -DEMBREE_RAY_MASK=ON
        -DEMBREE_MAX_ISA=NEON
        -DEMBREE_ISA_NEON=ON
        -DEMBREE_TUTORIALS=OFF
        -DBUILD_SHARED_LIBS=ON
    DEPENDS ${CHAIN}
)
set(CHAIN embree)

ExternalProject_Add(OpenColorIO
    GIT_REPOSITORY https://github.com/AcademySoftwareFoundation/OpenColorIO
    GIT_TAG b35fb73b8674176098d3084deaa9da3d111d72d1 # v2.3.0
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -Dyaml-cpp_ROOT=${InstallRoot}
        -DOCIO_BUILD_APPS=OFF
        -DOCIO_BUILD_TESTS=OFF
        -DOCIO_BUILD_GPU_TESTS=OFF
        -DOCIO_USE_SSE=OFF
        -DOCIO_BUILD_PYTHON=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DBUILD_SHARED_LIBS=ON
        -DOCIO_BUILD_STATIC=OFF
        -DCMAKE_CXX_STANDARD=17
    DEPENDS ${CHAIN}
)
set(CHAIN OpenColorIO)

ExternalProject_Add(TIFF
    URL https://gitlab.com/libtiff/libtiff/-/archive/v4.0.7/libtiff-v4.0.7.tar.gz
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -Dld-version-script=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
    DEPENDS ${CHAIN}
)
set(CHAIN TIFF)

ExternalProject_Add(JPEGTurbo
    GIT_REPOSITORY https://github.com/libjpeg-turbo/libjpeg-turbo
    GIT_TAG bb3d325624526c91646bb9af9578d7198c082d51 # 2.0.1
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DWITH_SIMD=FALSE
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
    DEPENDS ${CHAIN}
)
set(CHAIN JPEGTurbo)

ExternalProject_Add(pybind11
    GIT_REPOSITORY https://github.com/pybind/pybind11
    GIT_TAG a2e59f0e7065404b44dfe92a28aca47ba1378dc4 # v2.13.6
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DPYBIND11_TEST=NO
    DEPENDS ${CHAIN}
)
set(CHAIN pybind11)

ExternalProject_Add(OpenImageIO
    GIT_REPOSITORY https://github.com/OpenImageIO/oiio
    GIT_TAG 331a323468928c8017ad048b26d47c4e57a724a7 # 2.3.20.0
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DBoost_ROOT=${InstallRoot}
        -DIMath_ROOT=${InstallRoot}
        -DDISABLE_CMAKE_SEARCH_PATHS=TRUE
        -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=TRUE
        -DOpenEXR_ROOT=${InstallRoot}
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DUSE_QT=0
        -DUSE_PYTHON=1
    DEPENDS ${CHAIN}
)
set(CHAIN OpenImageIO)

ExternalProject_Add(OpenImageDenoise
   URL https://github.com/OpenImageDenoise/oidn/releases/download/v2.2.0/oidn-2.2.0.arm64.macos.tar.gz
   BUILD_COMMAND ""
   CONFIGURE_COMMAND ""
   INSTALL_COMMAND bash -c "rm -f ../OpenImageDenoise/lib/libtbb.dylib"
           COMMAND bash -c "ditto ../OpenImageDenoise ${InstallRoot}"
   DEPENDS ${CHAIN}
)
set(CHAIN OpenImageDenoise)

ExternalProject_Add(qt5
    GIT_REPOSITORY https://code.qt.io/qt/qt5.git
    GIT_SUBMODULES_RECURSE false
    GIT_SHALLOW true
    GIT_TAG 5bd237e89469a032ac9d4d33fcd3896897d6d245 # 5.12.12
    GIT_SUBMODULES qtbase qtscript
    PATCH_COMMAND patch -Ni ${THIS_DIR}/Qt5.patch || true
    CONFIGURE_COMMAND ./configure -prefix ${InstallRoot} -confirm-license -opensource -no-egl -nomake examples -nomake tests QMAKE_APPLE_DEVICE_ARCHS=arm64 
    BUILD_COMMAND make ${JOBS_ARG}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make install
    DEPENDS ${CHAIN}
)
set(CHAIN qt5)

if(NOT NO_USD)
    ExternalProject_Add(USD
        GIT_REPOSITORY https://github.com/PixarAnimationStudios/USD
        GIT_TAG 0c7b9a95f155c221ff7df9270a39a52e3b23af8b # v22.11
        PATCH_COMMAND pwd && patch -Ni ${THIS_DIR}/USD.patch || true
        BUILD_COMMAND make ${JOBS_ARG}
        CMAKE_ARGS
            -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
            -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
            -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
            -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
            -DPXR_ENABLE_PYTHON_SUPPORT=ON
            -DPXR_USE_PYTHON_3=ON
            -DPXR_USE_DEBUG_PYTHON=OFF
            -DPYTHON_EXECUTABLE=${HoudiniPythonRoot}/bin/python${PythonVer}
            -DPYTHON_LIBRARY=${HoudiniPythonRoot}/lib/libpython${PythonVer}.dylib
            -DPYTHON_INCLUDE_DIR=${HoudiniPythonRoot}/include/python${PythonVer}
            -DPYTHON_VERSION_MAJOR=3
            -DPYTHON_VERSION_MINOR=11
            -DTBB_USE_DEBUG_BUILD=OFF
            -DPXR_BUILD_TESTS=OFF
            -DPXR_BUILD_EXAMPLES=OFF
            -DPXR_BUILD_TUTORIALS=OFF
            -DPXR_BUILD_USD_TOOLS=OFF
            -DPXR_ENABLE_PTEX_SUPPORT=OFF
            -DPXR_ENABLE_OPENVDB_SUPPORT=OFF
            -DPXR_BUILD_USDVIEW=OFF
            -DBoost_NO_BOOST_CMAKE=ON
            -DBoost_NO_SYSTEM_PATHS=ON
            -DCMAKE_MACOSX_RPATH=ON
        DEPENDS ${CHAIN}
    )
    set(CHAIN USD)
endif()

ExternalProject_Add(libuuid
    URL https://sourceforge.net/projects/libuuid/files/libuuid-1.0.3.tar.gz/download
    CONFIGURE_COMMAND ./configure --prefix=${InstallRoot}
    BUILD_COMMAND make ${JOBS_ARG}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make install
            COMMAND rm -rf ${InstallRoot}/include/_uuid
            COMMAND mv ${InstallRoot}/include/uuid ${InstallRoot}/include/_uuid
            COMMAND ln -sf ${InstallRoot}/include/_uuid/uuid.h ${InstallRoot}/include/uuid.h
    DEPENDS ${CHAIN}
)
set(CHAIN libuuid)

ExternalProject_Add(OpenSSL
    GIT_REPOSITORY https://github.com/openssl/openssl.git
    # GIT_TAG a92271e03a8d0dee507b6f1e7f49512568b2c7ad # 3.1.0 - contains a bug on Apple Silicon
    GIT_TAG 31157bc0b46e04227b8468d3e6915e4d0332777c # 3.0.8
    CONFIGURE_COMMAND ./Configure darwin64-arm64 --prefix=${InstallRoot} --openssldir=${InstallRoot} -rpath ${InstallRoot}/lib
    BUILD_IN_SOURCE 1
    BUILD_COMMAND make ${JOBS_ARG}
    DEPENDS ${CHAIN}
)
set(CHAIN OpenSSL)


ExternalProject_Add(libcurl
    URL https://curl.se/download/curl-7.88.1.tar.gz
    CONFIGURE_COMMAND ./configure --prefix=${InstallRoot} --with-secure-transport
    BUILD_COMMAND make ${JOBS_ARG}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make install
            COMMAND ln -sf ${InstallRoot}/lib/libcurl.4.dylib ${InstallRoot}/lib/libcurl.so.4 # This should be replaced with an additional NAME in FindLibcurl.cmake
    DEPENDS ${CHAIN}
)
set(CHAIN libcurl)

ExternalProject_Add(FreeType
    URL https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -D FT_REQUIRE_ZLIB=FALSE
        -D FT_REQUIRE_BZIP2=FALSE
        -D BUILD_SHARED_LIBS=true
    DEPENDS ${CHAIN}
)
set(CHAIN FreeType)

ExternalProject_Add(GLFW
    GIT_REPOSITORY https://github.com/glfw/glfw
    GIT_TAG 3.4
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
        -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
        -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
        -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
        -DGLFW_INSTALL=ON
        -DBUILD_SHARED_LIBS=ON
    DEPENDS ${CHAIN}
)
set(CHAIN GLFW)
