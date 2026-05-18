# C++ Project Starter (Windows + vcpkg + CMake)

This repo is my reusable template for starting C++ projects from an empty folder on this machine.
It is customized for:

- Windows + MSYS2/MINGW64 shell
- CMake + Ninja
- vcpkg at `C:\Users\User\Desktop\Programming\installed\vcpkg`
- MinGW toolchain with `x64-mingw-dynamic`

## Prerequisites (one-time)

- Visual Studio Build Tools (MSVC) installed
- CMake installed and on PATH
- Git installed
- vcpkg cloned at `C:\Users\User\Desktop\Programming\installed\vcpkg`

Optional (recommended): ensure vcpkg is up to date

```bash
cd /c/Users/User/Desktop/Programming/installed/vcpkg
git pull
.
```

## Start a new project from an empty folder

```bash
mkdir MyProject
cd MyProject
git init
```

Create a folder structure (example):

```bash
mkdir src
```

### 1) Add dependencies (vcpkg)

Create `vcpkg.json`:

```json
{
	"dependencies": [
		"fmt"
	]
}
```

### 2) Add CMake files

Create `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.10)

project(MyProject)

find_package(fmt CONFIG REQUIRED)

add_executable(MyProject src/main.cpp)

target_link_libraries(MyProject PRIVATE fmt::fmt)
```

Create `CMakePresets.json`:

```json
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
```

Create `CMakeUserPresets.json` (do not commit this file):

```json
{
	"version": 2,
	"configurePresets": [
		{
			"name": "default",
			"inherits": "vcpkg",
			"cacheVariables": {
				"CMAKE_MAKE_PROGRAM": "C:\\Users\\User\\Desktop\\Programming\\installed\\vcpkg\\downloads\\tools\\ninja-1.13.2-windows\\ninja.exe",
				"VCPKG_TARGET_TRIPLET": "x64-mingw-dynamic"
			},
			"environment": {
				"VCPKG_ROOT": "C:\\Users\\User\\Desktop\\Programming\\installed\\vcpkg"
			}
		}
	]
}
```

### 3) Add source code

Create `src/main.cpp`:

```cpp
#include <fmt/core.h>

int main() {
		fmt::print("Hello World!\n");
		return 0;
}
```

## Build and run

```bash
cmake --preset=default
cmake --build build
```

Run:

```bash
./build/MyProject.exe
```

## Notes and troubleshooting

- If you switch toolchains or vcpkg triplets, delete `build/` and reconfigure.
- The MinGW linker must match vcpkg triplet. This setup uses `x64-mingw-dynamic`.
- If CMake cannot find Ninja, make sure `CMAKE_MAKE_PROGRAM` points to the vcpkg Ninja path above.

## Git ignore

This repo includes a `.gitignore` that excludes build outputs, vcpkg artifacts, and user-specific presets.
