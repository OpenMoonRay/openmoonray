# Copyright 2024-2025 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# -*- coding: utf-8 -*-
import os, sys

name = 'openmoonray'

if 'early' not in locals() or not callable(early):
    def early(): return lambda x: x

@early()
def version():
    """
    Increment the build in the version.
    """
    _version = '3.6'
    from rezbuild import earlybind
    return earlybind.version(this, _version)

description = 'OpenMoonRay package'

authors = [
    'PSW Rendering and Shading',
    'moonbase-dev@dreamworks.com'
]

help = ('For assistance, '
        "please contact the folio's owner at: moonbase-dev@dreamworks.com")

variants = [
    [   # variant 0
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-vfx2023.1',
        'usd_core-0.23.8.x',
        'openimageio-2.4.8.0.x',
        'gcc-11.x',
        # 'openvdb-11',
        'openvdb-11.0.0.2', # temp fix to work around a package issue with openvdb-11.0.0.3
        'zlib-1.2.11.x'
    ],
    [   # variant 1
        'os-rocky-9',
        'opt_level-debug',
        'refplat-vfx2023.1',
        'usd_core-0.23.8.x',
        'openimageio-2.4.8.0.x',
        'gcc-11.x',
        # 'openvdb-11',
        'openvdb-11.0.0.2', # temp fix to work around a package issue with openvdb-11.0.0.3
        'zlib-1.2.11.x'
    ],
    [   # variant 2
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-vfx2023.1',
        'usd_core-0.24.3.x',
        'openimageio-2.4.8.0.x',
        'gcc-11.x',
        # 'openvdb-11',
        'openvdb-11.0.0.2', # temp fix to work around a package issue with openvdb-11.0.0.3
        'zlib-1.2.11.x'
    ],
    [   # variant 3
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-vfx2023.1',
        'usd_core-0.22.5.x',
        'openimageio-2.3.20.0.x',
        'gcc-11.x',
        # 'openvdb-11',
        'openvdb-11.0.0.2', # temp fix to work around a package issue with openvdb-11.0.0.3
        'zlib-1.2.11.x'
    ],
    [   # variant 4
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-vfx2023.1',
        'usd_core-0.22.5.x',
        'openimageio-2.3.20.0.x',
        'clang-17.0.6.x',
        'openvdb-10',
        'zlib-1.2.11.x'
    ],
    [   # variant 5
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-vfx2024.0',
        'usd_core-0.24.3.x',
        'openimageio-2.4.8.0.x',
        'gcc-11.x',
        # 'openvdb-11',
        'openvdb-11.0.0.2', # temp fix to work around a package issue with openvdb-11.0.0.3
        'zlib-1.2.11.x'
    ],
    [   # variant 6
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-vfx2025.0',
        'usd_core-0.25.5.1.x',
        'usd_view-0.25.5.1.x',
        'openimageio-3.0',
        'gcc-11.x',
        # 'openvdb-12',
        'openvdb-12.1.1.0', # temp fix to work around a package issue with openvdb-12.1.1.1
        'zlib-1.2.11.x'
    ],
    [   # variant 7
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-houdini21.0',
        'usd_core-0.25.5.1.x',
        'usd_view-0.25.5.1.x',
        'openimageio-3.0',
        'gcc-11.x',
        # 'openvdb-12',
        'openvdb-12.1.1.0', # temp fix to work around a package issue with openvdb-12.1.1.1
        'zlib-1.2.11.x'
    ],
    [   # variant 8
        'os-rocky-9',
        'opt_level-optdebug',
        'refplat-vfx2022.0',
        'usd_core-0.22.5.x',
        'openimageio-2.3.20.0.x',
        'gcc-9.3.x.1',
        'openvdb-9',
        'zlib-1.2.11.x',
        'opensubdiv-3.5.0.x.0'
    ],
]

conf_rats_variants = variants[0:2]

# Add ephemeral package to each variant.
for i, variant in enumerate(variants):
    variant.insert(0, '.openmoonray_variant-%d' % i)

requires = [
    'boost',
    'cuda-12.1.0.x',
    'curl_no_ldap-7.49.1.x',
    'embree-4.2.0.x',
    'imath-3',
    'jsoncpp-1.9.5',
    'libmicrohttpd-0.9.71.x.1',
    'log4cplus-1.1.2.x',
    'lua',
    'mkl',
    'openexr',
    'openimagedenoise',
    'opensubdiv',
    'openvdb',
    'optix-7.6.0.x',
    'qt',
    'random123-1.08.3',
    'tbb',
    'usd_imaging',
    'uuid-1.0.0',
]

private_build_requires = [
    'alembic',
    'cmake',
    'cppunit',
    'ispc-1.20.0.x',
    'python',
]

def commands():
    prependenv('ARRAS_SESSION_PATH', '{root}/sessions')
    prependenv('CMAKE_PREFIX_PATH', '{root}')
    prependenv('REZ_MOONRAY_ROOT', '{root}')
    prependenv('HOUDINI_PATH', '{root}/houdini')
    prependenv('HDMOONRAY_DOUBLESIDED', '1')
    prependenv('LD_LIBRARY_PATH', '{root}/lib64')
    prependenv('MOONRAY_CLASS_PATH', '{root}/coredata')
    prependenv('MOONRAY_DSO_PATH', '{root}/rdl2dso')
    prependenv('PATH', '{root}/bin')
    prependenv('PXR_PLUGIN_PATH', '{root}/plugin/pxr') # for legacy DWA USD builds
    prependenv('PXR_PLUGINPATH_NAME', '{root}/plugin/pxr')
    prependenv('PYTHONPATH', '{root}/python/lib/$PYTHON_NAME')
    prependenv('RDL2_DSO_PATH', '{root}/rdl2dso')

uuid = '7f6d2e07-4a15-4a50-87d6-9535e05d1f93'

config_version = 0
