if (TARGET WiFi101)
  return()
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake)

set(WiFi101_RECURSE True)

add_external_arduino_library(WiFi101)

find_package(SPI)

target_include_directories(WiFi101
    PUBLIC ${WiFi101_PATH}/src/utility
    PRIVATE ${WiFi101_PATH}/src/utility
)

target_link_libraries(WiFi101 SPI)
