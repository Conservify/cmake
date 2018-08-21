if (TARGET lwstreams)
  return()
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake)

set(lwstreams_RECURSE True)

add_external_arduino_library(lwstreams)
