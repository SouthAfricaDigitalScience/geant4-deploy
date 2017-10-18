#!/bin/bash -e
. /etc/profile.d/modules.sh

module add ci
module add cmake
module add gcc/${GCC_VERSION}
#module add clhep/${CLHEP_VERSION}-gcc-${GCC_VERSION}

SOURCE_FILE=${NAME}.${VERSION}.tar.gz
#geant4-10.3-release.zip from github
#VERSION on gitlab at CERN is v10.3.2/archive.tar.gz
#gitlab at CERN : https://gitlab.cern.ch/geant4/geant4/repository/v10.3.2/archive.tar.gz

echo "${SOFT_DIR}"
mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget https://gitlab.cern.ch/${NAME}/${NAME}/repository/${VERSION}/archive.tar.gz -O ${SRC_DIR}/${SOURCE_FILE}
#  wget http://geant4.web.cern.ch/geant4/support/source/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
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
#becase we are going to download the data files independently and use -DGEANT4_INSTALL_DATA=OFF ....
#lets check if the data already is here from a previous build or a previous install 
#if not lets get the data with some locking.

# geant4/cmake/Modules/Geant4DatasetDefinitions.cmake
# geant4/cmake/Modules/Geant4InstallData.cmake

tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
mkdir -p ${WORKSPACE}/${NAME}.${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/${NAME}.${VERSION}/build-${BUILD_NUMBER}
# This CMake doesn't allow in-source build
cmake ${WORKSPACE}/${NAME}.${VERSION}    -G"Unix Makefiles" \
 #  -DCMAKE_INSTALL_PREFIX=${SOFT_DIR}-clhep-${CLHEP_VERSION}-gcc-${GCC_VERSION} \
   -DCMAKE_INSTALL_PREFIX=${SOFT_DIR}-gcc-${GCC_VERSION} \
   -DGEANT4_INSTALL_DATA_TIMEOUT=1500                \
   -DCMAKE_CXX_FLAGS="-fPIC"                         \
   -DCMAKE_INSTALL_LIBDIR="lib"     \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo    \
   -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"  \
   -DGEANT4_ENABLE_TESTING=OFF    \
   -DBUILD_SHARED_LIBS=ON    \
   -DGEANT4_INSTALL_EXAMPLES=ON  \
   -DGEANT4_BUILD_MULTITHREADED=OFF  \
   -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC"  \
   -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC"  \
   -DGEANT4_USE_G3TOG4=ON   \
   -DGEANT4_INSTALL_DATA=OFF   \
   -DGEANT4_USE_SYSTEM_EXPAT=OFF \
   -DGEANT4_BUILD_TESTS=ON

make
