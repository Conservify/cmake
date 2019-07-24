if(TARGET lwcron)
  return()
endif()

set(lwcron_RECURSE True)

add_external_arduino_library(lwcron)
