cmake_minimum_required(VERSION 2.8)
project(design_pattern C CXX)


set (CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake")

if(EXISTS ${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    conan_basic_setup()
else()
    message(WARNING "The file conanbuildinfo.cmake doesn't exist, you have to run conan install first")
endif()

include("cmakepp")
include("cotire")

SET(PATTERN_DIR_LIST
  factory
  absfactory
  singleton
  builder
  prototype
  bridge
  adapter
  decorator
  composite
  flyweight
  facade
  proxy
  template
  strategy
  state
  observer
  memento
  mediator
  command
  visitor
  chain_of_responsibility
  iterator
  interpreter
  )

if(CONFIG_FILE)
  message("config file ${CONFIG_FILE} Found")
  include(pattern_config.cmake)
endif()

if("${CMAKE_GENERATOR}" STREQUAL "Ninja")
  if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_definitions("-fcolor-diagnostics")
  endif()
endif()

add_definitions("-std=c++1y -Wall -Wextra -O3")

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)

foreach(MODULE ${PATTERN_DIR_LIST})
  set(DIR ${MODULE})
  add_subdirectory(${DIR})
endforeach()
