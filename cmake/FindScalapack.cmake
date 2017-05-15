###############################################################################
# Copyright (c) 2016 The University of Tokyo
# This software is released under the MIT License, see License.txt
###############################################################################

# please use scalapack-config.cmake
# Exists in ${SCALAPACK_INSTALL_DIR}/lib/cmake/scalapack-2.0.2/
#
# Variables:
#
# SCALAPACK_FOUND
# SCALAPACK_LIBRARIES
#
if(SCALAPACK_LIBRARIES)
  set(SCALAPACK_FOUND TRUE)
  RETURN()
endif()

find_file(_MKL_SCALAPACK_INCLUDE
  NAMES "mkl_scalapack.h"
  HINTS "$ENV{MKLROOT}/include"
  NO_SYSTEM_ENVIRONMENT_PATH
)
message(STATUS "MKL Scalapack FOUND")

if(_MKL_SCALAPACK_INCLUDE)
  find_library(_MKL_SCALAPACK_LP64
    NAMES mkl_scalapack_lp64
    HINTS $ENV{MKLROOT}/lib/intel64
  )
  find_library(_MKL_INTEL_LP64
    NAMES mkl_intel_lp64
    HINTS $ENV{MKLROOT}/lib/intel64
  )
  find_library(_MKL_INTEL_THREAD
    NAMES mkl_intel_thread
    HINTS $ENV{MKLROOT}/lib/intel64
  )
  find_library(_MKL_CORE
    NAMES mkl_core
    HINTS $ENV{MKLROOT}/lib/intel64
  )
  find_library(_MKL_BLACS_INTELMPI_LP64
    NAMES mkl_blacs_intelmpi_lp64
    HINTS $ENV{MKLROOT}/lib/intel64
  )
  set(SCALAPACK_LIBRARIES
    ${_MKL_SCALAPACK_LP64}
    ${_MKL_INTEL_LP64}
    ${_MKL_INTEL_THREAD}
    ${_MKL_CORE}
    ${_MKL_BLACS_INTELMPI_LP64}
    iomp5
    pthread
    m
    dl
    CACHE STRING "MKL ScaLAPACK")
else()
  find_library(SCALAPACK_LIBRARIES
    NAMES scalapack
    HINTS ${CMAKE_SOURCE_DIR}/../scalapack-2.0.2/build/lib
    $ENV{HOME}/metis-5.0.1/build/lib
    $ENV{HOME}/local/lib
    $ENV{HOME}/.local/lib
    ${CMAKE_LIBRARY_PATH}
    /usr/local/metis/lib
    /usr/local/lib
    /usr/lib
  )
endif()

if(SCALAPACK_LIBRARIES)
  message(STATUS "Found SCALAPACK")
  set(SCALAPACK_FOUND TRUE)
endif()