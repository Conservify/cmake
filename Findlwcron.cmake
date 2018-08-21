if (TARGET lwcron)
  return()
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake)

set(lwcron_RECURSE True)

add_external_arduino_library(lwcron)
