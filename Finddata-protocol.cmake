if (TARGET data-protocol)
  return()
endif()

find_package(nanopb)

add_external_arduino_library(data-protocol)

target_link_libraries(data-protocol nanopb)
