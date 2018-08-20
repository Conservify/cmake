if (TARGET WiFi101)
  return()
endif()

add_external_arduino_library(WiFi101)

find_package(SPI)

target_link_libraries(WiFi101 SPI)
