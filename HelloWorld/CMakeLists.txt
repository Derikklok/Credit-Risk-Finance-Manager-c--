cmake_minimum_required(VERSION 3.10)

project(HelloWorld)

find_package(fmt CONFIG REQUIRED)

add_executable(HelloWorld helloworld.cpp)

target_link_libraries(HelloWorld PRIVATE fmt::fmt)

# Copy vcpkg runtime DLLs next to the executable for MinGW dynamic builds.
if(DEFINED VCPKG_TARGET_TRIPLET)
	set(VCPKG_RUNTIME_DIR "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/bin")
	if(EXISTS "${VCPKG_RUNTIME_DIR}")
		file(GLOB VCPKG_RUNTIME_DLLS "${VCPKG_RUNTIME_DIR}/*.dll")
		if(VCPKG_RUNTIME_DLLS)
			add_custom_command(
				TARGET HelloWorld
				POST_BUILD
				COMMAND ${CMAKE_COMMAND} -E copy_if_different
						${VCPKG_RUNTIME_DLLS}
						$<TARGET_FILE_DIR:HelloWorld>
			)
		endif()
	endif()
endif()