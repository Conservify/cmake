if (NOT DEFINED ARDUINO_IDE)
  foreach(path $ENV{HOME}/arduino-1.8.3 $ENV{HOME}/conservify/arduino-1.8.3
               $ENV{HOME}/workspace/arduino-1.8.3
               ${PROJECT_SOURCE_DIR}/../arduino-1.8.3 ${PROJECT_SOURCE_DIR}/../../arduino-1.8.3)
      if (EXISTS ${path})
        set(ARDUINO_IDE ${path})
        break()
    endif()
  endforeach()

  if (NOT DEFINED ARDUINO_IDE)
    message(FATAL_ERROR "Unable to find Arduino IDE")
  endif()
endif()

set(ARDUINO_PACKAGES_PATH "${ARDUINO_IDE}/packages")
set(ARDUINO_TOOLS_PATH "${ARDUINO_PACKAGES_PATH}/arduino/tools")
set(ARM_TOOLS "${ARDUINO_TOOLS_PATH}/arm-none-eabi-gcc/4.8.3-2014q1/bin")

set(ARDUINO_BOARD "arduino_zero")
set(ARDUINO_MCU "cortex-m0plus")
set(ARDUINO_FCPU "48000000L")

set(ARDUINO_CMSIS_DIRECTORY "${ARDUINO_TOOLS_PATH}/CMSIS/4.5.0/CMSIS")
set(ARDUINO_CMSIS_INCLUDE_DIRECTORY "${ARDUINO_CMSIS_DIRECTORY}/Include/")
set(ARDUINO_DEVICE_DIRECTORY "${ARDUINO_TOOLS_PATH}/CMSIS-Atmel/1.1.0/CMSIS/Device/ATMEL")
set(ARDUINO_BOARD_CORE_ROOT "${ARDUINO_PACKAGES_PATH}/adafruit/hardware/samd/1.0.22")
set(ARDUINO_BOARD_CORE_LIBRARIES_PATH "${ARDUINO_BOARD_CORE_ROOT}/libraries")
set(ARDUINO_LIBRARIES_PATH "${ARDUINO_IDE}/libraries")
set(ARDUINO_CORE_DIRECTORY "${ARDUINO_BOARD_CORE_ROOT}/cores/arduino/")
set(ARDUINO_BOARD_DIRECTORY "${ARDUINO_BOARD_CORE_ROOT}/variants/${ARDUINO_BOARD}")
set(ARDUINO_BOOTLOADER "${CMAKE_MODULE_PATH}/linking/samd21x18_bootloader_large.ld")
set(ARDUINO_INCLUDES ${ARDUINO_CMSIS_INCLUDE_DIRECTORY} ${ARDUINO_DEVICE_DIRECTORY} ${ARDUINO_CORE_DIRECTORY} ${ARDUINO_BOARD_DIRECTORY})

set(ARDUINO_USB_STRING_FLAGS "-DUSB_MANUFACTURER=\"Arduino LLC\" -DUSB_PRODUCT=\"\\\"Arduino Zero\\\"\"")
set(ARDUINO_BOARD_FLAGS "-DF_CPU=${ARDUINO_FCPU} -DARDUINO=2491 -DARDUINO_M0PLUS=10605 -DARDUINO_SAMD_ZERO -DARDUINO_ARCH_SAMD -D__SAMD21G18A__ -DUSB_VID=0x2341 -DUSB_PID=0x804d -DUSBCON")
set(ARDUINO_C_FLAGS "-g -Os -s -ffunction-sections -fdata-sections -nostdlib --param max-inline-insns-single=500 -MMD -mcpu=${ARDUINO_MCU} -mthumb ${ARDUINO_BOARD_FLAGS}")
set(ARDUINO_CXX_FLAGS "${ARDUINO_C_FLAGS} -fno-threadsafe-statics -fno-rtti -fno-exceptions")
set(ARDUINO_ASM_FLAGS "-g -x assembler-with-cpp ${ARDUINO_BOARD_FLAGS}")

set(ARDUINO_OBJCOPY "${ARM_TOOLS}/arm-none-eabi-objcopy")
set(ARDUINO_NM "${ARM_TOOLS}/arm-none-eabi-nm")

function(enable_small_bootloader)
  set(ARDUINO_BOOTLOADER "${CMAKE_MODULE_PATH}/linking/samd21x18_bootloader_small.ld" PARENT_SCOPE)
  message(STATUS "Linking for use with small bootloader.")
endfunction()

function(enable_large_bootloader)
  set(ARDUINO_BOOTLOADER "${CMAKE_MODULE_PATH}/linking/samd21x18_bootloader_large.ld" PARENT_SCOPE)
  message(STATUS "Linking for use with large bootloader.")
endfunction()

# Not a huge fan of this. There doesn't seem to be a good way of setting C/C++
# flags separately for a target, though.
function(apply_compile_flags files new_c_flags new_cxx_flags new_asm_flags)
  foreach(file ${files})
    if(${file} MATCHES ".c$")
      set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "${new_c_flags}")
    endif()
    if(${file} MATCHES ".cpp$")
      set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "${new_cxx_flags}")
    endif()
    if(${file} MATCHES ".s$")
      set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "${new_asm_flags}")
    endif()
  endforeach()
endfunction()

function(configure_compile_options target_name sources)
  target_include_directories(${target_name} PUBLIC "${ARDUINO_INCLUDES}")
  set_target_properties(${target_name} PROPERTIES C_STANDARD 11)
  set_target_properties(${target_name} PROPERTIES CXX_STANDARD 11)
  apply_compile_flags("${sources}" ${ARDUINO_C_FLAGS} ${ARDUINO_CXX_FLAGS} ${ARDUINO_ASM_FLAGS})
endfunction()

function(configure_arduino_core_target)
  if(TARGET arduino-core)
    return()
  endif()

  set(sources
    ${ARDUINO_BOARD_DIRECTORY}/variant.cpp
    ${ARDUINO_CORE_DIRECTORY}/pulse_asm.S
    ${ARDUINO_CORE_DIRECTORY}/avr/dtostrf.c
    ${ARDUINO_CORE_DIRECTORY}/wiring_shift.c
    ${ARDUINO_CORE_DIRECTORY}/WInterrupts.c
    ${ARDUINO_CORE_DIRECTORY}/pulse.c
    ${ARDUINO_CORE_DIRECTORY}/cortex_handlers.c
    ${ARDUINO_CORE_DIRECTORY}/wiring_digital.c
    ${ARDUINO_CORE_DIRECTORY}/startup.c
    ${ARDUINO_CORE_DIRECTORY}/hooks.c
    ${ARDUINO_CORE_DIRECTORY}/wiring_private.c
    ${ARDUINO_CORE_DIRECTORY}/itoa.c
    ${ARDUINO_CORE_DIRECTORY}/delay.c
    ${ARDUINO_CORE_DIRECTORY}/wiring_analog.c
    ${ARDUINO_CORE_DIRECTORY}/USB/PluggableUSB.cpp
    ${ARDUINO_CORE_DIRECTORY}/USB/USBCore.cpp
    ${ARDUINO_CORE_DIRECTORY}/USB/samd21_host.c
    ${ARDUINO_CORE_DIRECTORY}/USB/CDC.cpp
    ${ARDUINO_CORE_DIRECTORY}/wiring.c
    ${ARDUINO_CORE_DIRECTORY}/abi.cpp
    ${ARDUINO_CORE_DIRECTORY}/Print.cpp
    ${ARDUINO_CORE_DIRECTORY}/Reset.cpp
    ${ARDUINO_CORE_DIRECTORY}/Stream.cpp
    ${ARDUINO_CORE_DIRECTORY}/Tone.cpp
    ${ARDUINO_CORE_DIRECTORY}/WMath.cpp
    ${ARDUINO_CORE_DIRECTORY}/RingBuffer.cpp
    ${ARDUINO_CORE_DIRECTORY}/SERCOM.cpp
    ${ARDUINO_CORE_DIRECTORY}/Uart.cpp
    ${ARDUINO_CORE_DIRECTORY}/WString.cpp
    ${ARDUINO_CORE_DIRECTORY}/new.cpp
    ${ARDUINO_CORE_DIRECTORY}/IPAddress.cpp
  )

  add_library(arduino-core STATIC ${sources})

  configure_compile_options(arduino-core "${sources}")
endfunction()

# Call from the project.
function(enable_arduino_toolchain)
  set(CMAKE_C_COMPILER "${ARM_TOOLS}/arm-none-eabi-gcc" PARENT_SCOPE)
  set(CMAKE_CXX_COMPILER "${ARM_TOOLS}/arm-none-eabi-g++" PARENT_SCOPE)
  set(CMAKE_ASM_COMPILER "${ARM_TOOLS}/arm-none-eabi-gcc" PARENT_SCOPE)
  set(CMAKE_AR "${ARM_TOOLS}/arm-none-eabi-ar" PARENT_SCOPE)
  set(CMAKE_RANLIB "${ARM_TOOLS}/arm-none-eabi-ranlib" PARENT_SCOPE)
endfunction()

function(configure_firmware_linker_script target_name script)
  set(${target_name}_LINKER ${script} PARENT_SCOPE)
endfunction()

function(configure_firmware_link target_name additional_libraries)
  get_target_property(libraries ${target_name} LINK_LIBRARIES)

  set(unique_libraries ${target_name})
  if(NOT "${libraries}" STREQUAL "libraries-NOTFOUND")
    foreach(library ${libraries})
      get_property(libs TARGET ${library} PROPERTY INTERFACE_LINK_LIBRARIES)
      list(APPEND unique_libraries ${library})
      list(APPEND unique_libraries ${libs})
    endforeach()
  endif()

  list(REMOVE_DUPLICATES unique_libraries)
  set(library_files)
  foreach(library ${unique_libraries})
    get_target_property(library_dir ${library} BINARY_DIR)
    list(APPEND library_files ${library_dir}/lib${library}.a)
  endforeach()

  add_custom_target(${target_name}.elf)

  add_dependencies(${target_name}.elf ${target_name})

  set(linker_script ${ARDUINO_BOOTLOADER})
  if(DEFINED ${target_name}_LINKER)
    set(linker_script ${${target_name}_LINKER})
  endif()

  add_custom_command(TARGET ${target_name}.elf POST_BUILD
    COMMAND ${CMAKE_C_COMPILER} -Os -Wl,--gc-sections -save-temps -T${linker_script}
    --specs=nano.specs --specs=nosys.specs -mcpu=${ARDUINO_MCU} -mthumb -Wl,--cref -Wl,--check-sections
    -Wl,--gc-sections -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align
    -Wl,-Map,${CMAKE_CURRENT_BINARY_DIR}/${target_name}.map -o ${CMAKE_CURRENT_BINARY_DIR}/${target_name}.elf
    -L${ARDUINO_CMSIS_DIRECTORY}/Lib/GCC/
    ${library_files} ${additional_libraries}
  )

  add_custom_target(${target_name}.bin)

  add_dependencies(${target_name}.bin ${target_name}.elf)

  add_custom_command(TARGET ${target_name}.bin POST_BUILD COMMAND ${ARDUINO_OBJCOPY} -O binary
    ${CMAKE_CURRENT_BINARY_DIR}/${target_name}.elf
    ${CMAKE_CURRENT_BINARY_DIR}/${target_name}.bin)

  add_custom_command(TARGET ${target_name}.bin POST_BUILD COMMAND ${ARDUINO_NM} --print-size --size-sort --radix=d
    ${CMAKE_CURRENT_BINARY_DIR}/${target_name}.elf > ${CMAKE_CURRENT_BINARY_DIR}/${target_name}.syms)

  add_custom_target(${target_name}_bin ALL DEPENDS ${target_name}.bin)

  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${target_name}.syms"
    "${CMAKE_CURRENT_BINARY_DIR}/${target_name}.elf"
    "${CMAKE_CURRENT_BINARY_DIR}/${target_name}.bin"
    "${CMAKE_CURRENT_BINARY_DIR}/${target_name}.map")
endfunction()

function(add_arduino_library target_name sources)
  add_library(${target_name} STATIC ${sources})
  configure_compile_options(${target_name} "${sources}")
endfunction()

function(add_arduino_firmware target_name)
  get_target_property(updated_sources ${target_name} SOURCES)
  list(INSERT updated_sources 0 ${ARDUINO_CORE_DIRECTORY}/main.cpp)
  configure_compile_options(${target_name} "${updated_sources}")
  target_sources(${target_name} PUBLIC ${updated_sources})

  configure_arduino_core_target()

  target_link_libraries(${target_name} arduino-core)

  # set(ld_flags -lm -larm_cortexM0l_math -lc -u _printf_float)
  set(ld_flags -lm -larm_cortexM0l_math)
  configure_firmware_link(${target_name} "${ld_flags}")
endfunction()

function(add_arduino_bootloader target_name)
  configure_arduino_core_target()

  configure_firmware_link(${target_name} "")
endfunction()

function(add_external_arduino_library name)
  if(NOT DEFINED EXTERNAL_DEPENDENCIES)
    include(${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake)
  endif()

  if (NOT EXISTS ${${name}_PATH})
    message(FATAL_ERROR "No ${name}_PATH")
  endif()

  set(path "${${name}_PATH}")
  set(recurse "${${name}_RECURSE}")
  set(sources_path ${path})

  if (EXISTS "${path}/src")
    set(sources_path "${path}/src")
  endif()

  message(STATUS "Library: ${name} (${sources_path})")

  if (NOT TARGET ${name})
    if (recurse)
      file(GLOB_RECURSE sources ${sources_path}/*.c ${sources_path}/*.cpp)
    else()
      file(GLOB sources ${sources_path}/*.c ${sources_path}/*.cpp)
    endif()

    add_arduino_library(${name} "${sources}")

    target_include_directories(${name}
      PUBLIC ${sources_path}
      PRIVATE ${sources_path}
    )
  endif()
endfunction()

function(add_gitdeps)
  if(NOT DEFINED EXTERNAL_DEPENDENCIES)
    message(STATUS "Including: ${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake")
    include(${CMAKE_CURRENT_SOURCE_DIR}/dependencies.cmake)
  endif()

  foreach(name ${EXTERNAL_DEPENDENCIES})
    add_external_arduino_library(${name})
  endforeach()
endfunction()
