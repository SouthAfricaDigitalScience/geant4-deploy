#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add cmake
module add clhep/${CLHEP_VERSION}

cd ${WORKSPACE}/${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf *
cmake ${WORKSPACE}/${VERSION}/$(echo ${NAME}| tr '[:lower:]' '[:upper:]') -G"Unix Makefiles" \
   -DCMAKE_INSTALL_PREFIX=${SOFT_DIR}\ 
   -DGEANT4_INSTALL_DATA_TIMEOUT=1500                \
   -DCMAKE_CXX_FLAGS="-fPIC"                         \
   -DCMAKE_INSTALL_LIBDIR="lib"   \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo  \
   -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"  \
   -DGEANT4_ENABLE_TESTING=OFF  \
   -DBUILD_SHARED_LIBS=ON  \
   -DGEANT4_INSTALL_EXAMPLES=OFF  \
   -DCLHEP_ROOT_DIR:PATH="$CLHEP_ROOT"  \
   -DGEANT4_BUILD_MULTITHREADED=OFF  \
   -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC"  \
   -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC"  \
   -DGEANT4_USE_G3TOG4=ON  \
   -DGEANT4_INSTALL_DATA=ON  \
   -DGEANT4_USE_SYSTEM_EXPAT=OFF
  
make -j2 install

echo "Creating the modules file directory ${HEP_MODULES}"

mkdir -p ${HEP_MODULES}/${NAME}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/geant4-deploy"
setenv GEANT4_VERSION       $VERSION
setenv GEANT4_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(GEANT4_DIR)/lib
prepend-path CFLAGS            "-I$::env(GEANT4_DIR)/include"
prepend-path LDFLAGS           "-L::env(GEANT4_DIR)/lib"
prepend-path PATH              $::env(GEANT4_DIR)/bin
MODULE_FILE
) > modules/$VERSION

cp -v modules/$VERSION ${HEP_MODULES}/${NAME}


module add ${NAME}/${VERSION}
which geant4-config
