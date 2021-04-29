#!/bin/bash

sudo apt update
sudo apt upgrade -y

# Generic tools
sudo apt install build-essential cmake pkg-config unzip yasm git checkinstall qt5-default -y
# Image I/O libs
sudo apt install libjpeg-dev libpng-dev libtiff-dev -y
# Compiler
sudo apt install gcc-6 g++-6 -y

# Video/Audio Libs - FFMPEG, GSTREAMER, x264 and so on.
sudo apt install libavcodec-dev libavformat-dev libswscale-dev libavresample-dev -y
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-base1.0-dev -y 
sudo apt install libxvidcore-dev x264 libx264-dev libfaac-dev libmp3lame-dev libtheora-dev  -y
sudo apt install libfaac-dev libmp3lame-dev libvorbis-dev -y

# OpenCore - Adaptive Multi Rate Narrow Band (AMRNB) and Wide Band (AMRWB) speech codec
sudo apt install libopencore-amrnb-dev libopencore-amrwb-dev -y

# Cameras programming interface libs
sudo apt-get install libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils -y
cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd ~

# GTK lib for the graphical user functionalites coming from OpenCV highghui module
sudo apt-get install libgtk-3-dev -y

# Parallelism library C++ for CPU
sudo apt-get install libtbb-dev -y

# Optimization libraries for OpenCV
sudo apt-get install libatlas-base-dev gfortran -y

# Optional libraries
sudo apt-get install libprotobuf-dev protobuf-compiler -y
sudo apt-get install libgoogle-glog-dev libgflags-dev -y
sudo apt-get install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen -y

# Proceed with the installation
cd ~
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.1.1.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.1.1.zip
unzip opencv.zip
unzip opencv_contrib.zip

echo "Procced with the installation"
cd opencv-4.1.1
mkdir build
cd build

time cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D CMAKE_C_COMPILER=/usr/bin/gcc-6 \
      -D INSTALL_C_EXAMPLES=OFF \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D WITH_CUDA=ON \
      -D WITH_CUDNN=ON \
      -D CUDNN_LIBRARY=/usr/lib/x86_64-linux-gnu/libcudnn.so \
      -D CUDNN_INCLUDE_DIR=/usr/local/cuda/include \
      -D CUDA_ARCH_BIN=7.5 \
      -D CUDA_FAST_MATH=ON \
      -D WITH_OPENGL=ON \
      -D CUDA_ARCH_PTX="" \
      -D ENABLE_FAST_MATH=ON \
      -D CUDA_FAST_MATH=ON \
      -D WITH_CUBLAS=ON \
      -D WITH_LIBV4L=ON \
      -D WITH_V4L=ON \
      -D WITH_GSTREAMER=ON \
      -D WITH_GSTREAMER_0_10=OFF \
      -D OPENCV_DNN_CUDA=ON \
      -D WITH_QT=ON \
      -D WITH_TBB=ON \
      -D BUILD_opencv_python3=ON \
      -D BUILD_TESTS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D OPENCV_PC_FILE_NAME=opencv.pc \
      -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.1.1/modules \
      -D CUDA_nppi_LIBRARY=true \
      -D CPACK_BINARY_DEB=ON \
      ../

# If it is fine proceed with the compilation (Use nproc to know the number of cpu cores):
make -j$(nproc)
sudo make install

# Include the libs in your environment
sudo /bin/bash -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig

# Install opencv core packages
sudo apt-get install -y libopencv-dev libopencv-core-dev

# Check version
python3 -c "import cv2 ; print(cv2.__version__)"
