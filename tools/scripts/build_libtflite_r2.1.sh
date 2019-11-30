#!/bin/sh
set -e
#set -x

export TENSORFLOW_VER=r2.1
export TENSORFLOW_DIR=`pwd`/tensorflow_${TENSORFLOW_VER}

git clone https://github.com/tensorflow/tensorflow.git ${TENSORFLOW_DIR}

cd ${TENSORFLOW_DIR}
git checkout ${TENSORFLOW_VER}

echo "----------------------------------------------------"
echo " (configure) press ENTER-KEY several times.         "
echo "----------------------------------------------------"
./configure

# clean up bazel cache, just in case.
bazel clean

# download all the build dependencies.
./tensorflow/lite/tools/make/download_dependencies.sh 2>&1 | tee -a log_download_dependencies.txt

# build TensorFlow Lite library (libtensorflow-lite.a)
make -j 4  -f ./tensorflow/lite/tools/make/Makefile BUILD_WITH_NNAPI=false 2>&1 | tee -a log_build_libtflite.txt

# build GPU Delegate library (libdelegate.a)
bazel build -s -c opt --copt="-DMESA_EGL_NO_X11_HEADERS" tensorflow/lite/delegates/gpu:delegate 2>&1 | tee -a log_build_delegate.txt



echo "----------------------------------------------------"
echo " build success."
echo "----------------------------------------------------"

cd ${TENSORFLOW_DIR}
ls -l tensorflow/lite/tools/make/gen/linux_x86_64/lib/
ls -l bazel-bin/tensorflow/lite/delegates/gpu/



