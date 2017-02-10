[![Build Status](https://ci.sagrid.ac.za/job/geant4-deploy/badge/icon)](https://ci.sagrid.ac.za/job/geant4-deploy)

# clhep-deploy

Build scripts and tests for the [Geant4](https://geant4.cern.ch/) for CODE-RADE

# Dependencies

This project depends on

  * cmake
  * gcc
  * clhep
  

# Versions

We build the following versions :

  * 10.3.0

# Configuration

The builds are configured out-of-source with cmake :

```
cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${SOFT_DIR}
```

# Citing
