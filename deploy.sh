#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add cmake
module add gcc/${GCC_VERSION}
module add clhep/${CLHEP_VERSION}-gcc-${GCC_VERSION}

cd ${WORKSPACE}/${NAME}.${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf *
cmake ${WORKSPACE}/${NAME}.${VERSION}/ -G"Unix Makefiles" \
   -DCMAKE_INSTALL_PREFIX=${SOFT_DIR}-clhep-${CLHEP_VERSION}-gcc-${GCC_VERSION}\
   -DGEANT4_INSTALL_DATA_TIMEOUT=1500                \
   -DCMAKE_CXX_FLAGS="-fPIC"                         \
   -DCMAKE_INSTALL_LIBDIR="lib"   \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo  \
   -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"  \
   -DBUILD_SHARED_LIBS=ON  \
   -DGEANT4_INSTALL_EXAMPLES=OFF  \
   -DCLHEP_ROOT_DIR:PATH="$CLHEP_ROOT"  \
   -DGEANT4_BUILD_MULTITHREADED=OFF  \
   -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC"  \
   -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC"  \
   -DGEANT4_USE_G3TOG4=ON  \
   -DGEANT4_INSTALL_DATA=ON  \
   -DGEANT4_USE_SYSTEM_EXPAT=OFF

make install

echo "Creating the modules file directory ${HEP}"

mkdir -p ${HEP}/${NAME}
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

#module-whatis   "
#[Category      ] physics
#[Nam           ] $NAME
#[Version       ] $VERSION
#[Description   ] Geant4 is a toolkit for the simulation of the passage of particles through matter. It used in particle, nuclear, accelerator, and medical physics, together with space science and right across science
#[Website       ] http://geant4.cern.ch
#[Compiler      ] gcc
#[Dependencies  ] clhep ${CLHEP_VERSION}
#$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/geant4-deploy
#"
setenv       GEANT4_VERSION       $VERSION
setenv       GEANT4_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
setenv  GEANT4BASE                $::env(GEANT4_DIR)
setenv  G4INCLUDE               $::env(GEANT4BASE)/include/geant4
setenv  G4INSTALL           $::env(GEANT4BASE)/src/geant4
setenv  G4ABLADATA                  $::env(GEANT4BASE)/data/G4ABLA3.0
setenv  G4LEDATA          $::env(GEANT4BASE)/data/G4EMLOW6.9
setenv  G4LEVELGAMMADATA        $::env(GEANT4BASE)/data/PhotonEvaporation2.0
setenv  G4NEUTRONHPDATA         $::env(GEANT4BASE)/data/G4NDL3.13
setenv  G4RADIOACTIVEDATA         $::env(GEANT4BASE)/data/RadioactiveDecay3.2
setenv  G4REALSURFACEDATA         $::env(GEANT4BASE)/data/RealSurface1.0
setenv  G4LIB_BUILD_SHARED        1
setenv  G4LIB_BUILD_STATIC        1
setenv  G4LIB           $::env(GEANT4BASE)/lib/geant4
setenv  G4LIB_USE_GRANULAR        1
setenv  G4SYSTEM          Linux-g++
setenv  G4UI_USE_TCSH         1
setenv  G4VIS_BUILD_VRML_DRIVER       1
setenv  G4VIS_USE_VRML                1
setenv  G4WORKDIR                     $::env(HOME)/geant4
prepend-path  LD_LIBRARY_PATH     $::env(GEANT4BASE)/lib/geant4/Linux-g++
prepend-path  PATH        $::env(HOME)/geant4/bin/Linux-g++

prepend-path CFLAGS            "-I${G4INCLUDE}"
prepend-path LDFLAGS           "-L${G4LIB}"
MODULE_FILE
) > modules/$VERSION

echo "HEP/NAME is ${HEP}/${NAME}"
mkdir -p ${HEP}/${NAME}
cp -v modules/$VERSION ${HEP}/${NAME}
module avail ${NAME}
module add  ${NAME}/${VERSION}
which geant4-config
