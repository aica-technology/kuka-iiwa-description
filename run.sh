#!/bin/bash

# This script is for internal development purposes, and does
# not run for the general public due to the fact that the
# image 'aica-technology/hardware-descriptions is not public.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
aica-docker interactive aica-technology/hardware-descriptions:latest -u ros2 \
  --volume="${SCRIPT_DIR}":/home/ros2/ros2_ws/src/kuka_iiwa_description:rw
