#!/bin/bash
ROS_VERSION=galactic

IMAGE_NAME=aica-technology/kuka-iiwa-description
IMAGE_TAG=latest

HARDWARE=""
HARDWARE_DESCRIPTIONS_BRANCH="develop"

HELP_MESSAGE="Usage: build-interactive.sh [--hardware \"hardware\"] [-r] [-v] [--description-branch \"branch\"]
Options:
  --hardware \"\"                 Specify a list of hardware for which to
                                  install the description packages, contained within
                                  quotes and separated by spaces.
  -r, --rebuild                   Rebuild the image using the docker
                                  --no-cache option
  -v, --verbose                   Use the verbose option during the building
                                  process
  --description-branch \"branch\" Set the branch of the hardware-description repository
                                  (default: ${HARDWARE_DESCRIPTIONS_BRANCH})
"

BUILD_FLAGS=()
while [[ $# -gt 0 ]]; do
  opt="$1"
  case $opt in
    --hardware) HARDWARE="$2" ; shift 2 ;;
    -r|--rebuild) BUILD_FLAGS+=(--no-cache) ; shift ;;
    -v|--verbose) BUILD_FLAGS+=(--progress=plain) ; shift ;;
    --description-branch) HARDWARE_DESCRIPTIONS_BRANCH="$2" ; shift 2 ;;
    -h|--help) echo "${HELP_MESSAGE}" ; exit 0 ;;
    *) echo 'Error in command line parsing' >&2
       echo -e "\n${HELP_MESSAGE}"
       exit 1
  esac
done

BUILD_FLAGS+=(--build-arg ROS_VERSION="${ROS_VERSION}")
if [[ "$OSTYPE" != "darwin"* ]]; then
  BUILD_FLAGS+=(--ssh default="${SSH_AUTH_SOCK}")
else
  BUILD_FLAGS+=(--ssh default="$HOME/.ssh/id_rsa")
fi
BUILD_FLAGS+=(--build-arg HARDWARE="${HARDWARE}")
BUILD_FLAGS+=(--build-arg HARDWARE_DESCRIPTIONS_BRANCH="${HARDWARE_DESCRIPTIONS_BRANCH}")
BUILD_FLAGS+=(-t "${IMAGE_NAME}:${IMAGE_TAG}")

docker pull ghcr.io/aica-technology/ros2-ws:"${ROS_VERSION}"
DOCKER_BUILDKIT=1 docker build "${BUILD_FLAGS[@]}" . || exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
aica-docker interactive "${IMAGE_NAME}" -u ros2 \
  --volume="${SCRIPT_DIR}":/home/ros2/ros2_ws/src/kuka_iiwa_description:rw