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

# Allow the pinned (older) dependencies to configure under CMake 4.x, which
# rejects cmake_minimum_required < 3.5 and hides legacy find modules
# (FindBoost, FindPythonInterp/Libs) behind policies. Passed to every
# CMake-based ExternalProject below; empty (no-op) under CMake 3.x.
# Note: a set(ENV{...}) here would NOT work — ExternalProject configure steps
# run at build time in separate processes.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
    set(POLICY_MIN -DCMAKE_POLICY_VERSION_MINIMUM=3.5)
    # For deps that run NESTED ExternalProjects at build time (OpenColorIO
    # builds its own yaml-cpp/pystring), the cache arg above cannot reach the
    # inner configure; CMake >= 4 also honors this as an environment variable.
    set(POLICY_MIN_ENV CMAKE_POLICY_VERSION_MINIMUM=3.5)
endif()

include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
  set(JOBS_ARG -j${N})
endif()

file(REAL_PATH ${CMAKE_SOURCE_DIR} rootSrcDir)
set(THIS_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# User configurable settings
set(InstallRoot ${rootSrcDir}/../../../../installs CACHE FILEPATH "Install root for dependencies")
set(PythonVer 3.9.6 CACHE STRING "Python version (n.m), e.g. 3.6")
set(PythonRoot /usr CACHE FILEPATH "Location of Python install")

# Arguments shared by every CMake-based dependency: policy floor for CMake 4,
# find dependencies only in ${InstallRoot}, never in homebrew, and install
# into ${InstallRoot}.
set(COMMON_CMAKE_ARGS
    ${POLICY_MIN}
    -DCMAKE_PREFIX_PATH:PATH=${InstallRoot}
    -DCMAKE_IGNORE_PATH:PATH=/opt/homebrew
    -DCMAKE_IGNORE_PREFIX_PATH:PATH=/opt/homebrew
    -DCMAKE_INSTALL_PREFIX:PATH=${InstallRoot}
)

ExternalProject_Add(Blosc
    GIT_REPOSITORY https://github.com/Blosc/c-blosc
    GIT_TAG 616f4b7 # 1.21.6 # macOS 26 Tahoe
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
)
set(CHAIN Blosc)

ExternalProject_Add(Boost
    URL https://archives.boost.io/release/1.78.0/source/boost_1_78_0.tar.gz
        https://downloads.sourceforge.net/project/boost/boost/1.78.0/boost_1_78_0.tar.gz
    URL_HASH SHA256=94ced8b72956591c4775ae2207a9763d3600b30d9d7446562c552f0a14a63be7
    UPDATE_COMMAND ./bootstrap.sh --prefix=${InstallRoot} --with-libraries=python,filesystem,system,thread,regex,date_time,chrono,program_options,iostreams --with-toolset=clang linkflags="-arch ${BOOST_ARCH}"
    CONFIGURE_COMMAND ""
    PATCH_COMMAND patch -p3 -N < ${THIS_DIR}/Boost.patch || true
    BUILD_COMMAND ./b2 install ${JOBS_ARG} --user-config=${THIS_DIR}/user-config.jam variant=release link=shared threading=multi define=BOOST_UNORDERED_HAVE_PIECEWISE_CONSTRUCT=0
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    DEPENDS ${CHAIN}
)
set(CHAIN Boost)

ExternalProject_Add(JsonCpp
    GIT_REPOSITORY https://github.com/open-source-parsers/jsoncpp.git
    GIT_TAG 5defb4ed1a4293b8e2bf641e16b156fb9de498cc # 1.9.5
    CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
        -DJSONCPP_LIB_BUILD_SHARED:BOOL=ON
    DEPENDS ${CHAIN}
)
set(CHAIN JsonCpp)

ExternalProject_Add(Lua
    URL https://www.lua.org/ftp/lua-5.4.4.tar.gz
    URL_HASH SHA256=164c7849653b80ae67bec4b7473b884bf5cc8d2dca05653475ec2ed27b9ebf61
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
        https://mirrors.kernel.org/gnu/libmicrohttpd/libmicrohttpd-0.9.72.tar.gz
    URL_HASH SHA256=0ae825f8e0d7f41201fd44a0df1cf454c1cb0bc50fe9d59c26552260264c2ff8
    BUILD_IN_SOURCE 1
    # prevent make from regenerating autotools files (requires automake), as for CppUnit below
    PATCH_COMMAND bash -c "touch aclocal.m4 && find . -name '*.in' -exec touch {} + && touch configure"
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
        ${COMMON_CMAKE_ARGS}
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
        ${COMMON_CMAKE_ARGS}
        -DBoost_ROOT=${InstallRoot}
        -DBUILD_SHARED_LIBS=OFF
    DEPENDS ${CHAIN}
)
set(CHAIN OpenEXR)

ExternalProject_Add(TBB
    URL https://github.com/oneapi-src/oneTBB/archive/2020_U3.tar.gz
    URL_HASH SHA256=2103cc6238c935664f87680618f6684d57501d4a2fa8ea8f6c97ad6ff7dc722a
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
        ${COMMON_CMAKE_ARGS}
        -DBlosc_ROOT=${InstallRoot}
        -DBoost_ROOT=${InstallRoot}
        -DTBB_ROOT=${InstallRoot}
    DEPENDS ${CHAIN}
)
set(CHAIN OpenVDB)

ExternalProject_Add(Log4CPlus
    GIT_REPOSITORY https://github.com/log4cplus/log4cplus
    GIT_TAG REL_2_0_5
    PATCH_COMMAND patch -p1 -N < ${THIS_DIR}/log4plus-limit-threads.patch || true
    # prevent make from regenerating autotools files (requires automake), as for CppUnit below
    COMMAND bash -c "touch aclocal.m4 && find . -name '*.in' -exec touch {} + && touch configure tests/testsuite"
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ./configure --prefix ${InstallRoot}
    BUILD_COMMAND make
    INSTALL_COMMAND make install
    DEPENDS ${CHAIN}
)
set(CHAIN Log4CPlus)

ExternalProject_Add(CppUnit
    URL https://dev-www.libreoffice.org/src/cppunit-1.15.1.tar.gz
    URL_HASH SHA256=89c5c6665337f56fd2db36bc3805a5619709d51fb136e51937072f63fcc717a7
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
    URL_HASH SHA256=c423a5a88d7a9a6ed667e41d025801c123fa0c5fd384d4ea138fa1fcf2bc24c9
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
        ${COMMON_CMAKE_ARGS}
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
    GIT_TAG 056b7b0cb0d087961e9dba75104820e44faf52a1 # v2.0.2
    BUILD_COMMAND ${CMAKE_COMMAND} -E env ${POLICY_MIN_ENV} make ${JOBS_ARG}
    CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
        -Dyaml-cpp_ROOT=${InstallRoot}
        -DOCIO_BUILD_APPS=OFF
        -DOCIO_BUILD_TESTS=OFF
        -DOCIO_BUILD_GPU_TESTS=OFF
        -DOCIO_USE_SSE=OFF
        -DOCIO_BUILD_PYTHON=OFF
        -DBUILD_SHARED_LIBS=ON
        -DOCIO_BUILD_STATIC=OFF
        -DCMAKE_CXX_STANDARD=17
    DEPENDS ${CHAIN}
)
set(CHAIN OpenColorIO)

ExternalProject_Add(TIFF
    URL https://gitlab.com/libtiff/libtiff/-/archive/v4.0.7/libtiff-v4.0.7.tar.gz
    URL_HASH SHA256=67c79057aa42ed8f48ae42dd1db60d56773d45cd7c8ec4c30857031adcd9ed2c
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
        -Dld-version-script=OFF
    DEPENDS ${CHAIN}
)
set(CHAIN TIFF)

ExternalProject_Add(JPEGTurbo
    GIT_REPOSITORY https://github.com/libjpeg-turbo/libjpeg-turbo
    GIT_TAG bb3d325624526c91646bb9af9578d7198c082d51 # 2.0.1
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
        -DWITH_SIMD=FALSE
    DEPENDS ${CHAIN}
)
set(CHAIN JPEGTurbo)

ExternalProject_Add(pybind11
    GIT_REPOSITORY https://github.com/pybind/pybind11
    GIT_TAG a2e59f0e7065404b44dfe92a28aca47ba1378dc4 # v2.13.6
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        ${POLICY_MIN}
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
        ${COMMON_CMAKE_ARGS}
        -DBoost_ROOT=${InstallRoot}
        -DIMath_ROOT=${InstallRoot}
        -DDISABLE_CMAKE_SEARCH_PATHS=TRUE
        -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=TRUE
        -DOpenEXR_ROOT=${InstallRoot}
        -DUSE_QT=0
        -DUSE_PYTHON=1
        -DPython_EXECUTABLE=/usr/bin/python3
    DEPENDS ${CHAIN}
)
set(CHAIN OpenImageIO)

ExternalProject_Add(OpenImageDenoise
   URL https://github.com/OpenImageDenoise/oidn/releases/download/v2.2.0/oidn-2.2.0.arm64.macos.tar.gz
   URL_HASH SHA256=16cdaddabeb0f2af22fc8e466317c1a14a54b6ec03db2ac343e17fad40c70f3f
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
            ${COMMON_CMAKE_ARGS}
            -DPXR_ENABLE_PYTHON_SUPPORT=ON
            -DPXR_USE_PYTHON_3=ON
            -DPXR_USE_DEBUG_PYTHON=OFF
            -DPYTHON_EXECUTABLE=/Library/Developer/CommandLineTools/usr/bin/python3
            -DPYTHON_LIBRARY=/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/lib/libpython3.9.dylib
            -DPYTHON_INCLUDE_DIR=/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9/Headers
            -DPYTHON_VERSION_MAJOR=3
            -DPYTHON_VERSION_MINOR=9
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
    URL https://downloads.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz
        https://sourceforge.net/projects/libuuid/files/libuuid-1.0.3.tar.gz/download
    URL_HASH SHA256=46af3275291091009ad7f1b899de3d0cea0252737550e7919d17237997db5644
    # prevent make from regenerating autotools files (requires automake), as for CppUnit above
    PATCH_COMMAND bash -c "touch aclocal.m4 && find . -name '*.in' -exec touch {} + && touch configure"
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
        https://github.com/curl/curl/releases/download/curl-7_88_1/curl-7.88.1.tar.gz
    URL_HASH SHA256=cdb38b72e36bc5d33d5b8810f8018ece1baa29a8f215b4495e495ded82bbf3c7
    # prevent make from regenerating autotools files (requires automake), as for CppUnit above
    PATCH_COMMAND bash -c "touch aclocal.m4 && find . -name '*.in' -exec touch {} + && touch configure"
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
        https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.gz
    URL_HASH SHA256=1ac27e16c134a7f2ccea177faba19801131116fd682efc1f5737037c5db224b5
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
        -DFT_REQUIRE_ZLIB=FALSE
        -DFT_REQUIRE_BZIP2=FALSE
        -DBUILD_SHARED_LIBS=true
    DEPENDS ${CHAIN}
)
set(CHAIN FreeType)

ExternalProject_Add(GLFW
    GIT_REPOSITORY https://github.com/glfw/glfw
    GIT_TAG 3.4
    BUILD_COMMAND make ${JOBS_ARG}
    CMAKE_ARGS
        ${COMMON_CMAKE_ARGS}
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
        -DGLFW_INSTALL=ON
        -DBUILD_SHARED_LIBS=ON
    DEPENDS ${CHAIN}
)
set(CHAIN GLFW)

