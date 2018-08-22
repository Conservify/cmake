if (TARGET SD)
  return()
endif()

file(GLOB files ${ARDUINO_LIBRARIES_PATH}/SD/src/*.cpp)

add_arduino_library(SD "${files}")

target_include_directories(SD
    PUBLIC ${ARDUINO_LIBRARIES_PATH}/SD/src
    PRIVATE ${ARDUINO_LIBRARIES_PATH}/SD/src
)
