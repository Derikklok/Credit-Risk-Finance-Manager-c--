#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="${1:-}"

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Usage: ./Initiate_Backend.sh <ProjectName>"
  exit 1
fi

PROJECT_DIR="$(pwd)/${PROJECT_NAME}"

if [[ -e "$PROJECT_DIR" ]]; then
  echo "Error: '${PROJECT_DIR}' already exists."
  exit 1
fi

mkdir -p "$PROJECT_DIR/src"

cat > "$PROJECT_DIR/src/main.cpp" <<'EOF'
#include <drogon/drogon.h>
#include <cstdlib>
#include <string>

int main() {
    auto portEnv = std::getenv("APP_PORT");
    auto port = portEnv ? std::stoi(portEnv) : 8080;

    drogon::app()
        .addListener("0.0.0.0", port)
        .registerHandler("/health", [](const drogon::HttpRequestPtr&, const drogon::HttpResponseCallback& cb) {
            auto resp = drogon::HttpResponse::newHttpResponse();
            resp->setBody("OK");
            cb(resp);
        })
        .registerHandler("/echo", [](const drogon::HttpRequestPtr& req, const drogon::HttpResponseCallback& cb) {
            auto name = req->getParameter("name");
            if (name.empty()) {
                auto resp = drogon::HttpResponse::newHttpResponse();
                resp->setStatusCode(drogon::k400BadRequest);
                resp->setBody("Missing query param: name");
                cb(resp);
                return;
            }

            auto resp = drogon::HttpResponse::newHttpResponse();
            resp->setBody("Hello, " + name + "!\n");
            cb(resp);
        })
        .run();
}
EOF

cat > "$PROJECT_DIR/vcpkg.json" <<'EOF'
{
  "dependencies": [
    "drogon",
    "trantor",
    "jsoncpp",
    "openssl",
    "mysql-connector-cpp"
  ]
}
EOF

cat > "$PROJECT_DIR/CMakeLists.txt" <<'EOF'
cmake_minimum_required(VERSION 3.10)

project(MyBackend)

find_package(Drogon CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(mysql-connector-cpp CONFIG REQUIRED)

add_executable(MyBackend src/main.cpp)

target_link_libraries(MyBackend PRIVATE Drogon::Drogon OpenSSL::SSL OpenSSL::Crypto mysqlcppconn8)

# Copy vcpkg runtime DLLs next to the executable for MinGW dynamic builds.
if(DEFINED VCPKG_TARGET_TRIPLET)
    set(VCPKG_RUNTIME_DIR "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/bin")
    if(EXISTS "${VCPKG_RUNTIME_DIR}")
        file(GLOB VCPKG_RUNTIME_DLLS "${VCPKG_RUNTIME_DIR}/*.dll")
        if(VCPKG_RUNTIME_DLLS)
            add_custom_command(
                TARGET MyBackend
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        ${VCPKG_RUNTIME_DLLS}
                        $<TARGET_FILE_DIR:MyBackend>
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
+echo "Env vars: set APP_PORT to change the server port (default 8080)."
+echo "Run:"
+echo "  cd '$PROJECT_DIR'"
+echo "  cmake --preset=default"
+echo "  cmake --build build"
+echo "  ./build/MyBackend.exe"
