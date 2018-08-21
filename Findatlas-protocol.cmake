if (TARGET atlas-protocol)
  return()
endif()

find_package(nanopb)

add_external_arduino_library(atlas-protocol)

target_link_libraries(atlas-protocol nanopb)
