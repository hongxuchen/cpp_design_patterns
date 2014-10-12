get_filename_component(PROJECTID ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" PROJECTID ${PROJECTID})
project(${PROJECTID})

file(GLOB SRC_FILES *.cc)
set(EXECUTABLE_NAME "${PROJECTID}.out")
add_executable(${EXECUTABLE_NAME} ${SRC_FILES})
