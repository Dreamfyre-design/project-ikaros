cmake_minimum_required(VERSION 3.21)
project(Ikaros VERSION 0.1.0 LANGUAGES CXX)

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
    message(FATAL_ERROR "Use a separate build folder: cmake -S . -B build")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(IKAROS_BUILD_APP "Build the Windows graphical application" ON)
set(SFML_ROOT "" CACHE PATH "Root of an unpacked SFML 2.6.x SDK")
include(CTest)

if(IKAROS_BUILD_APP)
    if(NOT WIN32)
        message(FATAL_ERROR "The launcher currently targets Windows. Use -DIKAROS_BUILD_APP=OFF to build only the portable core tests.")
    endif()
    if(SFML_ROOT)
        list(PREPEND CMAKE_PREFIX_PATH "${SFML_ROOT}")
    endif()
    find_package(SFML 2.6 CONFIG REQUIRED COMPONENTS graphics window system)
    if(NOT TARGET sfml-graphics)
        message(FATAL_ERROR "Ikaros uses the SFML 2.6 API. Select an SFML 2.6.x SDK, not SFML 3.")
    endif()

    add_executable(Ikaros WIN32 src/main.cpp)
    target_include_directories(Ikaros PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src")
    target_link_libraries(Ikaros PRIVATE sfml-graphics sfml-window sfml-system comdlg32 shell32 user32)
    set_target_properties(Ikaros PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
    foreach(configuration DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
        set_target_properties(Ikaros PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY_${configuration} "${CMAKE_BINARY_DIR}/bin")
    endforeach()
    if(MSVC)
        target_compile_options(Ikaros PRIVATE /W4 /EHsc /utf-8)
    endif()
    if(NOT SFML_STATIC_LIBRARIES)
        add_custom_command(TARGET Ikaros POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "$<TARGET_FILE:sfml-graphics>" "$<TARGET_FILE:sfml-window>"
                "$<TARGET_FILE:sfml-system>" "$<TARGET_FILE_DIR:Ikaros>"
            VERBATIM)
    endif()
    add_custom_command(TARGET Ikaros POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/scenarios" "${CMAKE_BINARY_DIR}/scenarios"
        COMMAND "${CMAKE_COMMAND}" -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/licenses" "${CMAKE_BINARY_DIR}/licenses"
        COMMAND "${CMAKE_COMMAND}" -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/docs" "${CMAKE_BINARY_DIR}/docs"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${CMAKE_CURRENT_SOURCE_DIR}/USER-GUIDE.html" "${CMAKE_CURRENT_SOURCE_DIR}/README.md"
            "${CMAKE_CURRENT_SOURCE_DIR}/Run Ikaros.cmd"
            "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE"
            "${CMAKE_CURRENT_SOURCE_DIR}/VALIDATION.md"
            "${CMAKE_BINARY_DIR}"
        VERBATIM)
endif()

if(BUILD_TESTING)
    add_executable(ikaros-gravity-tests tests/gravity-tests.cpp)
    target_include_directories(ikaros-gravity-tests PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src")
    if(MSVC)
        target_compile_options(ikaros-gravity-tests PRIVATE /W4 /EHsc /utf-8)
    else()
        target_compile_options(ikaros-gravity-tests PRIVATE -Wall -Wextra -Wpedantic)
    endif()
    add_test(NAME gravity-original-method COMMAND ikaros-gravity-tests)
endif()
