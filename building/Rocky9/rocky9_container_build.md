# Building MoonRay in a Rocky 9 Docker container
 
Start with reading the [general build instructions](../general_build).

This document follows essentially the same process as building directly on a Rocky Linux 9 system, but inside a container.

To keep it concrete, I've chosen specific directory locations inside the container : you can change these if needed:

- */source* location of the openmoonray repository clone
- */build* CMake build directory
- */installs/moonray* location to install MoonRay

You will need Docker, Git, Git LFS, and a copy of the MoonRay source.  Some of these submodules use Git LFS to track some of the files. To install Git LFS use the following git command:

```bash
git lfs install
```

To clone the source from the github repo (on the host), use this git command:

```bash
> git clone --recurse-submodules https://github.com/OpenMoonRay/openmoonray.git 
```
You can place the clone anywhere : the rest of this document calls the directory you have cloned openmoonray into (on the host machine) ***openmoonray-dir***. It will be mounted at */source* inside the container.

This version of the build omits Cuda/GPU support, because GPU devices are not generally available inside a container. See the general build documentation for how to add GPU support.

---
## Step 1. Base requirements
---

Start a new container running the rockylinux:9 image:

```bash
> docker run -v <openmoonray-dir>:/source -v /tmp:/tmp --security-opt seccomp=unconfined --rm -it rockylinux:9
```

Once inside the container, the first step is to install some additional RPM packages. The script *building/Rocky9/install_packages.sh* will install the packages and perform some environment variable setup. 

```bash
source /source/building/Rocky9/install_packages.sh --nocuda
```

---
## Step 2. Build the remaining dependencies
---

The next step is to build the remaining dependencies from source. The CMake project *building/Rocky9/CMakeLists.txt* contains targets that will do it automatically.

```bash
> mkdir /build
> cd /build
> cmake /source/building/Rocky9
> cmake --build . -- -j $(nproc)
```

The option "-j $(nproc)" tells CMake to use all available cores on your machine for building.

---
## Step 3. Build MoonRay
---

The main CMake project in *openmoonray* builds MoonRay itself, and installs it to a specified location.

```bash
> rm -rf /build/*
> cd /source
> cmake --preset rocky9-release -DMOONRAY_USE_OPTIX=NO
> cmake --build --preset rocky9-release -- -j $(nproc)
```

Set up the install and test moonray:

```bash
> source /installs/openmoonray/scripts/setup.sh
> moonray -in /source/testdata/rectangle.rdla -out /tmp/rectangle.exr
> hd_render -in /source/testdata/sphere.usd -out /tmp/sphere.exr
```

If everything is working, the moonray command should produce output like this:

```
Loading Scene File(s): /source/testdata/rectangle.rdla
Render prep time = 00:00:00.008
  [+] Rendering [======================] 100.0%
00:00:01  671.2 MB | ---------- Time ------------------------------------------
00:00:01  671.2 MB | Render time                      = 00:00:01.404000
00:00:01  671.2 MB | Total time                       = 00:00:01.442000
Wrote /tmp/rectangle.exr
```
---
## Step 4 : Commit container
---

To reduce the container size, you may want to delete all the files in */build* before saving the container : they are no longer needed.

To save the container as an image, run 'docker ps` in another shell. This will show you the running container ID. Then you can use "docker commit" to save the container out to a new *openmoonray* Docker image:

```bash
> docker ps

CONTAINER ID        IMAGE               ...
c3a90b08a53a        rockylinux:9    ...

> docker commit c3a90b08a53a openmoonray
```

The container ID will be different in your case. Do not exit the shell that is running the container until the commit command completes.

To run the new container:

```bash
> docker run -v <openmoonray-dir>:/source -v /tmp:/tmp --security-opt seccomp=unconfined --rm -it openmoonray
```

Moonray doesn't need the source repository mounted to run, but it is included here to provide access to the test files. You can add any additional mounts you need to access files on the host machine.

You will need to rerun *setup.sh* once the container is started, to set up the environment:

```bash
> source /installs/openmoonray/scripts/setup.sh
> moonray -in /source/testdata/rectangle.rdla -out /tmp/rectangle.exr
```

---
## Running moonray_gui
---

To run **moonray_gui**, you need to set up X in the container. The steps required may vary depending on the host setup, but generally you will need to set the environment variables ***DISPLAY*** and ***XAUTHORITY***, and make sure the directory that *XAUTHORITY* points to is mounted in the container. 


```bash
> docker run -v <openmoonray-dir>:/source -v /tmp:/tmp -e DISPLAY=$DISPLAY -e XAUTHORITY=${XAUTHORITY} -v "${XAUTHORITY}:${XAUTHORITY}:z" --security-opt seccomp=unconfined --rm -it openmoonray
> source /installs/openmoonray/scripts/setup.sh
> moonray_gui -in /source/testdata/rectangle.rdla -out /tmp/rectangle.exr
```


