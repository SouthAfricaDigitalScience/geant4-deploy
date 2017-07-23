[![Build Status](https://ci.sagrid.ac.za/job/geant4-deploy/badge/icon)](https://ci.sagrid.ac.za/job/geant4-deploy)

# geant4-deploy

Build scripts and tests for the [Geant4](https://geant4.cern.ch/) for CODE-RADE

# Dependencies

This project depends on

  * cmake
  * gcc
  * clhep


# Versions

We build the following versions :

  * 10.3.0
  * 10.1.3

# Configuration

The builds are configured out-of-source with cmake :

```
cmake ${WORKSPACE}/${NAME}.${VERSION}    -G"Unix Makefiles" \
  -DGEANT4_INSTALL_DATADIR=${SOFT_DIR}/data \
   -DCMAKE_INSTALL_PREFIX=${SOFT_DIR}-clhep-${CLHEP_VERSION}-gcc-${GCC_VERSION} \
   -DGEANT4_INSTALL_DATA_TIMEOUT=1500                \
   -DCMAKE_CXX_FLAGS="-fPIC"                         \
   -DCMAKE_INSTALL_LIBDIR="lib"     \
   -DCMAKE_BUILD_TYPE=RelWithDebInfo    \
   -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"  \
   -DGEANT4_ENABLE_TESTING=OFF    \
   -DBUILD_SHARED_LIBS=ON    \
   -DGEANT4_INSTALL_EXAMPLES=ON  \
   -DCLHEP_ROOT_DIR:PATH="${CLHEP_ROOT}"  \
   -DGEANT4_BUILD_MULTITHREADED=OFF  \
   -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC"  \
   -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC"  \
   -DGEANT4_USE_G3TOG4=ON   \
   -DGEANT4_INSTALL_DATA=ON   \
   -DGEANT4_USE_SYSTEM_EXPAT=OFF \
   -DGEANT4_BUILD_TESTS=ON
   ```

# Citing
