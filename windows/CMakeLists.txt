cmake_minimum_required(VERSION 3.14)
project(campusx_flutter LANGUAGES CXX)

set(BINARY_NAME "CampusX")
set(APPLICATION_ID "com.campusx.desktop")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

set(WRAPPER_ROOT "${CMAKE_SOURCE_DIR}/flutter/ephemeral/cpp_client_wrapper")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${PROJECT_BINARY_DIR}/Debug")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_PROFILE "${PROJECT_BINARY_DIR}/Profile")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PROJECT_BINARY_DIR}/Release")

set(CMAKE_POLICY_DEFAULT_CMP0063 NEW)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

add_subdirectory(${FLUTTER_MANAGED_DIR})

add_subdirectory("runner")

if(EXISTS "${CMAKE_SOURCE_DIR}/test/CMakeLists.txt")
  add_subdirectory("test")
endif()

set(FLUTTER_LIBRARY "${FLUTTER_MANAGED_DIR}/ephemeral/flutter_windows.dll")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

set(PROJECT_BUILD_DIR "${PROJECT_BINARY_DIR}/")
set(AOT_LIBRARY "${PROJECT_BUILD_DIR}/windows/app.so")

set(FLUTTER_ICU_DATA_FILE "${FLUTTER_MANAGED_DIR}/ephemeral/icudtl.dat")
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

foreach(bundled_library ${PLUGIN_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${CMAKE_INSTALL_PREFIX}"
    COMPONENT Runtime)
endforeach(bundled_library)

set(FLUTTER_DATA_DIR "${PROJECT_BUILD_DIR}/flutter_assets")
install(DIRECTORY "${FLUTTER_DATA_DIR}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)
