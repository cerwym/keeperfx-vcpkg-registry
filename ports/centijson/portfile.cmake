vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mity/centijson
    REF 66e68c49d0c4c11cafc198c51c4837caff6fae9e
    SHA512 4e9f5bb60f1e3fc8c00e8b5d6f1d5e7d8c3a2f4b9e6a1c8d7f5e3b2a9c4d1f7e8b5a6c3d9f2e1a7b4c8d5e3f1a9b6c2d7e4f8a5b1c3d9e6f2a8b5c1d4e7f3a9
    HEAD_REF master
)

# The upstream source has a basic CMakeLists.txt but we need to enhance it for vcpkg
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [[
cmake_minimum_required(VERSION 3.13)
project(centijson C)

add_library(centijson 
    src/json.c
    src/json-dom.c
    src/json-ptr.c
    src/value.c
)

target_include_directories(centijson
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        $<INSTALL_INTERFACE:include>
)

set_target_properties(centijson PROPERTIES 
    PUBLIC_HEADER "src/json.h;src/json-dom.h;src/json-ptr.h;src/value.h"
)

install(
    TARGETS centijson
    EXPORT centijsonTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include
)

install(
    EXPORT centijsonTargets
    FILE centijsonTargets.cmake
    NAMESPACE centijson::
    DESTINATION share/centijson
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/centijsonConfigVersion.cmake"
    VERSION 0.0.0
    COMPATIBILITY SameMajorVersion
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/centijsonConfig.cmake"
"include(CMakeFindDependencyMacro)\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/centijsonTargets.cmake\")\n"
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/centijsonConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/centijsonConfigVersion.cmake"
    DESTINATION share/centijson
)
]])

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/centijson)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
