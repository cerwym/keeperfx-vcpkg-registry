vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cerwym/centitoml
    REF "v${VERSION}"
    SHA512 42be369c68d81b587067386f5d8abefa45a6fdb676a7e422a57d24bab882b846dc3230c96cf77c1aa279479d8d50bf98df5ebd9870eed3f8a51e4bd38b0700da
    HEAD_REF main
)

# No upstream CMakeLists.txt; inject a minimal one.
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [[
cmake_minimum_required(VERSION 3.13)
project(centitoml C)

find_package(centijson CONFIG REQUIRED)

add_library(centitoml toml_api.c)
target_link_libraries(centitoml PUBLIC centijson::centijson)
target_include_directories(centitoml
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)
set_target_properties(centitoml PROPERTIES PUBLIC_HEADER "toml.h")

install(
    TARGETS centitoml
    EXPORT centitomlTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include
)
install(
    EXPORT centitomlTargets
    FILE centitomlTargets.cmake
    NAMESPACE centitoml::
    DESTINATION share/centitoml
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/centitomlConfigVersion.cmake"
    VERSION 0.1.0
    COMPATIBILITY SameMajorVersion
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/centitomlConfig.cmake"
"include(CMakeFindDependencyMacro)\nfind_dependency(centijson)\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/centitomlTargets.cmake\")\n"
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/centitomlConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/centitomlConfigVersion.cmake"
    DESTINATION share/centitoml
)
]])

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/centitoml)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
