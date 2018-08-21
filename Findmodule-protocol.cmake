if (TARGET module-protocol)
  return()
endif()

find_package(nanopb)

add_external_arduino_library(module-protocol)

target_link_libraries(module-protocol nanopb)
