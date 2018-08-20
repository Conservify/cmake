file(GLOB files ${ARDUINO_LIBRARIES_PATH}/SD/*.cpp)

add_arduino_library(SD ${files})

target_include_directories(SD
    PUBLIC ${ARDUINO_LIBRARIES_PATH}/SD
    PRIVATE ${ARDUINO_LIBRARIES_PATH}/SD
)
