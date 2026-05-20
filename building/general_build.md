# Building Open MoonRay

### Linux
MoonRay currently builds on Linux systems. We test the build on Rocky Linux 9 (with GCC 11). It should be possible to build on other distributions, but often some adjustments are needed, especially regarding obtaining the necessary third-party dependencies. MoonRay can be built directly on a Linux system or inside a suitable Docker container.

Support for GPU/XPU and building of the GUI tools are both options that can be turned off if you don't need them.

The build process described here includes cloning the source, obtaining the required dependencies and building MoonRay itself. The details depend somewhat on the Linux distribution being used, whether you need compatibility with some other software or build framework, and where you want to install MoonRay. This document discusses the various alternatives. For more concrete instructions, look at the documents that discuss building on specific platforms.

### macOS
MoonRay now also builds on macOS Apple silicon systems and can leverage the unified memory architecture for XPU mode. Much of the content in these general build instructions are applicable to macOS, although they were originally written for Linux builds. Look [here](macOS/macOS_build.md) for macOS specific instructions.

---
## MoonRay Source Repositories
---

The Open MoonRay source is split into 19 git repositories, all available at [GitHub](https://github.com/OpenMoonRay). Each repository can be built separately, by invoking cmake with the root of the repository as the source path. This requires that CMake be configured so that it can find all of the libraries and tools that are needed by the particular repository you are building.

We've created the ***openmoonray*** repository as a way to download and build all of the source in one step, without worrying about dependencies between the separate repositories. It is highly recommended that you use this process, unless you have a strong reason to build the individual parts separately, or to build only a subset. However, the *openmoonray* repository is not a *necessary* part of the Open MoonRay source : we do not use it for the builds we use internally in production.

If you do want to build the repositories separately, the process may be made easier by using a dependency/build framework like Rez/rez-build. The following page has a description of the individual repositories and their dependencies : [Open Moonray Repositories](repo_deps.md), and some more information is given below.

---
## Getting the source via the ***openmoonray*** repository
---

The *openmoonray* repo references 19 other repositories via *Git* submodules. Some of these submodules use Git LFS to track some of the files. To install Git LFS use the following git command:

```bash
git lfs install
```

Next, to clone all the repositories into one structure, run the following git command:

```bash
git clone --recurse-submodules https://github.com/OpenMoonRay/openmoonray.git
```

The source for every repository will be downloaded and organised into a directory structure that enables everything to be built using a single CMake project at the root of the *openmoonray* clone. Of course, you can also clone the repositories individually into any structure you want, but you will then need to build them separately.

---
## Obtaining the dependencies
---

MoonRay is dependent on a number of third-party libraries and tools. You can obtain these however you want, but the *openmoonray* repo defines a "canonical" process for selected platforms. 

Rather than providing a list of dependencies and versions, we provide sets of scripts and CMake projects in the */building* directory of *openmoonray*. Running these scripts will install the dependencies onto the system. This has several advantages. Firstly, the scripts will always match the current source, and can be directly tested for accuracy by running them. Secondly, they contain build options and other settings, as well as specifying a particular version for each dependency. If your requirements fit what they do, you can simply run them directly to install the dependencies. If not, you can either modify them as appropriate, or use them as a reference.

There are separate directories under */building* for obtaining dependencies based on OS or Linux distribution (currently Rocky Linux 9 and macOS Sonoma). The rest of this section describes how to use the scripts. They are designed to run in the *bash* shell.

### 1. Packages

The first step is to install required packages from the OS distribution. The availability of suitable package versions varies from distribution to distribution: for example, Rocky Linux 9 has more of the dependencies available than did Centos 7. If there is no suitable binary package for a dependency, you can download it as source and build it -- as discussed in the next section. The script to install the required packages is called *install_packages.sh*. It makes some changes to the current shell environment, so you should run it like this:

```bash
source building/Rocky9/install_packages.sh
```

Generally root permissions are necessary to install packages onto a system. It might be possible to install to an alternate location that doesn't require root permissions, but we have not tested this.

*install_packages.sh* has two options. ***`--nocuda`*** skips installation of the CUDA libraries, and can be used if you are not building with GPU support. ***`--noqt`*** skips installation of the Qt libraries, and can be used if you are not building the GUI apps.

**Compiler**

The Rocky 9 script installs GCC 11. clang 13/15 should also work for MoonRay, but we have seen a few issues building the dependencies with clang.

**CMake**

The MoonRay build system requires CMake version at least 3.23.1 (mainly for ISPC support). This is newer than most distributions currently provide, so the *install_packages.sh* scripts download a version from the main CMake site.

**CUDA**

MoonRay's GPU support requires the NVidia CUDA libraries. It you are not planning to build with GPU support, then CUDA is not needed and you can run *install_packages.sh* with the --nocuda option

**Qt 5**

The GUI tools ***moonray_gui*** and ***arras_render*** are written using Qt 5. If you do not plan to build these GUI tools, you can run *install_packages.sh* with the --noqt option.

### 2. Dependencies built from source

The directories */building/macOS* and */building/Rocky9* also contain CMake projects that download and build the remaining dependencies from source. If you view the *CMakeLists.txt* files, you will see a series of ***ExternalProject_Add*** commands. Each one of these spawns a separate CMake environment that downloads, builds and installs a third-party package. You can view the full syntax for *ExternalProject_Add* [here](https://cmake.org/cmake/help/v3.23/module/ExternalProject.html), but in most cases it should be fairly clear what the options do. If you already have some of the dependencies installed, or you have some other way of obtaining them, you can comment out the corresponding command in *CMakeLists.txt*. You can also try changing options or versions if you need to : the project contains settings that we have tested, but they are not necessarily the only set that work.

The procedure for running the dependencies CMake project is as follows:

- Choose a build directory - can be anywhere, but I'll assume */build*. Run the cmake command, providing the location of *CMakeLists.txt* (I'll assume we're building for Rocky 9 and */source* contains a clone of the *openmoonray* repo):

```bash
mkdir /build
cd /build
cmake /source/building/Rocky9
cmake --build . -- -j $(nproc)
```

The option *-j $(nproc)* tells make/cmake to use all available cores for building : you can change this to a number, or omit the option entirely for serial building.

The projects are set up to build the individual dependencies serially : the DEPENDS line on each *ExternalProject_Add* forces this. Issues or errors in the build process tend to be less confusing when run this way, but you can try optimzing the dependencies to enable a faster, fully-parallel build if desired. Once the build is complete, you can delete the contents of the build directory.

The dependency building projects don't have many configuration options. Generally, adapting the process to run on a different platform requires trial and error, producing multiple inter-related changes. We don't have any very practical way to capture the differences in a model that is any simpler than the scripts themselves. Therefore developing a new dependency install process in practice means producing a new set of scripts, similar to the set for Rocky 9.

You can change the directory that the dependency build project installs to, using the variable *InstallRoot*. For example:

```bash
cmake /source/building/Rocky9 -DInstallRoot=~/moonray/dependencies
cmake --build . -- -j $(nproc)
```

If you do this, you will also have to configure the main CMake build of MoonRay to find the dependencies in their alternate location. The default value of *InstallRoot* is */usr/local* : this corresponds to the default location that CMake looks at to find dependencies, and so with the default setting, the main MoonRay CMake will find the dependencies without further hints. The is discussed further below. 

---
## Building MoonRay
---

Once the dependencies are installed, you can run the main MoonRay CMake project. If you don't need to set any additional CMake configuration, the steps are as follows:

- Start from an empty build directory, which can be anywhere.
```bash
cmake <openmoonray root dir>
cmake --build . -- -j $(nproc)
```

- You can then install the build result wherever you want
```bash
cmake --install . --prefix <install dir>
```

There are many different options supported by CMake, such as the choice of compiler to use, and whether to make a debug or release build. See the [CMake documentation](https://cmake.org/cmake/help/v3.23) for full coverage.

The MoonRay CMake project also includes some custom options, some of which may be required by the build environment. To build on Rocky Linux 9, you will need to set the options *PYTHON_EXECUTABLE=python3*, *BOOST_PYTHON_COMPONENT_NAME=python39*, and *ABI_VERSION=0*

```bash
# Rocky 9
cmake <openmoonray root dir> -DPYTHON_EXECUTABLE=python3 -DBOOST_PYTHON_COMPONENT_NAME=python39 -DABI_VERSION=0
cmake --build . -- -j $(nproc)
```

Setting ***-DBUILD_QT_APPS=NO*** will suppress building of the Qt applications *moonray_gui* and *arras_render*, which removes the dependency on Qt5 libraries.

Setting ***-DMOONRAY_USE_OPTIX=NO*** builds MoonRay without GPU support : CUDA and Optix are no longer required dependencies, but MoonRay will not use XPU mode or GPU denoising even if a GPU is present at run time.

---
## Installation Setup
---

The installation contains a script ***scripts/setup.sh*** that sets up a shell environment suitable for running MoonRay:

```bash
source <install dir>/scripts/setup.sh
```

The MoonRay Hydra plugin requires class descriptions in JSON form to function. These are automatically built by *setup.sh* if they don't exist, but the command to build them manually is:

```bash
bin/rdl2_json_exporter --out <output dir>/ --sparse
```

The output directory is normally *shader_json* directly under the install root, but you can put them where you want as long as the environment variable MOONRAY_CLASS_PATH points to them. Note that the trailing slash is required when specifying the output directory to *rdl2_json_exporter*

The other environment variables set up by *setup.sh* are:

|Variable|Purpose|
|--------|-------|
| **PATH += *release*/bin** | *(must be set for Arras to function correctly)* |
| **RDL2_DSO_PATH = *release*/rdl2dso** | *tells moonray where to find plugin shared libraries* |
| **REZ_MOONRAY_ROOT  = *release*** | *tells moonray where to find shaders file for XPU mode (it will look for ${REZ_MOONRAY_ROOT}/shaders/GPUShaders.ptx* |
| **ARRAS_SESSION_PATH = *release*/sessions** | *tells Arras where to find session files* |
| **MOONRAY_CLASS_PATH = *release*/shader_json** | *tells Hydra Ndr plugins where to find shader descriptions (see above)* |
| **PXR_PLUGINPATH_NAME += *release*/plugin/pxr** | *adds MoonRay Hydra plugins to Hydra plugin path* |

*setup.py* doesn't set up PYTHONPATH to include the Python modules that come with USD. It doesn't need to be set for MoonRay's purposes, but the *hd_render* command will log a series of warnings that they are not found. This isn't harmful, because *hd_render* doesn't invoke Python code.

---
## Testing the install
---

There are some very simple test files in the source release that you can use to check the install is valid:

Test commandline MoonRay:
```bash
> moonray -in /source/testdata/rectangle.rdla -out /tmp/rectangle.exr
```

Test the moonray_gui Qt app (if built)
```bash
> moonray_gui -in /source/testdata/rectangle.rdla -out /tmp/rectangle.exr
```

Test the Hydra plugin:
```bash
> hd_render -in /source/testdata/sphere.usd -out /tmp/sphere.exr
```

---
## Finding Dependencies
---

If you choose to install or use dependencies in non-standard locations, you will need to configure the main MoonRay CMake build to tell it where they are.

CMake has standard methods for locating the pre-built dependencies of a project. The default, without any additional settings, is normally to look in */usr/local* : */usr/local/include* for headers, */usr/local/lib* for libraries, */usr/local/bin* for executables, and so on.

If CMake cannot find a dependency, you will usually see an error message like this:

```
CMake Error at /rel/third_party/cmake/3.25.2/share/cmake-3.25/Modules/FindPackageHandleStandardArgs.cmake:230 (message):
  Could NOT find JsonCpp (missing: JsonCpp_INCLUDE_DIRS JsonCpp_LIBRARIES)
```

In the case of JsonCpp, you can tell CMake to look in an alternate location by setting the environment variable JSONCPP_ROOT prior to running cmake. For example:

```bash
export JSONCPP_ROOT=/moonray_deps/jsoncpp
```

will cause cmake to look for the headers in */moonray_deps/jsoncpp/include*, and the library in */moonray_deps/jsoncpp/lib*.

The environment variables used for the different packages are:

- CPPUNIT_ROOT
- JSONCPP_ROOT
- LIBCURL_ROOT
- LIBUNWIND_ROOT
- LOG4CPLUS_ROOT
- LUA_DIR
- OPENSUBDIV_ROOT
- OPENVDB_ROOT
- OPTIX_ROOT
- ISPC

The ***ISPC*** environment variable should be set to point to the ISPC compiler binary (i.e. *.../bin/ispc*).

There is an alternative method, generally used when the dependency is itself built with CMake. CMake can generate a script -- usually called ***packagename*Config.cmake**, where ***packagename*** is the name of the package being built -- that correctly configures a dependency for use in other projects. These config scripts are installed with the dependency. For CMake to find them, the CMake variable ***CMAKE_PREFIX_PATH*** must include the directory containing them (or an ancestor). This second method is used for the following libraries:

- Boost
- Cuda
- Embree
- OpenColorIO
- OpenImageIO
- OpenEXR
- OpenImageDenoise
- MicroHttpd
- Qt
- TBB
- pxr

The Pixar USD libraries are required for Hydra and USD support, and are found under the name "pxr". A file ***pxrConfig.cmake*** somewhere on CMAKE_PREFIX_PATH is required for the build to work. *pxrConfig.cmake* should be generated and installed automatically when USD is built from source.

If you systematically install all the dependencies somewhere other than */usr/local*, you will need to set all the *_ROOT* hint variables, plus *CMAKE_PREFIX_PATH*, to the alternate locations. One way to do this is with CMake presets, discussed briefly in the next section.

---
## CMake Presets
---

CMake provides a ***presets*** mechanism, which can be useful to capture sets of CMake configuration options. They are contained in files called *CMakePresets.json* and *CMakeUserPresets.json*. The difference is that *CMakeUserPresets.json* is typically used for presets that you don't want to add to source control. The full documentation for presets is [here](https://cmake.org/cmake/help/v3.23/manual/cmake-presets.7.html).

---
## Building in a Docker container
---

You can build MoonRay inside a Docker container: the process isn't really different than building directly on a machine. There are instructions for building in a container for Rocky 9, but the process may be different for other distributions.

### Container build tips

You might need to use the docker run option ***--security-opt seccomp=unconfined*** to allow the container to access the host network fully. This seems to be required for Rocky 9 images.

You can clone the Open MoonRay source on the host machine and mount it into the container, which may be more convenient than cloning from inside the container. It can also be useful to mount */tmp*, as a way to transfer files between the host and the container. To mount a directory in the container, use the -v option to docker run:

```bash
docker run --security-opt seccomp=unconfined -v <openmoonray source>:/source -v /tmp:/tmp --network=host --rm -it rockylinux:9
```

You can save the current state of the container at any time using the docker commit command. However, note that this will not save the current shell environment : when you run the saved container it will start a new *bash* shell.

You can use the docker build command to create an initial base container with the OS and the packages installed by *install_packages.sh*. This is done by writing a "Dockerfile" with the contents of *install_packages.sh* translated into docker build commands. You don't have to do this, and it is not documented further here.

Running the GUI applications from inside a container requires X to be set up in the container. Exactly how to do this may depend on the X setup on the host, but the documented Rocky 9 process gives an example.

---
## Building the Repositories Separately
---

Each repository can be built on its own, by running the CMake project (*CMakeLists.txt*) at the root of the repository. The dependencies required for each repository are listed here: [Open Moonray Repositories](repo_deps.md). 

There are a number of different variables and options that need to be set correctly : to build this way regularly, you will probably want to automate the process or use a build/configuration system like Rez.

The external dependencies can be set up in the same way as for the full build. If you are not installing them directly on to the machine, read the section on **Finding Dependencies** above for how to configure the CMake build to find them.

Many of the repositories use the source files (mostly cmake modules) in the ***cmake_modules*** repository, so you need access to a clone of this repo. Set the environment variable ***CMAKE_MODULES_ROOT*** to point to the root of this repository. Also, make sure the correct versions of CMake and the C++ compiler are set on your PATH.

To deal with dependencies between the different MoonRay repositories, each repo generates a ***reponame*Config.cmake** as part of the install process. For example, installing scene_rdl2 generates the file `lib64/cmake/SceneRdl2-12.4.0.0` under the install root. For these to be found, the install roots should be added to the environment variable ***CMAKE_PREFIX_PATH***. 

For example, building the ***moonray*** repository requires the repositories ***mcrt_denoise*** and ***scene_rdl2*** to be previously built and installed, so you would set the prefix path as follows:

```bash
export CMAKE_PREFIX_PATH=<root of scene_rdl2 install>:${CMAKE_PREFIX_PATH}
export CMAKE_PREFIX_PATH=<root of mcrt_denoise install>:${CMAKE_PREFIX_PATH}
```

(if CMAKE_PREFIX_PATH already contains entries for external dependencies, obviously these must be preserved)

Repositories that compile MoonRay shaders need access to the ***rdl2_json_exporter*** program, which is installed by the *scene_rdl2* repository. Therefore, once *scene_rdl2* is built and installed, add its ***bin*** directory to PATH:

```bash
export PATH=<root of scene_rdl2 install>/bin:${PATH}
```
Once everything is set up run *cmake* in an empty build directory, passing the root of the repository you are building as the source path. The arguments need to be the same as for a full build, with the addition of `-DCMAKE_MODULE_PATH=${CMAKE_MODULES_ROOT}/cmake` (so that the cmake modules in the *cmake_modules* repository are visible to cmake). For example, on Rocky 9:

```bash
cmake /source/moonray/moonray -DCMAKE_MODULE_PATH=${CMAKE_MODULES_ROOT}/cmake -DPYTHON_EXECUTABLE=python3 -DBOOST_PYTHON_COMPONENT_NAME=python39 -DABI_VERSION=0
```

Then you can build and install as usual:

```bash
cmake --build . -- -j $(nproc)
cmake --install . --prefix <install dir>
```

### Summary:

- External dependencies must be set up (as for a full build)
- CMake and C++ compiler must be set up on PATH
- Internal dependencies (on other MoonRay repos) are set up by adding the root of the dependency install to CMAKE_PREFIX_PATH.
- Once scene_rdl2 is built and installed, its bin directory should be added to PATH
- set the environment variable CMAKE_MODULES_ROOT to the root of the *cmake_modules* repository (source), and also pass the argument `-DCMAKE_MODULE_PATH=${CMAKE_MODULES_ROOT}/cmake` to the cmake command.
