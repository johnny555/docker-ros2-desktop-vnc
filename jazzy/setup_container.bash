#!/bin/bash

source /opt/ros/jazzy/local_setup.bash

# Create user ros, and allow it to install stuff. 
adduser --disabled-password --gecos "docker user" ubuntu
echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu && chmod 0440 /etc/sudoers.d/ubuntu
chown -R ubuntu /home/ubuntu/start_creating_robots2

# Get FreeCAD 
sudo --user=ubuntu wget -O /home/ubuntu/FreeCAD.AppImage https://github.com/FreeCAD/FreeCAD-Bundle/releases/download/weekly-builds/FreeCAD_weekly-builds-38419-conda-Linux-x86_64-py311.AppImage
sudo chmod +x /home/ubuntu/FreeCAD.AppImage 

# Setup FreeCAD Cross For FreeCAD
sudo --user=ubuntu mkdir -p /home/ubuntu/.local/share/FreeCAD/Mod/
sudo --user=ubuntu git clone https://github.com/johnny555/freecad.cross.git /home/ubuntu/.local/share/FreeCAD/Mod/freecad.cross

# Get python deps
sudo --user=ubuntu pip install black urdf-parser-py

# clean up apt
#     
su ubuntu

cd /home/ubuntu/
git clone https://github.com/johnny555/start_creating_robots2.git
cd /home/ubuntu/start_creating_robots2/src

# Get bugfix for resource spawner
git clone https://github.com/gazebosim/gz-fuel-tools.git
git clone https://github.com/gazebosim/gz-sim.git

cd /home/ubuntu/start_creating_robots2
source /opt/ros/jazzy/setup.bash

# install build deps and build
sudo apt update
rosdep install --from-path src --ignore-src -y -r 
colcon build --symlink-install --merge-install

sudo rm -rf /var/lib/apt/lists/*

# Make it so that sourcing happens automatically
echo "source /opt/ros/jazzy/setup.bash" >> /home/ubuntu/.bashrc
echo "source /home/ubuntu/start_creating_robots2/install/setup.bash" >> /home/ubuntu/.bashrc

# Suppress deprecated setuptools warning
echo "PYTHONWARNINGS=\"ignore:setup.py install is deprecated::setuptools.command.install,ignore:easy_install command is deprecated::setuptools.command.easy_install\"; export PYTHONWARNINGS" >> /home/ubuntu/.bashrc

# Add GAZEBO path so we can easily include models. Must use merge install. 
# Sholud be able to use package:// syntax now. 
echo "export GZ_SIM_RESOURCE_PATH=/home/ubuntu/start_creating_robots2/install/share/:/opt/ros/jazzy/share/" >> /home/ubuntu/.bashrc
echo "export SDF_PATH=/home/ubuntu/start_creating_robots2/install/share/:/opt/ros/jazzy/share/" >> /home/ubuntu/.bashrc