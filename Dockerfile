FROM ubuntu:14.04

MAINTAINER Dmitriy Belyaev "dimabelyaev27@gmail.com"

RUN echo "deb-src http://httpredir.debian.org/debian unstable main" >> /etc/apt/sources.list && \
    apt-get update && apt-get -y install curl cmake g++ unzip python python-dev python-pip pkg-config \
    libssl-dev libpng-dev libjpeg8-dev libfreetype6-dev liblapack-dev gfortran

RUN pip install numpy && pip install cython && pip install scikit-image flask flask_api

ENV PYTHON2_NUMPY_INCLUDE_DIRS="/usr/lib/python2.7/dist-packages/numpy/core/include" \
    PYTHON_LIBRARY="/usr/lib/x86_64-linux-gnu/libpython2.7.so" \
    PYTHON_INCLUDE_DIR2="/usr/include/x86_64-linux-gnu/python2.7" \
    PYTHON_INCLUDE_DIR="/usr/include/python2.7" \
    PYTHON2_EXECUTABLE="/usr/bin/python"

RUN mkdir -p /tmp/opencv && cd /tmp/opencv && curl -O http://netcologne.dl.sourceforge.net/project/libjpeg-turbo/1.5.0/libjpeg-turbo-official_1.5.0_amd64.deb && \
    dpkg -i libjpeg-turbo-official_1.5.0_amd64.deb && \
    curl -O https://codeload.github.com/Itseez/opencv/zip/2.4.12 && unzip 2.4.12 && mkdir opencv-2.4.12/build && cd opencv-2.4.12/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_JPEG=ON -D BUILD_JPEG=OFF -D JPEG_INCLUDE_DIR=/opt/libjpeg-turbo/include/ -D JPEG_LIBRARY=/opt/libjpeg-turbo/lib64/libjpeg.a .. && \
    make && make install && pkg-config --cflags opencv && pkg-config --libs opencv && rm -rf /tmp/opencv

COPY . /var/app

ENV SCANNER_ADDITIONAL_CONFIG="/var/app/production.py"

WORKDIR /var/app

CMD python web.py

EXPOSE 5000
