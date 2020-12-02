
# Building
To build locally, just run:
```bash
./build.sh --platform=<amd64|raspberrypi3>
./build.sh --bootstrap --platform=<amd64|raspberrypi3>
```

Use
--bootstrap for the bare minimum

The CI server will take care of deploying images to Dockerhub.

# General Use for Development
1. Navigate to project directory
2. Launch a development container with run.sh and any desired options
3. Project directory will be shared to ~/workspace in the container. All changes to files in here will happen within the host as well.
4. cd into the ~/workspace directory, then build/run/debug your code as desired

## Alias setup
To make it easy to launch a dev container at any time, create an alias in .bashrc, or your platform's equivalent:
```bash
alias dev="<path_to>/run.sh"
```

## Caching
The run.sh script creates and shares multiple cache directories, such that they can persist and be shared across multiple container instances.

Cached files all live in the ~/.local/pidev/ directory on the Host.

Cached resources include:
- CLion preferences
- Conan packages
- A general purpose /data/ folder that would normally exist on any Balena device

## Permissions fixup
Because of mismatches between users/groups on host versus Docker image, a possible 
work around:
```bash
chmod a+rw -R ~/.local/pidev
```

This avoids having to run as root, which would be worse permissions wise. 

## Conan
Conan is installed as part of the image. Packages persist via the cache, so as to avoid unneccessary redownloading/rebuilding.

To access private Conan repositories on Artifactory, these environment variables need to be set:
- CONAN_LOGIN_USERNAME
- CONAN_PASSWORD

Once in the container, you need to authenticate with the private remote repo via (you only need to do this once):
```bash
conan user -r <REPO> -p
```

## Nvidia Support
If you are working on a system with Nvidia hardware and want to use hardware acceration and/or CUDA, install nvidia-docker and pass the option:
```bash
run.sh --nvidia
```

## CLion Support
For debugging on x86_64, you can share the CLion IDE into the container:
```bash
# You can use whatever CLion version you want
CLION_VERSION=2018.3.3
run.sh --clion=${CLION_VERSION}
```
The script expects CLion installations to exist in ${HOME}/jetbrains/clion/${CLION_VERSION}, but you can easily modify this to suit your needs.

## GUI Support
The run script is configured to allow launching of GUI applications which communicate with the host's XServer.

## ARM Support
For running ARM containers, first run the following to register support for armv7 binaries via qemu-user-static:
```bash
# '--credential yes' allows 'sudo' to work properly: 
# https://github.com/multiarch/qemu-user-static/issues/17
docker run --rm --privileged multiarch/qemu-user-static:register --reset --credential yes
```

Then pass --arm to run.sh to launch an ARM development container:
```bash
run.sh --arm
```
