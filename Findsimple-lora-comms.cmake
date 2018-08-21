if (TARGET simple-lora-comms)
  return()
endif()

find_package(arduino-logging)
find_package(nanopb)
find_package(lwstreams)
find_package(RadioHead)

add_external_arduino_library(simple-lora-comms)

target_link_libraries(simple-lora-comms arduino-logging)
target_link_libraries(simple-lora-comms nanopb)
target_link_libraries(simple-lora-comms lwstreams)
target_link_libraries(simple-lora-comms RadioHead)
