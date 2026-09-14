# Building MoonRay on macOS

Start with reading the [general build instructions](../general_build).

---
## Base Requirements
- Apple M-series hardware
    - macOS 14.6 Sonoma / Xcode 15.4
    - macOS 15.6 Sequoia / Xcode 16.4
    - macOS 26.0.Tahoe / Xcode 26.0
    - macOS 26.5 Tahoe / Xcode 26.6
- 17+ GB Disk Space
- Install Xcode
- Tahoe requires an additional component: `xcodebuild -downloadComponent MetalToolchain`
- `/usr/bin/python3` must be the internal macOS Python 3.9 shim (this is default with an Xcode install)
- Git and [Git LFS](https://git-lfs.com/)
- Download and install CMake 3.26.5 (or greater):
    https://github.com/Kitware/CMake/releases/download/v3.26.5/cmake-3.26.5-macos-universal.dmg
    ```bash
    sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install
    ```

---
### Step 1. Create the folders
Create a clean root folder for moonray.  Attempting to build atop a previous installation may cause issues.
```bash
mkdir -p /Applications/MoonRay/{installs,build,build-deps,source}
mkdir -p /Applications/MoonRay/installs/{bin,lib,include}
```

---
### Step 2. Check out the OpenMoonRay source
```bash
cd /Applications/MoonRay/source
git clone --recurse-submodules <repository>
```

---
### Step 3. Create symbolic links
```bash
cd /Applications/MoonRay
ln -s source/openmoonray/building .
ln -s source/openmoonray .
```

Note: If building for Houdini, you'll potentially need to make the following changes before proceeding:
* Edit source/openmoonray/CMakeMacOSPresets.json to update HOUDINI_INSTALL_DIR
* Edit source/openmoonray/scripts/macOS/setupHoudini.sh to update HOUDINI_PATH
* Edit source/openmoonray/building/macOS/pxr-houdini/pxrTargets.cmake to update HPYTHONLIB and HPYTHONINC if needed

Houdini 20 is officially supported. The experimental Houdini 22 alignment and
its exact dependency, submodule, build, and validation details are documented
in [Houdini22_build_notes.md](Houdini22_build_notes.md).

---
### Step 4. Build the dependencies
Note: If building for Houdini you'll need to build moonray against Houdini's USD libraries.
You'll want to skip building USD during this step by adding `-DNO_USD=1` to the first cmake
command below: `cmake -DNO_USD=1 ../building/macOS`.  You should clean
the build-deps/ and installs/ directory if you have previously installed the dependencies
without passing -DNO_USD=1, to remove any USD related files or step 5 may fail to link to
Houdini's USD libs.
```bash
cd /Applications/MoonRay/build-deps
cmake ../building/macOS
cmake --build .
```

---
### Step 5. Build MoonRay
Note: If building for Houdini, replace macos-release presets below with macos-houdini-release
```bash
cd /Applications/MoonRay/openmoonray
cmake --preset macos-release
cmake --build --preset macos-release
```

---
### Step 6. Run/Test
```bash
source /Applications/MoonRay/installs/openmoonray/scripts/setup.sh
cd /Applications/MoonRay/openmoonray/testdata
moonray_gui -exec_mode xpu -info -in curves.rdla
```

HOUDINI:
Open "Houdini Terminal" in Applications and run:
```bash
source /Applications/MoonRay/installs/openmoonray/scripts/macOS/setupHoudini.sh
houdini
```

In the Main menu bar at top select Desktop->Solaris.
In the Scene View tab on the main window, change from "obj" to "stage" if it is not already set to "stage".
Click in the Solaris network editor, hit tab, type "sphere" and hit enter and then click to place a sphere on the stage.
In the viewport, click on "Persp" and select "Moonray", this should trigger rendering.

---
### Step 7. Post-build/install Cleanup
```bash
rm -rf /Applications/MoonRay/{build,build-deps}
```
