#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add cmake
module add clhep/${CLHEP_VERSION}

cd ${WORKSPACE}/geant${VERSION}/build-${BUILD_NUMBER}
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
module-whatis   "
[Category      ] physics
[Nam           ] $NAME
[Version       ] $VERSION
[Description   ] Geant4 is a toolkit for the simulation of the passage of particles through matter. It used in particle, nuclear, accelerator, and medical physics, together with space science and right across science
[Website       ] http://geant4.cern.ch
[Compiler      ] gcc
[Dependencies  ] clhep ${CLHEP_VERSION}
"
setenv       GEANT4_VERSION       $VERSION
setenv       GEANT4_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
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

echo "HEP_MODULES/NAME is ${HEP_MODULES}/${NAME}"
mkdir -p ${HEP_MODULES}/${NAME}
cp -v modules/$VERSION ${HEP_MODULES}/${NAME}
module avail ${NAME}
module add  ${NAME}/${VERSION}
