if (TARGET phylum)
  return()
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake)

set(phylum_RECURSE True)

add_external_arduino_library(phylum)

find_package(SPI)
find_package(arduino-logging)
find_package(SerialFlash)

target_link_libraries(phylum SPI)
target_link_libraries(phylum arduino-logging)
target_link_libraries(phylum SerialFlash)

target_include_directories(phylum
    PUBLIC ${phylum_PATH}/src
    PRIVATE ${phylum_PATH}/src
)
