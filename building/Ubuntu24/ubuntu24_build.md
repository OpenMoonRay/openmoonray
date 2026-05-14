# Building MoonRay on Ubuntu 24.04

Start with reading the [general build instructions](../general_build).

---
## Base Requirements
* CMake 3.23.1 (or greater)

* If you want to include MoonRay GPU support (XPU mode), you will also need to download the NVIDIA Optix headers
    (from [here](https://developer.nvidia.com/designworks/optix/downloads/legacy)), which require an EULA.
    Be sure to download version 7.6, as MoonRay is not yet compatible with their more recent releases.
    Once you have extracted the downloaded contents, note the location of the header files (under *include*): these will be copied to */usr/local/include* in step 3 below.

---
### Step 1. Create the folders
Create a clean root folder for moonray.  Attempting to build atop a previous installation may cause issues.
The folders can be created in the location of your choosing, but these instruction, the provided CMake presets,
and several of the scripts mentioned below assume this location/structure.
```bash
mkdir -p /opt/MoonRay/{installs,build,build-deps,source}
mkdir -p /opt/MoonRay/installs/{bin,lib,include}
```

---
### Step 2. Clone the OpenMoonRay source
```bash
sudo apt install -y git git-lfs
cd /opt/MoonRay/source
git clone --recurse-submodules https://github.com/dreamworksanimation/openmoonray.git
```

Note: If building for Houdini, you'll potentially need to make the following changes before proceeding:
* Edit source/openmoonray/CMakeLinuxPresets.json to update HOUDINI_INSTALL_DIR
* Edit source/openmoonray/scripts/Ubuntu24/setupHoudini.sh to update HOUDINI_PATH
* Edit source/openmoonray/building/Ubuntu24/pxr-houdini/pxrTargets.cmake to update HPYTHONLIB and HPYTHONINC if needed

---
### Step 3. Install some of the dependencies via script/package manager
```bash
sudo source openmoonray/building/Ubuntu24/install_packages.sh
sudo apt install nvidia-cuda-toolkit
```
You can add arguments `--nocuda` and `--noqt` to skip GPU and GUI support respectively.
If you are building with GPU support, copy the Optix headers that you downloaded and extracted into */usr/local*

```bash
cp -r /tmp/optix/include/* /usr/local/include
```

---
### Step 4. Build the remaining dependencies from source
Note: If building for Houdini you'll need to build moonray against Houdini's USD libraries.
You'll want to skip building USD during this step by adding `-DNOUSD=1` to the first cmake
command below: `cmake -DNO_USD=1 ../source/openmoonray/building/Ubuntu24`.  You should clean
the build-deps/ and installs/ directory if you have previously installed the dependencies
without passing -DNOUSD=1, to remove any USD related files or step 5 may fail to link to
Houdini's USD libs.
```
cd /opt/MoonRay/build-deps
cmake ../source/openmoonray/building/Ubuntu24
cmake --build . -- -j $(nproc)
```

---
### Step 5. Build MoonRay
Note: If building for Houdini, replace ubuntu24-release presets below with ubuntu24-houdini-release
```
cd /opt/MoonRay/source/openmoonray
cmake --preset ubuntu24-release
cmake --build --preset ubuntu24-release -- -j $(nproc)
```

---
### Step 6. Run/Test
```
source /opt/MoonRay/installs/openmoonray/scripts/setup.sh
cd /opt/MoonRay/source/openmoonray/testdata
moonray_gui -exec_mode xpu -info -in curves.rdla
```

HOUDINI:
Open a terminal and run:
```
cd /opt/hfs20.0  # location of houdini install
source houdini_setup
source /opt/MoonRay/source/openmoonray/scripts/Ubuntu24/setupHoudini.sh
houdini
```

In the Main menu bar at top select Desktop->Solaris
In the Scene View tab on the main window, change from "obj" to "stage".
Click in the Solaris network editor, hit tab, type "sphere" and hit enter to place a sphere on the stage.
In the viewport menu, click on "Persp" and select "Moonray", this should trigger rendering.

---
### Step 8. Post-build/install Cleanup
```
rm -rf /opt/MoonRay/{build,build-deps}
```

