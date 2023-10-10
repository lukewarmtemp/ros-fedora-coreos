# How to Run the Native Container

Run Fedora CoreOS on your system: https://fedoraproject.org/coreos/download/?stream=stable


Check the details of your system:
```bash
$ rpm-ostree status

    fedora:fedora/x86_64/coreos/stable
                Version: 38.20230918.3.0 (2023-10-04T06:33:38Z)
                Commit: bc49c681f6c1f931db8547f7d18ee3b9fef5dc044ff475b0076d58a655479f90
                GPGSignature: Valid signature by 6A51BBABBA3D5467B6171221809A8D7CEB10B464
```

Rebase to the Fedora CoreOS + ROS2 container image
```bash
# On my VM and network connection, the rebase process takes around 6 minutes
$ sudo systemctl stop zincati.service
$ sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/lukewarmtemp/ros-fedora-coreos:latest
```

Reboot the system for the changes
```bash
$ sudo systemctl reboot
```

Verify that we have rebased our system to the container image
```bash
$ rpm-ostree status

    ostree-unverified-registry:ghcr.io/lukewarmtemp/ros-fedora-coreos:latest
                Digest: sha256:4e5fa0725a2ddfe7def557aa146ac460f2d043cc20931b3c67cbf66c591a95ac
                Version: 38.20230918.3.0 (2023-10-10T03:55:42Z)
```

Source the ROS2 setup file and run the demo `talker` node
```bash
$ . /etc/ros2/install/local_setup.bash
$ ros2 run demo_nodes_cpp talker
```

Source the ROS2 setup file and run the demo `listener` node
```
$ . /etc/ros2/install/local_setup.bash
$ ros2 run demo_nodes_cpp listener
```
