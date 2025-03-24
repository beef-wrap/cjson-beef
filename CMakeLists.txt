cmake_minimum_required(VERSION 3.27)

project(cjson)

# remove "lib" prefix on unix systems
set(CMAKE_STATIC_LIBRARY_PREFIX "")

option(BUILD_SHARED_LIBS "" Off)
option(ENABLE_CJSON_TEST "" Off)

add_subdirectory(cJSON)

if (WIN32)
    set(OUTPUT_DIR "windows" CACHE STRING "")
elseif(APPLE)
    set(OUTPUT_DIR "macos" CACHE STRING "")
elseif(UNIX)
    set(OUTPUT_DIR "linux" CACHE STRING "")
endif ()

set_target_properties(cjson PROPERTIES ARCHIVE_OUTPUT_DIRECTORY $<LOWER_CASE:../../../libs/${OUTPUT_DIR}>) 
set_target_properties(cjson PROPERTIES OUTPUT_NAME_DEBUG "cjsond")
set_target_properties(cjson PROPERTIES OUTPUT_NAME_RELEASE "cjson")