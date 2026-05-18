---
layout: Conceptual
title: Install and use packages with CMake | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/vcpkg/get_started/get-started
breadcrumb_path: /vcpkg/breadcrumb/toc.json
feedback_system: OpenSource
feedback_product_url: https://github.com/Microsoft/vcpkg/issues/
ROBOTS: INDEX,FOLLOW
manager: aupopa
ms.date: 2024-07-16T00:00:00.0000000Z
ms.service: vcpkg
ms.topic: tutorial
audience: developer
uhfHeaderId: MSDocsHeader-Vcpkg
ms.workload:
- cplusplus
ms.reviewer:
- aupopa
- viromer
- twhitney
zone_pivot_group_filename: zone-pivot-groups.json
description: Tutorial guides the user through the process of installing and using packages with CMake.
zone_pivot_groups: shell-selections
author: JavierMatosD
ms.author: javiermat
locale: en-us
document_id: 5099d71b-6e6f-f2d6-ab3f-3e8327541245
document_version_independent_id: 5099d71b-6e6f-f2d6-ab3f-3e8327541245
updated_at: 2024-09-25T22:33:00.0000000Z
original_content_git_url: https://github.com/MicrosoftDocs/vcpkg-docs/blob/live/vcpkg/get_started/get-started.md
gitcommit: https://github.com/MicrosoftDocs/vcpkg-docs/blob/21c90d1d849171080142233cd5a7353234135aa4/vcpkg/get_started/get-started.md
git_commit_id: 21c90d1d849171080142233cd5a7353234135aa4
site_name: Docs
depot_name: MSDN.vcpkg-docs
page_type: conceptual
toc_rel: ../toc.json
feedback_help_link_type: ''
feedback_help_link_url: ''
word_count: 894
asset_id: get_started/get-started
moniker_range_name: 
monikers: []
item_type: Content
source_path: vcpkg/get_started/get-started.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/a3955c7b-f5ee-420d-aff5-d7119738f38b
- https://authoring-docs-microsoft.poolparty.biz/devrel/4628cbd9-6f47-4ae1-b371-d34636609eaf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/b31948f4-2f38-404b-ac93-c3c8c5b3ae33
- https://authoring-docs-microsoft.poolparty.biz/devrel/be21deb8-8c64-44b0-b71f-2dc56ca7364f
platformId: 374219ff-604c-3e63-60f0-01a1f03954d5
---

# Install and use packages with CMake | Microsoft Learn

This tutorial shows you how to create a C++ "Hello World" program that uses the `fmt` library with CMake and vcpkg. You'll install dependencies, configure, build, and run a simple application.

## Prerequisites

- A terminal
- A C++ compiler
- [CMake](https://cmake.org/download/)
- [Git](https://git-scm.com/downloads)

::: zone pivot="shell-cmd,shell-powershell"

Note

For Windows users, Visual Studio's MSVC (Microsoft Visual C++ Compiler) is the required compiler for C++ development.

::: zone-end

## 1 - Set up vcpkg

1. Clone the repository

    The first step is to clone the vcpkg repository from GitHub. The repository contains scripts to acquire the vcpkg executable and a registry of curated open-source libraries maintained by the vcpkg community. To do this, run:

    ```console
    git clone https://github.com/microsoft/vcpkg.git
    ```

    The vcpkg curated registry is a set of over 2,000 open-source libraries. These libraries have been validated by vcpkg's continuous integration pipelines to work together. While the vcpkg repository does not contain the source code for these libraries, it holds recipes and metadata to build and install them in your system.
2. Run the bootstrap script

    Now that you have cloned the vcpkg repository, navigate to the `vcpkg` directory and execute the bootstrap script:

::: zone pivot="shell-cmd"

    ```console
    cd vcpkg && bootstrap-vcpkg.bat
    ```

::: zone-end

::: zone pivot="shell-powershell"

    ```console
    cd vcpkg; .\bootstrap-vcpkg.bat
    ```

::: zone-end

::: zone pivot="shell-bash"

    ```console
    cd vcpkg && ./bootstrap-vcpkg.sh
    ```

::: zone-end

    The bootstrap script performs prerequisite checks and downloads the vcpkg executable.

    That's it! vcpkg is set up and ready to use.

## 2 - Set up the project

1. Configure the `VCPKG_ROOT` environment variable.

::: zone pivot="shell-bash"

    ```bash
    export VCPKG_ROOT=/path/to/vcpkg
    export PATH=$VCPKG_ROOT:$PATH
    ```

Note

Setting environment variables using the `export` command only affects the current shell session. To make this change permanent across sessions, add the `export` command to your shell's profile script (e.g., `~/.bashrc` or `~/.zshrc`).

::: zone-end

::: zone pivot="shell-cmd"

    ```console
    set "VCPKG_ROOT=C:\path\to\vcpkg"
    set PATH=%VCPKG_ROOT%;%PATH%
    ```

Note

Setting environment variables in this manner only affects the current terminal session. To make these changes permanent across all sessions, set them through the Windows System Environment Variables panel.

::: zone-end

::: zone pivot="shell-powershell"

    ```powershell
    $env:VCPKG_ROOT = "C:\path\to\vcpkg"
    $env:PATH = "$env:VCPKG_ROOT;$env:PATH"
    ```

Note

Setting environment variables in this manner only affects the current terminal session. To make these changes permanent across all sessions, set them through the Windows System Environment Variables panel.

::: zone-end

    Setting `VCPKG_ROOT` tells vcpkg where your vcpkg instance is located. Adding it to `PATH` ensures you can run vcpkg commands directly from the shell.
2. Create the project directory.

    ```console
    mkdir helloworld && cd helloworld
    ```

## 3 - Add dependencies and project files

1. Create the manifest file and add the `fmt` dependency.

    First, create a manifest file (`vcpkg.json`) in your project's directory by running the [`vcpkg new`](../commands/new) command from within the `helloworld` directory:

    ```console
    vcpkg new --application
    ```

    Next, add the `fmt` dependency:

    ```console
    vcpkg add port fmt
    ```

    Your `vcpkg.json` should look like this:

    ```json
    {
        "dependencies": [
            "fmt"
        ]
    }
    ```

    This is your manifest file. vcpkg reads the manifest file to learn what dependencies to install and integrates with CMake to provide the dependencies required by your project.

    The default `vcpkg-configuration.json` file introduces [baseline](../reference/vcpkg-configuration-json#registry-baseline) constraints, specifying the minimum versions of dependencies that your project should use. While modifying this file is beyond the scope of this tutorial, it plays a crucial role in defining version constraints for your project's dependencies. Therefore, even though it's not strictly necessary for this tutorial, it's a good practice to add `vcpkg-configuration.json` to your source control to ensure version consistency across different development environments.
2. Create the project files.

    Create the `CMakeLists.txt` file with the following content:

    ```cmake
    cmake_minimum_required(VERSION 3.10)
    
    project(HelloWorld)
    
    find_package(fmt CONFIG REQUIRED)
    
    add_executable(HelloWorld helloworld.cpp)
    
    target_link_libraries(HelloWorld PRIVATE fmt::fmt)
    ```

    Now, let's break down what each line in the `CMakeLists.txt` file does:

    - `cmake_minimum_required(VERSION 3.10)`: Specifies that the minimum version of CMake required to build the project is 3.10. If the version of CMake installed on your system is lower than this, an error will be generated.
    - `project(HelloWorld)`: Sets the name of the project to "HelloWorld."
    - `find_package(fmt CONFIG REQUIRED)`: Looks for the `fmt` library using its CMake configuration file. The `REQUIRED` keyword ensures that an error is generated if the package is not found.
    - `add_executable(HelloWorld helloworld.cpp)`: Adds an executable target named "HelloWorld," built from the source file `helloworld.cpp`.
    - `target_link_libraries(HelloWorld PRIVATE fmt::fmt)`: Specifies that the `HelloWorld` executable should link against the `fmt` library. The `PRIVATE` keyword indicates that `fmt` is only needed for building `HelloWorld` and should not propagate to other dependent projects.

    Create the `helloworld.cpp` file with the following content:

    ```cpp
    #include <fmt/core.h>
    
    int main()
    {
        fmt::print("Hello World!\n");
        return 0;
    }
    ```

    In this `helloworld.cpp` file, the `<fmt/core.h>` header is included for using the `fmt` library. The `main()` function then calls `fmt::print()` to output the "Hello World!" message to the console.

## 4 - Build and run the project

1. Run CMake configuration

    CMake can automatically link libraries installed by vcpkg when `CMAKE_TOOLCHAIN_FILE` is set to use [vcpkg's custom toolchain](../users/buildsystems/cmake-integration). This can be acomplished using CMake presets files.

    Create the following files inside the `helloworld` directory:

    `CMakePresets.json`

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

    `CMakeUserPresets.json`

    ```json
    {
      "version": 2,
      "configurePresets": [
        {
          "name": "default",
          "inherits": "vcpkg",
          "environment": {
            "VCPKG_ROOT": "<path to vcpkg>"
          }
        }
      ]
    }
    ```

    The `CMakePresets.json` file contains a single preset named "vcpkg", which sets the `CMAKE_TOOLCHAIN_FILE` variable. The `CMakeUserPresets.json` file sets the `VCPKG_ROOT` environment variable to point to the absolute path containing your local installation of vcpkg. It is recommended to not check `CMakeUserPresets.json` into version control systems.

    Finally, configure the build using CMake:

    ```console
    cmake --preset=default
    ```
2. Build the project

    Run:

    ```console
    cmake --build build
    ```
3. Run the application

    Finally, run the executable to see your application in action:

::: zone pivot="shell-bash"

    ```console
    ./build/HelloWorld
    
    Hello World!
    ```

::: zone-end

::: zone pivot="shell-cmd,shell-powershell"

    ```console
    .\build\HelloWorld.exe
    
    Hello World!
    ```

::: zone-end