echo "Please be patient as the initial setup for the simulator is completed."
sudo apt-get remove modemmanager
sudo apt install python3-pip
sudo apt install libgstreamer1.0-dev
sudo apt install gstreamer1.0-plugins-good
sudo apt install gstreamer1.0-plugins-bad
sudo apt install gstreamer1.0-plugins-ugly
sudo python3 pip 
sudo apt install python3-empy
sudo apt install python3-numpy
sudo apt install python3-toml
sudo apt install python3-packaging
sudo apt install python3-jinja2

git clone https://github.com/PX4/Firmware.git --recursive
cd Firmware
bash ./Tools/setup/ubuntu.sh
cd
sudo apt-get update -y
sudo apt-get install git zip qtcreator cmake \
    build-essential genromfs ninja-build exiftool -y

# Install xxd (package depends on version)
which xxd || sudo apt install xxd -y || sudo apt-get install vim-common --no-install-recommends -y

# Required python packages
sudo apt-get install python-argparse \
    python-empy python-toml python-numpy python-yaml \
    python-dev python-pip -y
sudo -H pip install --upgrade pip 
sudo -H pip install pandas jinja2 pyserial cerberus
sudo -H pip install pyulog

#Build Ninja for Gazebo SITL support
sudo apt-get install ninja-build -y
mkdir -p $HOME/ninja
cd $HOME/ninja
wget https://github.com/martine/ninja/releases/download/v1.6.0/ninja-linux.zip
unzip ninja-linux.zip
rm ninja-linux.zip
exportline="export PATH=$HOME/ninja:\$PATH"
if grep -Fxq "$exportline" ~/.profile; then echo nothing to do ; else echo $exportline >> ~/.profile; fi
. ~/.profile

cd
cpucores=$(( $(lscpu | grep Core.*per.*socket | awk -F: '{print $2}') * $(lscpu | grep Socket\(s\) | awk -F: '{print $2}') ))
popd
wget https://www.eprosima.com/index.php/component/ars/repository/eprosima-fast-rtps/eprosima-fast-rtps-1-7-1/eprosima_fastrtps-1-7-1-linux-tar-gz -O eprosima_fastrtps-1-7-1-linux.tar.gz
tar -xzf eprosima_fastrtps-1-7-1-linux.tar.gz eProsima_FastRTPS-1.7.1-Linux/
tar -xzf eprosima_fastrtps-1-7-1-linux.tar.gz requiredcomponents
tar -xzf requiredcomponents/eProsima_FastCDR-1.0.8-Linux.tar.gz 
wait
cd
cd eProsima_FastCDR-1.0.8-Linux && ./configure --libdir=/usr/lib && make -j2 && sudo make install
cd eProsima_FastRTPS-1.7.1-Linux && ./configure --libdir=/usr/lib && make -j2 && sudo make install
rm -rf requiredcomponents eprosima_fastrtps-1-7-1-linux.tar.gz
wait
cd 
sudo apt-get install protobuf-compiler libeigen3-dev libopencv-dev -y
sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
## Setup keys
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install gazebo9 -y
sudo apt-get install libgazebo9-dev -y
sudo apt-get install protobuf-compiler libeigen3-dev libopencv-dev -y
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -
sudo apt update
sudo apt install ros-melodic-desktop-full
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc
sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
sudo rosdep init
rosdep update
## Setup environment variables
rossource="source /opt/ros/melodic/setup.bash"
if grep -Fxq "$rossource" ~/.bashrc; then echo ROS setup.bash already in .bashrc;
else echo "$rossource" >> ~/.bashrc; fi
eval $rossource
## Install rosinstall and other dependencies
sudo apt install python-rosinstall build-essential -y
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws

## Install dependencies
sudo apt-get install python-wstool python-rosinstall-generator python-catkin-tools -y

## Initialise wstool
wstool init ~/catkin_ws/src

## Build MAVROS
### Get source (upstream - released)
rosinstall_generator --upstream mavros | tee /tmp/mavros.rosinstall
### Get latest released mavlink package
rosinstall_generator mavlink | tee -a /tmp/mavros.rosinstall
### Setup workspace & install deps
wstool merge -t src /tmp/mavros.rosinstall
wstool update -t src
rosdep install --from-paths src --ignore-src --rosdistro melodic -y
rosdep install --from-paths src --ignore-src --rosdistro melodic -y --os ubuntu:bionic
catkin build
## Re-source environment to reflect new packages/build environment
catkin_ws_source="source ~/catkin_ws/devel/setup.bash"
if grep -Fxq "$catkin_ws_source" ~/.bashrc; then echo ROS catkin_ws setup.bash already in .bashrc;
else echo "$catkin_ws_source" >> ~/.bashrc; fi
source ~/.bashrc
sudo su
pip3 install --user pyros-genmsg

# cd PX4-SITL-SIM
# chmod +x startfixedwing.sh 
# chmod +x startmulticopter.sh 
# chmod +x startvtol.sh 
# cd multiplevehicle
# echo "The next steps will allow the use of multiple-vehcile simulations"
# echo "Before we begin, I need to know the name of your linux home directory profile. For example home/directoryname/. Please input the name below." 
# read varname
# cp -r iris_3.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r iris_4.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r iris_5.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r iris_6.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r iris_7.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r iris_8.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r iris_9.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r iris_10.sh /home/$varname/Firmware/ROMFS/px4fmu_common/init.d-posix
# cp -r multi_uav_mavros_sitl3.launch /home/$varname/Firmware/launch
# cp -r multi_uav_mavros_sitl4.launch /home/$varname/Firmware/launch
# cp -r multi_uav_mavros_sitl5.launch /home/$varname/Firmware/launch
# cp -r multi_uav_mavros_sitl6.launch /home/$varname/Firmware/launch
# cp -r multi_uav_mavros_sitl7.launch /home/$varname/Firmware/launch
# cp -r multi_uav_mavros_sitl8.launch /home/$varname/Firmware/launch
# cp -r multi_uav_mavros_sitl9.launch /home/$varname/Firmware/launch
# cp -r multi_uav_mavros_sitl10.launch /home/$varname/Firmware/launch
# echo "The setup is now completed."
# echo "Please restart your computer to complete the installation."
