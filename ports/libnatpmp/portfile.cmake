vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO miniupnp/libnatpmp
    REF 007f4f2765ef6e1b7b2bddcc03f3697fb3df74e5
    SHA512 0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=OFF
        -DNATPMP_STATICLIB=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libnatpmp PACKAGE_NAME libnatpmp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# On Windows, iphlpapi must be linked by the consumer
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libnatpmp/usage" [[
libnatpmp provides CMake integration.

  find_package(libnatpmp CONFIG REQUIRED)
  target_link_libraries(main PRIVATE libnatpmp::libnatpmp)

Note: on Windows, iphlpapi is linked automatically via the imported target.
]])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
