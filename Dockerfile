ARG ROS_VERSION=galactic
FROM ghcr.io/aica-technology/ros2-ws:${ROS_VERSION}

RUN sudo apt-get update && sudo apt-get install -y ros-${ROS_DISTRO}-joint-state-publisher-gui

# install desired hardware descriptions
ENV HARDWARE_WORKSPACE=${HOME}/ros2_ws
ARG HARDWARE=""
ARG HARDWARE_DESCRIPTIONS_BRANCH=develop
USER root
RUN --mount=type=ssh git clone -b ${HARDWARE_DESCRIPTIONS_BRANCH} --depth 1 \
  git@github.com:aica-technology/hardware-descriptions.git /tmp/hardware-descriptions
WORKDIR /tmp/hardware-descriptions/
RUN --mount=type=ssh ./scripts/install_descriptions.sh -d ${HARDWARE_WORKSPACE}/src ${HARDWARE}
# change ownership of the installed packages
RUN chown -R ${USER}:${USER} ${HARDWARE_WORKSPACE}/src
RUN rm -rf /tmp/hardware-descriptions
USER ${USER}

WORKDIR ${HOME}/ros2_ws
COPY ./ ./src/kuka_iiwa_description

RUN /bin/bash -c "source ${HOME}/ros2_ws/install/setup.bash; colcon build --symlink-install"