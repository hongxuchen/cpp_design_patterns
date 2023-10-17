cmake_minimum_required(VERSION 3.6)
project(design_pattern C CXX)

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

add_definitions("-std=c++17 -Wall -Wextra -O3")

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)

foreach(module ${PATTERN_DIR_LIST})
    set(DIR ${module})
    add_subdirectory(${DIR})
endforeach()
