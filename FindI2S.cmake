file(GLOB files ${ARDUINO_BOARD_CORE_LIBRARIES_PATH}/I2S/*.cpp)

add_arduino_library(I2S ${files})

target_include_directories(I2S
    PUBLIC ${ARDUINO_BOARD_CORE_LIBRARIES_PATH}/I2S
    PRIVATE ${ARDUINO_BOARD_CORE_LIBRARIES_PATH}/I2S
)
