if (TARGET Adafruit_SPIFlash)
  return()
endif()

add_external_arduino_library(Adafruit_SPIFlash)

find_package(SPI)

target_link_libraries(Adafruit_SPIFlash SPI)
