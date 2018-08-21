if (TARGET app-protocol)
  return()
endif()

find_package(nanopb)

add_external_arduino_library(app-protocol)

target_link_libraries(app-protocol nanopb)
