if(TARGET u8g2)
  return()
endif()

add_external_arduino_library(u8g2)

find_package(SPI)
target_link_libraries(u8g2 SPI)

find_package(Wire)
target_link_libraries(u8g2 Wire)
