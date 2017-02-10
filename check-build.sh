#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add cmake
module add clhep/${CLHEP_VERSION}
cd ${WORKSPACE}/${VERSION}/build-${BUILD_NUMBER}
make test

echo $?


echo "--------------------- begin ci deployed env to see if things are set ----"
env
echo "--------------------- end ci deployed env to see if things are set ----"
echo "bump git to get a new build"

echo "Making install"
make install
echo "Making module"
mkdir -vp modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module-whatis   "$NAME $VERSION."
setenv       CLHEP_VERSION       $VERSION
setenv       CLHEP_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(CLHEP_DIR)/lib
prepend-path CFLAGS            "-I${CLHEP_DIR}/include"
prepend-path LDFLAGS           "-L${CLHEP_DIR}/lib"
prepend-path PATH              $::env(CLHEP_DIR)/bin
MODULE_FILE
) > modules/$VERSION

echo "HEP_MODULES/NAME is ${HEP_MODULES}/${NAME}"
mkdir -p ${HEP_MODULES}/${NAME}
cp -v modules/$VERSION ${HEP_MODULES}/${NAME}
module avail ${NAME}
module add  ${NAME}/${VERSION}
