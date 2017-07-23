#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add cmake
module add gcc/${GCC_VERSION}
module add clhep/${CLHEP_VERSION}-gcc-${GCC_VERSION}

cd ${WORKSPACE}/${NAME}.${VERSION}/build-${BUILD_NUMBER}


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
module-whatis   "
[Category      ] physics
[Name           ] $NAME
[Version       ] $VERSION
[Description   ] Geant4 is a toolkit for the simulation of the passage of particles through matter. It used in particle, nuclear, accelerator, and medical physics, together with space science and right across science
[Website       ] http://${NAME}.4.cern.ch
[Compiler      ] gcc
[Dependencies  ] clhep ${CLHEP_VERSION}-gcc-${GCC_VERSION}
"
setenv       GEANT4_VERSION       $VERSION
setenv       GEANT4_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-clhep-${CLHEP_VERSION}-gcc-${GCC_VERSION}
setenv        GEANT4_DATA  $::env(GEANT4BASE)/data/
setenv  GEANT4BASE         /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/
setenv  G4INCLUDE                         $::env(GEANT4_DIR)/include/geant4
setenv  G4INSTALL                          $::env(GEANT4_DIR)/src/geant4
setenv  G4ABLADATA                      $::env(GEANT4_DATA)/G4ABLA3.0
setenv  G4LEDATA                            $::env(GEANT4_DATA)/G4EMLOW6.9
setenv  G4LEVELGAMMADATA      $::env(GEANT4_DATA)/PhotonEvaporation2.0
setenv  G4NEUTRONHPDATA         $::env(GEANT4_DATA)/G4NDL3.13
setenv  G4RADIOACTIVEDATA       $::env(GEANT4_DATA)/RadioactiveDecay3.2
setenv  G4REALSURFACEDATA     $::env(GEANT4_DATA)/RealSurface1.0
setenv  G4LIB_BUILD_SHARED      1
setenv  G4LIB_BUILD_STATIC        1
setenv  G4LIB           $::env(GEANT4_DIR)/lib/geant4
setenv  G4LIB_USE_GRANULAR        1
setenv  G4SYSTEM          Linux-g++
setenv  G4UI_USE_TCSH         1
setenv  G4VIS_BUILD_VRML_DRIVER       1
setenv  G4VIS_USE_VRML                1
setenv  G4WORKDIR                     $::env(HOME)/geant4
prepend-path  LD_LIBRARY_PATH     $::env(GEANT4_DIR)/lib/geant4/Linux-g++
prepend-path  PATH        $::env(HOME)/geant4/bin/Linux-g++
prepend-path  PATH         $::env(GEANT4_DIR)/bin
prepend-path CFLAGS            "-I${G4INCLUDE}"
prepend-path LDFLAGS           "-L${G4LIB}"
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}

echo "HEP/NAME is ${HEP}/${NAME}"
mkdir -p ${HEP}/${NAME}
cp -v modules/${VERSION}-gcc-${GCC_VERSION} ${HEP}/${NAME}
module avail ${NAME}
module add  ${NAME}/${VERSION}-gcc-${GCC_VERSION}
