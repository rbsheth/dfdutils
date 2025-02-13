# Copyright 2015-2020 The Khronos Group Inc.
# SPDX-License-Identifier: Apache-2.0

# Code generation scripts that require a Vulkan SDK installation

set(skip_mkvk_message "-> skipping mkvk target (this is harmless; only needed when re-generating of vulkan headers and dfdutils is required)")

find_package(Bash REQUIRED)
find_package(Perl)

if(NOT PERL_FOUND)
    message(FATAL ERROR "Perl not found, can't generate Vulkan sources!")
endif()

# What a shame! We have to duplicate most of the build commands because
# CMake's generator expressions don't handle empty strings well cross-platform (ex. Xcode fails on "" but Makefiles succeed).

# Hunter DataFormat source is already patched
if(NOT HUNTER_ENABLED)
    list(APPEND mkvkpatchdataformatsources_input
        "${DataFormat_INCLUDE_DIR}/KHR/khr_df.h")
    list(APPEND mkvkpatchdataformatsources_output
        "${GENERATED_DIR}/KHR/khr_df.h")

    if(BUILD_FOR_LIBKTX)
        if(CMAKE_HOST_WIN32)
            add_custom_command(OUTPUT ${mkvkpatchdataformatsources_output}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
                COMMAND ${CMAKE_COMMAND} -E copy "${DataFormat_INCLUDE_DIR}/KHR/khr_df.h" "${GENERATED_DIR}/KHR/khr_df.h"
                COMMAND ${BASH_EXECUTABLE} -c "patch -p2 -N -i ${PROJECT_SOURCE_DIR}/third_party/khr_df.patch || true"
                DEPENDS ${mkvkpatchdataformatsources_input}
                WORKING_DIRECTORY ${GENERATED_DIR}
                COMMENT "Patching DataFormat header"
                VERBATIM
            )
        else()
            add_custom_command(OUTPUT ${mkvkpatchdataformatsources_output}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
                COMMAND ${CMAKE_COMMAND} -E copy "${DataFormat_INCLUDE_DIR}/KHR/khr_df.h" "${GENERATED_DIR}/KHR/khr_df.h"
                COMMAND patch -p2 -N -i ${PROJECT_SOURCE_DIR}/third_party/khr_df.patch || true
                DEPENDS ${mkvkpatchdataformatsources_input}
                WORKING_DIRECTORY ${GENERATED_DIR}
                COMMENT "Patching DataFormat header"
                VERBATIM
            )
        endif()
    else()
            add_custom_command(OUTPUT ${mkvkpatchdataformatsources_output}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
                COMMAND ${CMAKE_COMMAND} -E copy "${DataFormat_INCLUDE_DIR}/KHR/khr_df.h" "${GENERATED_DIR}/KHR/khr_df.h"
                DEPENDS ${mkvkpatchdataformatsources_input}
                WORKING_DIRECTORY ${GENERATED_DIR}
                COMMENT "Copying DataFormat header"
                VERBATIM
            )
    endif()

    add_custom_target(mkvkpatchdataformatsources
        DEPENDS ${mkvkpatchdataformatsources_output}
        SOURCES ${mkvkpatchdataformatsources_input}
    )
endif()

list(APPEND mkvkpatchvulkansources_input
    "${Vulkan_INCLUDE_DIR}/vulkan/vulkan_core.h"
    "${Vulkan_INCLUDE_DIR}/vulkan/vk_platform.h")
list(APPEND mkvkpatchvulkansources_output
    "${GENERATED_DIR}/vulkan/vulkan_core.h"
    "${GENERATED_DIR}/vulkan/vk_platform.h")

    if(BUILD_FOR_LIBKTX)
        if(CMAKE_HOST_WIN32)
            add_custom_command(OUTPUT ${mkvkpatchvulkansources_output}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
                COMMAND ${CMAKE_COMMAND} -E copy "${Vulkan_INCLUDE_DIR}/vulkan/vk_platform.h" "${GENERATED_DIR}/vulkan/vk_platform.h"
                COMMAND ${CMAKE_COMMAND} -E copy "${Vulkan_INCLUDE_DIR}/vulkan/vulkan_core.h" "${GENERATED_DIR}/vulkan/vulkan_core.h"
                COMMAND ${BASH_EXECUTABLE} -c "patch -p2 -N -i ${PROJECT_SOURCE_DIR}/third_party/vulkan_core.patch || true"
                DEPENDS ${mkvkpatchvulkansources_input}
                WORKING_DIRECTORY ${GENERATED_DIR}
                COMMENT "Patching Vulkan headers"
                VERBATIM
            )
        else()
            add_custom_command(OUTPUT ${mkvkpatchvulkansources_output}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
                COMMAND ${CMAKE_COMMAND} -E copy "${Vulkan_INCLUDE_DIR}/vulkan/vk_platform.h" "${GENERATED_DIR}/vulkan/vk_platform.h"
                COMMAND ${CMAKE_COMMAND} -E copy "${Vulkan_INCLUDE_DIR}/vulkan/vulkan_core.h" "${GENERATED_DIR}/vulkan/vulkan_core.h"
                COMMAND patch -p2 -N -i ${PROJECT_SOURCE_DIR}/third_party/vulkan_core.patch || true
                DEPENDS ${mkvkpatchvulkansources_input}
                WORKING_DIRECTORY ${GENERATED_DIR}
                COMMENT "Patching Vulkan headers"
                VERBATIM
            )
        endif()
    else()
            add_custom_command(OUTPUT ${mkvkpatchvulkansources_output}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
                COMMAND ${CMAKE_COMMAND} -E copy "${Vulkan_INCLUDE_DIR}/vulkan/vk_platform.h" "${GENERATED_DIR}/vulkan/vk_platform.h"
                COMMAND ${CMAKE_COMMAND} -E copy "${Vulkan_INCLUDE_DIR}/vulkan/vulkan_core.h" "${GENERATED_DIR}/vulkan/vulkan_core.h"
                DEPENDS ${mkvkpatchvulkansources_input}
                WORKING_DIRECTORY ${GENERATED_DIR}
                COMMENT "Copying Vulkan headers"
                VERBATIM
            )
    endif()

add_custom_target(mkvkpatchvulkansources
    DEPENDS ${mkvkpatchvulkansources_output}
    SOURCES ${mkvkpatchvulkansources_input}
)

list(APPEND mkvkformatfiles_input
    "${GENERATED_DIR}/vulkan/vulkan_core.h"
    "${PROJECT_SOURCE_DIR}/cmake/mkvkformatfiles")
list(APPEND mkvkformatfiles_output
    "${GENERATED_DIR}/vkformat_enum.h"
    "${GENERATED_DIR}/vkformat_check.c"
    "${GENERATED_DIR}/vkformat_str.c")

if(CMAKE_HOST_WIN32)
    add_custom_command(OUTPUT ${mkvkformatfiles_output}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
        COMMAND ${BASH_EXECUTABLE} -c "Vulkan_INCLUDE_DIR=${GENERATED_DIR} ${PROJECT_SOURCE_DIR}/cmake/mkvkformatfiles ${GENERATED_DIR}"
        COMMAND ${BASH_EXECUTABLE} -c "unix2dos ${GENERATED_DIR}/vkformat_enum.h"
        COMMAND ${BASH_EXECUTABLE} -c "unix2dos ${GENERATED_DIR}/vkformat_check.c"
        COMMAND ${BASH_EXECUTABLE} -c "unix2dos ${GENERATED_DIR}/vkformat_str.c"
        DEPENDS ${mkvkformatfiles_input}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Generating VkFormat-related source files"
        VERBATIM
    )
else()
    add_custom_command(OUTPUT ${mkvkformatfiles_output}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
        COMMAND Vulkan_INCLUDE_DIR=${GENERATED_DIR} ${PROJECT_SOURCE_DIR}/cmake/mkvkformatfiles ${GENERATED_DIR}
        DEPENDS ${mkvkformatfiles_input}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Generating VkFormat-related source files"
        VERBATIM
    )
endif()

add_custom_target(mkvkformatfiles
    DEPENDS ${mkvkformatfiles_output}
    SOURCES ${mkvkformatfiles_input}
)

list(APPEND makevkswitch_input
    "${GENERATED_DIR}/vkformat_enum.h"
    "${PROJECT_SOURCE_DIR}/makevkswitch.pl")
set(makevkswitch_output
    "${GENERATED_DIR}/vk2dfd.inl")

if(CMAKE_HOST_WIN32)
    add_custom_command(
        OUTPUT ${makevkswitch_output}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
        COMMAND ${PERL_EXECUTABLE} makevkswitch.pl ${GENERATED_DIR}/vkformat_enum.h ${GENERATED_DIR}/vk2dfd.inl
        COMMAND ${BASH_EXECUTABLE} -c "unix2dos ${GENERATED_DIR}/vk2dfd.inl"
        DEPENDS ${makevkswitch_input}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Generating VkFormat/DFD switch body"
        VERBATIM
    )
else()
    add_custom_command(
        OUTPUT ${makevkswitch_output}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
        COMMAND ${PERL_EXECUTABLE} makevkswitch.pl ${GENERATED_DIR}/vkformat_enum.h ${GENERATED_DIR}/vk2dfd.inl
        DEPENDS ${makevkswitch_input}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Generating VkFormat/DFD switch body"
        VERBATIM
    )
endif()

add_custom_target(makevkswitch
    DEPENDS ${makevkswitch_output}
    SOURCES ${makevkswitch_input}
)


list(APPEND makedfd2vk_input
    "${GENERATED_DIR}/vkformat_enum.h"
    "makedfd2vk.pl")
list(APPEND makedfd2vk_output
    "${GENERATED_DIR}/dfd2vk.inl")

if(CMAKE_HOST_WIN32)
    add_custom_command(
        OUTPUT ${makedfd2vk_output}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
        COMMAND ${PERL_EXECUTABLE} makedfd2vk.pl ${GENERATED_DIR}/vkformat_enum.h ${GENERATED_DIR}/dfd2vk.inl
        COMMAND ${BASH_EXECUTABLE} -c "unix2dos ${GENERATED_DIR}/dfd2vk.inl"
        DEPENDS ${makedfd2vk_input}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Generating DFD/VkFormat switch body"
        VERBATIM
    )
else()
    add_custom_command(
        OUTPUT ${makedfd2vk_output}
        COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_DIR}"
        COMMAND ${PERL_EXECUTABLE} makedfd2vk.pl ${GENERATED_DIR}/vkformat_enum.h ${GENERATED_DIR}/dfd2vk.inl
        DEPENDS ${makedfd2vk_input}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Generating DFD/VkFormat switch body"
        VERBATIM
    )
endif()

add_custom_target(makedfd2vk
    DEPENDS ${makedfd2vk_output}
    SOURCES ${makedfd2vk_input}
)

add_custom_target(mkvk SOURCES ${CMAKE_CURRENT_LIST_FILE})

if(NOT HUNTER_ENABLED)
    add_dependencies(mkvk
        mkvkpatchdataformatsources
    )
endif()

add_dependencies(mkvk
    mkvkpatchvulkansources
    mkvkformatfiles
    makevkswitch
    makedfd2vk
)
