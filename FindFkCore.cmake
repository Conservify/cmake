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
  find_package(arduino-base64)

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

  target_link_libraries(firmware-common arduino-base64)

  target_include_directories(firmware-common
    PUBLIC ${firmware-common_PATH}/src
  )
  option(FK_ENABLE_RADIO "Enable/disable LoRa radio." OFF)
  if(FK_ENABLE_RADIO)
    target_compile_definitions(firmware-common PUBLIC -DFK_ENABLE_RADIO)
  else()
    target_compile_definitions(firmware-common PUBLIC -DFK_DISABLE_RADIO)
  endif(FK_ENABLE_RADIO)

  target_compile_definitions(firmware-common PUBLIC -DFK_NATURALIST -DFK_CORE)
endif()
