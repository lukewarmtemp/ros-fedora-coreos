FROM quay.io/fedora/fedora-coreos:stable

ARG ROS_VERSION=rolling

ENV LANG=en_US.UTF-8
ENV RPM_ARCH=x86_64
ENV ROS_PYTHON_VERSION=3

RUN rpm-ostree install dnf

RUN sudo dnf install -y \
  cmake \
  cppcheck \
  eigen3-devel \
  gcc-c++ \
  liblsan \
  libXaw-devel \
  libyaml-devel \
  make \
  opencv-devel \
  patch \
  python3-colcon-common-extensions \
  python3-coverage \
  python3-devel \
  python3-empy \
  python3-nose \
  python3-pip \
  python3-pydocstyle \
  python3-pyparsing \
  python3-pytest \
  python3-pytest-cov \
  python3-pytest-mock \
  python3-pytest-runner \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  poco-devel \
  poco-foundation \
  python3-flake8 \
  python3-flake8-import-order \
  redhat-rpm-config \
  uncrustify \
  wget

RUN python3 -m pip install -U --user \
  flake8-blind-except==0.1.1 \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  mypy==0.931

WORKDIR /etc
RUN mkdir -p /etc/ros2/src
WORKDIR /etc/ros2
RUN vcs import --input https://raw.githubusercontent.com/ros2/ros2/${ROS_VERSION}/ros2.repos src

RUN sudo dnf update -y

RUN sudo rosdep init
RUN rosdep update
RUN rosdep install --from-paths src --ignore-src -y --skip-keys "asio cyclonedds fastcdr fastrtps ignition-cmake2 ignition-math6 python3-babeltrace python3-mypy rti-connext-dds-6.0.1 urdfdom_headers"

# TODO: temporary workaround, remove once those packages can be built
RUN touch ./src/ros-visualization/rqt/rqt_gui_cpp/CATKIN_IGNORE && \
touch ./src/ros-visualization/qt_gui_core/qt_gui_app/CATKIN_IGNORE && \
touch ./src/ros-visualization/qt_gui_core/qt_gui_cpp/CATKIN_IGNORE

WORKDIR /etc/ros2
RUN sed -i '1s/^/#include <stdint.h> /' /etc/ros2/src/ros2/rcpputils/include/rcpputils/filesystem_helper.hpp
RUN sed -i '1s/^/#include <stdint.h> /' /etc/ros2/src/ros-tooling/libstatistics_collector/include/libstatistics_collector/moving_average_statistics/types.hpp
RUN sed -i '1s/^/#include <stdexcept> /' /etc/ros2/src/ros2/rclcpp/rclcpp/include/rclcpp/context.hpp
RUN sed -i '1s/^/#include <stdexcept> /' /etc/ros2/src/ros2/rclcpp/rclcpp/src/rclcpp/logging_mutex.cpp
RUN sed -i '1s/^/#include <stdint.h> /' /etc/ros2/src/ros2/rosbag2/rosbag2_compression/include/rosbag2_compression/compression_options.hpp

RUN rm -R /etc/ros2/src/ros2/rviz/
WORKDIR /etc/ros2/src/ros2/
RUN git clone -b humble https://github.com/ros2/rviz.git

WORKDIR /etc/ros2
RUN test -f /usr/bin/ld || ln -s /usr/bin/ld.bfd /usr/bin/ld

RUN colcon build --symlink-install --cmake-args -DTHIRDPARTY_Asio=ON --no-warn-unused-cli

RUN rm -rf /var/roothome
RUN rm -rf /var/lib/unbound
RUN rm -rf /var/lib/dnf
RUN rm -rf /var/lib/texmf
RUN rm -rf /var/log
RUN rm -rf /var/lib/selinux
RUN rm -rf /var/lib/sss
RUN rm -rf /var/lib/alternatives
RUN rm -rf /var/lib/rpm
RUN rm -rf /var/lib/systemd
RUN rm -rf /var/lib/vagrant
RUN rm -rf /var/lock
RUN rm -rf /var/mail
RUN rm -rf /var/run

RUN ostree container commit
