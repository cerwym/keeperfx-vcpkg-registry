vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cosinekitty/astronomy
    REF "v${VERSION}"
    SHA512 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    HEAD_REF master
)

# The upstream C source has no CMakeLists.txt; inject a minimal one.
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [[
cmake_minimum_required(VERSION 3.13)
project(astronomy C)

add_library(astronomy source/c/astronomy.c)
target_include_directories(astronomy
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source/c>
        $<INSTALL_INTERFACE:include>
)
set_target_properties(astronomy PROPERTIES PUBLIC_HEADER "source/c/astronomy.h")

install(
    TARGETS astronomy
    EXPORT astronomyTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include
)
install(
    EXPORT astronomyTargets
    FILE astronomyTargets.cmake
    NAMESPACE astronomy::
    DESTINATION share/astronomy
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/astronomyConfigVersion.cmake"
    VERSION 2.1.19
    COMPATIBILITY SameMajorVersion
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/astronomyConfig.cmake"
"include(CMakeFindDependencyMacro)\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/astronomyTargets.cmake\")\n"
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/astronomyConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/astronomyConfigVersion.cmake"
    DESTINATION share/astronomy
)
]])

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/astronomy)

# Remove debug headers (only one copy needed)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
