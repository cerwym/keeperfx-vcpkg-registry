vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO miniupnp/libnatpmp
    REF 134fc89e2781e154e40042641f4d8bcbe42579f1
    SHA512 4021646ef21cd2501e92c71f261d9a5859bafb59ebb6728e372cf69383792acb0839133beff10d638d9447efeec49d87b5f39d1f5fe7ee371f1f140b3e322969
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=OFF
    MAYBE_UNUSED_VARIABLES
        NATPMP_STATICLIB
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

# Move headers into natpmp/ subdirectory so #include <natpmp/natpmp.h> works
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/natpmp")
foreach(_h natpmp.h natpmp_declspec.h)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/include/${_h}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/include/${_h}" "${CURRENT_PACKAGES_DIR}/include/natpmp/${_h}")
    endif()
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# libnatpmp has no upstream CMake config — write a minimal one so
# find_package(libnatpmp CONFIG REQUIRED) works.
set(_share "${CURRENT_PACKAGES_DIR}/share/libnatpmp")
file(MAKE_DIRECTORY "${_share}")
file(WRITE "${_share}/libnatpmpConfig.cmake" [[
if(NOT TARGET libnatpmp::libnatpmp)
    add_library(libnatpmp::libnatpmp STATIC IMPORTED)
    get_filename_component(_natpmp_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
    find_library(_natpmp_lib NAMES natpmp PATHS "${_natpmp_root}/lib" NO_DEFAULT_PATH REQUIRED)
    set_target_properties(libnatpmp::libnatpmp PROPERTIES
        IMPORTED_LOCATION "${_natpmp_lib}"
        INTERFACE_INCLUDE_DIRECTORIES "${_natpmp_root}/include"
    )
    if(WIN32)
        set_property(TARGET libnatpmp::libnatpmp APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES iphlpapi)
    endif()
    unset(_natpmp_root)
    unset(_natpmp_lib)
endif()
]])
file(WRITE "${_share}/libnatpmpConfigVersion.cmake" [[
set(PACKAGE_VERSION "2023-10-22")
if(PACKAGE_FIND_VERSION AND PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)
    set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
    set(PACKAGE_VERSION_EXACT FALSE)
endif()
]])

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${_share}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
