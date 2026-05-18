#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="${1:-}"

if [[ -z "$PROJECT_NAME" ]]; then
	echo "Usage: ./Initiate_Cpp.sh <ProjectName>"
	exit 1
fi

PROJECT_DIR="$(pwd)/${PROJECT_NAME}"

if [[ -e "$PROJECT_DIR" ]]; then
	echo "Error: '${PROJECT_DIR}' already exists."
	exit 1
fi

mkdir -p "$PROJECT_DIR/src"

cat > "$PROJECT_DIR/src/main.cpp" <<'EOF'
#include <fmt/core.h>

int main() {
		fmt::print("Hello World!\n");
		return 0;
}
EOF

cat > "$PROJECT_DIR/vcpkg.json" <<'EOF'
{
	"dependencies": [
		"fmt"
	]
}
EOF

cat > "$PROJECT_DIR/CMakeLists.txt" <<'EOF'
cmake_minimum_required(VERSION 3.10)

project(MyProject)

find_package(fmt CONFIG REQUIRED)

add_executable(MyProject src/main.cpp)

target_link_libraries(MyProject PRIVATE fmt::fmt)

# Copy vcpkg runtime DLLs next to the executable for MinGW dynamic builds.
if(DEFINED VCPKG_TARGET_TRIPLET)
		set(VCPKG_RUNTIME_DIR "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/bin")
		if(EXISTS "${VCPKG_RUNTIME_DIR}")
				file(GLOB VCPKG_RUNTIME_DLLS "${VCPKG_RUNTIME_DIR}/*.dll")
				if(VCPKG_RUNTIME_DLLS)
						add_custom_command(
								TARGET MyProject
								POST_BUILD
								COMMAND ${CMAKE_COMMAND} -E copy_if_different
												${VCPKG_RUNTIME_DLLS}
												$<TARGET_FILE_DIR:MyProject>
						)
				endif()
		endif()
endif()
EOF

cat > "$PROJECT_DIR/CMakePresets.json" <<'EOF'
{
	"version": 2,
	"configurePresets": [
		{
			"name": "vcpkg",
			"generator": "Ninja",
			"binaryDir": "${sourceDir}/build",
			"cacheVariables": {
				"CMAKE_TOOLCHAIN_FILE": "$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
			}
		}
	]
}
EOF

cat > "$PROJECT_DIR/CMakeUserPresets.json" <<'EOF'
{
	"version": 2,
	"configurePresets": [
		{
			"name": "default",
			"inherits": "vcpkg",
			"cacheVariables": {
				"CMAKE_MAKE_PROGRAM": "C:\\Users\\User\\Desktop\\Programming\\installed\\vcpkg\\downloads\\tools\\ninja-1.13.2-windows\\ninja.exe",
				"CMAKE_BUILD_TYPE": "Release",
				"VCPKG_TARGET_TRIPLET": "x64-mingw-dynamic"
			},
			"environment": {
				"VCPKG_ROOT": "C:\\Users\\User\\Desktop\\Programming\\installed\\vcpkg"
			}
		}
	]
}
EOF

cat > "$PROJECT_DIR/.gitignore" <<'EOF'
# Build outputs
**/build/
**/CMakeFiles/
**/CMakeCache.txt
**/cmake_install.cmake
**/Makefile

# CMake user presets
**/CMakeUserPresets.json

# vcpkg artifacts
**/vcpkg_installed/
**/vcpkg/
**/vcpkg_lock.json

# Compiler outputs
*.o
*.obj
*.exe
*.dll
*.lib
*.a
*.pdb
*.ilk

# IDE/Editor files
.vscode/
*.user
*.suo
*.log

# OS files
.DS_Store
Thumbs.db
EOF

echo "Project created at: $PROJECT_DIR"
echo "Next steps:"
echo "  cd '$PROJECT_DIR'"
echo "  cmake --preset=default"
echo "  cmake --build build"
