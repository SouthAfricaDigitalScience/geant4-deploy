#!/bin/bash -e
. /etc/profile.d/modules.sh

module add ci
module add cmake
module add clhep/${CLHEP_VERSION}

SOURCE_FILE=${NAME}.${VERSION}.tar.gz

echo "SOFT_DIR is : ${SOFT_DIR}"
mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget http://geant4.web.cern.ch/geant4/support/source/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
mkdir -p ${WORKSPACE}/geant${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/geant${VERSION}/build-${BUILD_NUMBER}
# This CMake doesn't allow in-source build
cmake ${WORKSPACE}/${VERSION} -G"Unix Makefiles" \
   -DCMAKE_INSTALL_PREFIX=${SOFT_DIR}\
   -DGEANT4_INSTALL_DATA_TIMEOUT=1500                \
   -DCMAKE_CXX_FLAGS="-fPIC"                         \
   -DCMAKE_INSTALL_LIBDIR="lib"     \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo    \
   -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"  \
   -DGEANT4_ENABLE_TESTING=OFF    \
   -DBUILD_SHARED_LIBS=ON    \
   -DGEANT4_INSTALL_EXAMPLES=OFF   \
   -DCLHEP_ROOT_DIR:PATH="$CLHEP_ROOT"  \
   -DGEANT4_BUILD_MULTITHREADED=OFF  \
   -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC"  \
   -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC"  \
   -DGEANT4_USE_G3TOG4=ON   \
   -DGEANT4_INSTALL_DATA=ON   \
   -DGEANT4_USE_SYSTEM_EXPAT=OFF

make
