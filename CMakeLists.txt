cmake_minimum_required(VERSION 3.5.0)

project(qore-cairo-module)

set(VERSION_MAJOR 1)
set(VERSION_MINOR 0)
set(VERSION_PATCH 0)

set(PROJECT_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12.0")
    cmake_policy(SET CMP0074 NEW)

    if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.18.0")
        cmake_policy(SET CMP0053 NEW)
    endif()
endif()

cmake_policy(SET CMP0042 NEW)

if (UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()

find_package(Qore 2.0 REQUIRED)
find_package(PkgConfig REQUIRED)

pkg_check_modules(LIBCAIRO REQUIRED cairo)
# Use IMPORTED_TARGET to avoid name collision with our module target
if (pkgcfg_lib_LIBCAIRO_cairo)
    set(LIBCAIRO_LINK ${pkgcfg_lib_LIBCAIRO_cairo})
else()
    set(LIBCAIRO_LINK ${LIBCAIRO_LINK_LIBRARIES})
endif()

option(ENABLE_RSVG "Enable librsvg for SVG input/rendering" ON)
set(RSVG_FOUND OFF)

if (ENABLE_RSVG)
    pkg_check_modules(RSVG librsvg-2.0)
    if (RSVG_FOUND)
        message(STATUS "librsvg found: SVG input/rendering enabled")
    else()
        message(STATUS "librsvg not found; SVG input/rendering disabled")
    endif()
endif()

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++17" COMPILER_SUPPORTS_CXX17)
if(COMPILER_SUPPORTS_CXX17)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
else()
    message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++17 support.")
endif()

set(QPP_SRC
    src/QC_CairoSurface.qpp
    src/QC_CairoContext.qpp
    src/QC_CairoPattern.qpp
)

set(CPP_SRC
    src/cairo-module.cpp
    src/CairoSurface.cpp
    src/CairoContext.cpp
    src/CairoPattern.cpp
)

if (RSVG_FOUND)
    list(APPEND QPP_SRC src/QC_CairoSvgReader.qpp)
    list(APPEND CPP_SRC src/CairoSvgReader.cpp)
endif()

qore_wrap_qpp_value(QPP_SOURCES ${QPP_SRC})

foreach (it ${QPP_SOURCES})
    GET_FILENAME_COMPONENT(_outfile ${it} NAME_WE)
    set(QPP_DOX ${QPP_DOX} ${CMAKE_CURRENT_BINARY_DIR}/${_outfile}.dox.h)
endforeach()

set(module_name "cairo")

set(QMOD
    qlib/CairoDataProvider
)

set(QORE_DOX_TMPL_SRC
  docs/mainpage.dox.tmpl
)

add_library(${module_name} MODULE ${CPP_SRC} ${QPP_SOURCES})

include_directories(${CMAKE_SOURCE_DIR}/src)
include_directories(${LIBCAIRO_INCLUDE_DIRS})
if (LIBCAIRO_LIBRARY_DIRS)
    link_directories(${LIBCAIRO_LIBRARY_DIRS})
endif()

target_include_directories(${module_name} PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>)

add_custom_target(QORE_INC_FILES DEPENDS ${QORE_INC_SRC})
add_dependencies(${module_name} QORE_INC_FILES)

target_link_libraries(${module_name} ${QORE_LIBRARY})
target_link_options(${module_name} PRIVATE "-lcairo")

if (RSVG_FOUND)
    include_directories(${RSVG_INCLUDE_DIRS})
    if (RSVG_LIBRARY_DIRS)
        link_directories(${RSVG_LIBRARY_DIRS})
    endif()
    # Link RSVG libraries by linker flags to avoid target name collision with our "cairo" module
    foreach(_rsvg_lib ${RSVG_LIBRARIES})
        target_link_options(${module_name} PRIVATE "-l${_rsvg_lib}")
    endforeach()
    if (RSVG_LIBRARY_DIRS)
        foreach(_rsvg_dir ${RSVG_LIBRARY_DIRS})
            target_link_options(${module_name} PRIVATE "-L${_rsvg_dir}")
        endforeach()
    endif()
    target_compile_definitions(${module_name} PRIVATE HAVE_RSVG=1)
endif()

string(REPLACE ";" " " LIBCAIRO_CFLAGS_STR "${LIBCAIRO_CFLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${LIBCAIRO_CFLAGS_STR}")

if (RSVG_FOUND)
    string(REPLACE ";" " " RSVG_CFLAGS "${RSVG_CFLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${RSVG_CFLAGS}")
endif()

set(MODULE_DOX_INPUT ${CMAKE_BINARY_DIR})
qore_external_binary_module(${module_name} ${PROJECT_VERSION})

qore_dist(${PROJECT_VERSION})

qore_user_modules("${QMOD}")
qore_external_user_module("qlib/CairoDataProvider" "")

qore_config_info()

if (DOXYGEN_FOUND)
    qore_wrap_dox(QORE_DOX_SRC ${QORE_DOX_TMPL_SRC})
    add_custom_target(QORE_MOD_DOX_FILES DEPENDS ${QORE_DOX_SRC})
    add_dependencies(docs-module QORE_MOD_DOX_FILES)
endif()
