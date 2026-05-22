---
title: Open MoonRay repositories
---
# Open MoonRay repositories

The following table lists the MoonRay repositories and their requirements.
"Internal Dependencies" are dependencies on other MoonRay repositories, "External Dependencies" are third-party packages that must be installed prior to build.

As well as the dependencies listed here, you will need an appropriate C++ compiler and CMake itself.

| Repository | Internal dependencies | External dependencies |
|----|----|----|
| **cmake_modules** *Modules used in the build process* | None | cmake |
| **scene_rdl2** *MoonRay's scene representation* | None | boost, jsoncpp, log4cplus, lua, tbb |
| **mcrt_denoise** *Denoiser* | scene_rdl2 | cuda, openimagedenoise, optix, cppunit |
| **moonray** *Command-line renderer* | mcrt_denoise, scene_rdl2 | boost, cuda, embree, openexr, openimageio, opensubdiv, openvdb, optix, random123, zlib, cppunit, ispc, python |
| **moonray_gui** *Simple Qt viewer for MoonRay* | moonray, mcrt_denoise | qt5, cppunit |
| **moonshine** *Shaders* | moonray, scene_rdl2 | openimageio, cppunit, ispc, python |
| **moonshine_usd** *Usd-specific shaders* | moonray, moonshine | usd, cppunit, ispc |
| **moonray_dcc_plugins** *Tools to use MoonRay with DCC applications* | None | None |
| **render_profile_viewer** *Tool to analyse render performance* | None | python-3.7, PyQt5, PyQtChart, openimageio, importlib_metadata |
| **arras4_core** *Core Arras libraries* | None | uuid boost curl jsoncpp libmicrohttpd cppunit |
| **arras4_node** *Arras service for distributed rendering* | arras4_core | None |
| **mcrt_messages** *Communication protocol for Arras and MoonRay* | arras4_core | None |
| **mcrt_dataio** *Progressive image compression used with Arras* |arras4_core, mcrt_denoise, mcrt_messages, scene_rdl2 | cppunit |
| **mcrt_computation** *Implementation of MoonRay rendering via Arras* | arras4_core, mcrt_dataio, mcrt_messages, moonray, scene_rdl2 | cppunit |
| **arras_render** *Simple Qt viewer for Arras renders* | arras4_core, mcrt_dataio, mcrt_messages, scene_rdl2 | boost, jsoncpp, openimageio, openexr, qt, cppunit |
| **moonray_sdr_plugins** *Support for using MoonRay shaders with Hydra* | None | boost, usd |
| **hdMoonray** *Moonray Hydra plugin* | moonray, moonshine, mcrt_computation, arras4_core, mcrt_messages, mcrt_dataio, moonray_sdr_plugins |  openimageio, cppunit |
| **minicoord** *Arras service for distributed rendering* | None | python-2.7 | 
| **openmoonray** *Overall build for MoonRay* | All of the above | All of the above |

 

