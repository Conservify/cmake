# Get the current working branch
execute_process(
  COMMAND git rev-parse --abbrev-ref HEAD
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE GIT_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the latest abbreviated commit hash of the working branch
execute_process(
  COMMAND git log -1 --format=%H
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

add_definitions("-DFIRMWARE_GIT_HASH=\"${GIT_COMMIT_HASH}\"")
add_definitions("-DFIRMWARE_GIT_BRANCH=\"${GIT_BRANCH}\"")
add_definitions("-DFIRMWARE_BUILD=\"$ENV{BUILD_TAG}\"")

if (NOT TARGET firmware-common)
  add_external_arduino_library(firmware-common)

  find_package(arduino-logging)
  find_package(lwcron)
  find_package(RTCZero)
  find_package(RTClib)
  find_package(phylum)
  find_package(module-protocol)
  find_package(app-protocol)
  find_package(data-protocol)
  find_package(lwstreams)
  find_package(WiFi101)

  target_link_libraries(firmware-common arduino-logging)
  target_link_libraries(firmware-common lwcron)
  target_link_libraries(firmware-common RTCZero)
  target_link_libraries(firmware-common RTClib)

  target_compile_options(phylum PUBLIC -DPHYLUM_ENABLE_SERIAL_FLASH -DPHYLUM_ENABLE_SD)

  target_link_libraries(firmware-common phylum)

  target_link_libraries(firmware-common module-protocol)
  target_link_libraries(firmware-common app-protocol)
  target_link_libraries(firmware-common data-protocol)
  target_link_libraries(firmware-common lwstreams)
  target_link_libraries(firmware-common WiFi101)

  find_package(FuelGauge)
  target_link_libraries(firmware-common FuelGauge)

  find_package(TinyGPS)
  target_link_libraries(firmware-common TinyGPS)

  find_package(Adafruit_ASFcore)
  target_link_libraries(firmware-common Adafruit_ASFcore)

  find_package(AtSamd)
  target_link_libraries(firmware-common AtSamd)
endif()

function(fk_configure_module target_name)
  message("Configuring FkModule: ${target_name}")

  find_package(SPI)
  find_package(Wire)

  target_link_libraries(${target_name} firmware-common)
  target_link_libraries(${target_name} RTClib)
  target_link_libraries(${target_name} Wire)
  target_link_libraries(${target_name} RTCZero)
  target_link_libraries(${target_name} phylum)
  target_link_libraries(${target_name} arduino-logging)
  target_link_libraries(${target_name} AtSamd)
  target_link_libraries(${target_name} nanopb)
  target_link_libraries(${target_name} module-protocol)
  target_link_libraries(${target_name} SerialFlash)
  target_link_libraries(${target_name} SPI)

  target_include_directories(${target_name} PRIVATE ./)
endfunction()
