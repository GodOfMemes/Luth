set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build static third-party libraries" FORCE)

# Header-only dependencies copied into the repository.
add_library(luth_entt INTERFACE)
add_library(Luth::EnTT ALIAS luth_entt)
target_include_directories(luth_entt INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/source")

add_library(luth_json INTERFACE)
add_library(Luth::Json ALIAS luth_json)
target_include_directories(luth_json INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/source")

add_library(luth_stb INTERFACE)
add_library(Luth::Stb ALIAS luth_stb)
target_include_directories(luth_stb INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/source")

add_library(luth_vma INTERFACE)
add_library(Luth::VMA ALIAS luth_vma)
target_include_directories(luth_vma INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/source/vma/include")
target_link_libraries(luth_vma INTERFACE Vulkan::Headers)

# Assimp: retain the importer subset used by the previous build.
set(ASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT OFF CACHE BOOL "" FORCE)
foreach(importer ASSBIN COLLADA BLEND FBX GLTF IQM OBJ MD5)
    set(ASSIMP_BUILD_${importer}_IMPORTER ON CACHE BOOL "" FORCE)
endforeach()
set(ASSIMP_NO_EXPORT ON CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_SAMPLES OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL OFF CACHE BOOL "" FORCE)
set(ASSIMP_WARNINGS_AS_ERRORS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ZLIB ON CACHE BOOL "" FORCE)
set(ASSIMP_INJECT_DEBUG_POSTFIX OFF CACHE BOOL "" FORCE)
add_subdirectory(source/assimp EXCLUDE_FROM_ALL)
if(MSVC)
    target_compile_options(assimp PRIVATE /EHsc)
endif()

set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_WAYLAND OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_X11 ON CACHE BOOL "" FORCE)
set(USE_MSVC_RUNTIME_LIBRARY_DLL ON CACHE BOOL "" FORCE)
add_subdirectory(source/glfw EXCLUDE_FROM_ALL)

set(GLM_BUILD_LIBRARY OFF CACHE BOOL "" FORCE)
set(GLM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLM_BUILD_INSTALL OFF CACHE BOOL "" FORCE)
set(GLM_ENABLE_CXX_20 ON CACHE BOOL "" FORCE)
add_subdirectory(source/glm EXCLUDE_FROM_ALL)

set(SPDLOG_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(SPDLOG_BUILD_EXAMPLE OFF CACHE BOOL "" FORCE)
set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "" FORCE)
set(SPDLOG_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory(source/spdlog EXCLUDE_FROM_ALL)

set(TRACY_STATIC ON CACHE BOOL "" FORCE)
set(TRACY_ENABLE OFF CACHE BOOL "" FORCE)
set(TRACY_ON_DEMAND OFF CACHE BOOL "" FORCE)
set(TRACY_FIBERS OFF CACHE BOOL "" FORCE)
set(TRACY_LTO OFF CACHE BOOL "" FORCE)
add_subdirectory(source/tracy EXCLUDE_FROM_ALL)
target_compile_definitions(TracyClient
    PUBLIC "$<$<AND:$<OR:$<CONFIG:Debug>,$<CONFIG:Release>>,$<NOT:$<BOOL:${LUTH_ENABLE_ASAN}>>>:TRACY_ENABLE;TRACY_ON_DEMAND>"
    PRIVATE "$<$<AND:$<OR:$<CONFIG:Debug>,$<CONFIG:Release>>,$<NOT:$<BOOL:${LUTH_ENABLE_ASAN}>>>:TRACY_FIBERS>"
)

set(SPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS ON CACHE BOOL "" FORCE)
set(SPIRV_CROSS_SHARED OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_STATIC ON CACHE BOOL "" FORCE)
set(SPIRV_CROSS_CLI OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_TESTS OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_GLSL ON CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_HLSL OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_MSL OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_CPP OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_REFLECT OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_C_API OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_ENABLE_UTIL OFF CACHE BOOL "" FORCE)
set(SPIRV_CROSS_SKIP_INSTALL ON CACHE BOOL "" FORCE)
add_subdirectory(source/spirv-cross EXCLUDE_FROM_ALL)

set(USE_ASSERTS OFF CACHE BOOL "" FORCE)
set(OVERRIDE_CXX_FLAGS OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(INTERPROCEDURAL_OPTIMIZATION OFF CACHE BOOL "" FORCE)
set(FLOATING_POINT_EXCEPTIONS_ENABLED OFF CACHE BOOL "" FORCE)
set(ENABLE_ALL_WARNINGS OFF CACHE BOOL "" FORCE)
set(DEBUG_RENDERER_IN_DEBUG_AND_RELEASE OFF CACHE BOOL "" FORCE)
set(PROFILER_IN_DEBUG_AND_RELEASE OFF CACHE BOOL "" FORCE)
set(ENABLE_OBJECT_STREAM OFF CACHE BOOL "" FORCE)
set(ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(USE_STATIC_MSVC_RUNTIME_LIBRARY OFF CACHE BOOL "" FORCE)
set(JPH_ENABLE_VULKAN OFF CACHE BOOL "" FORCE)
set(USE_SSE4_1 ON CACHE BOOL "" FORCE)
set(USE_SSE4_2 ON CACHE BOOL "" FORCE)
set(USE_AVX ON CACHE BOOL "" FORCE)
set(USE_AVX2 ON CACHE BOOL "" FORCE)
set(USE_LZCNT ON CACHE BOOL "" FORCE)
set(USE_TZCNT ON CACHE BOOL "" FORCE)
set(USE_F16C ON CACHE BOOL "" FORCE)
set(USE_FMADD ON CACHE BOOL "" FORCE)
add_subdirectory(source/jolt/Build EXCLUDE_FROM_ALL)
target_compile_definitions(Jolt PUBLIC
    "$<$<CONFIG:Debug>:JPH_ENABLE_ASSERTS;JPH_DEBUG_RENDERER>"
    "$<$<CONFIG:Release>:JPH_DEBUG_RENDERER;NDEBUG>"
    "$<$<CONFIG:Dist>:NDEBUG>"
)
# Jolt publishes its C++ compiler flags. Guard them so they are not forwarded to
# the MASM source in Luth when the target is linked transitively.
get_target_property(jolt_interface_options Jolt INTERFACE_COMPILE_OPTIONS)
if(jolt_interface_options)
    set_property(TARGET Jolt PROPERTY INTERFACE_COMPILE_OPTIONS "")
    foreach(option IN LISTS jolt_interface_options)
        target_compile_options(Jolt INTERFACE "$<$<COMPILE_LANGUAGE:CXX>:${option}>")
    endforeach()
endif()

# Libraries without upstream CMake projects.
add_library(imgui STATIC
    source/imgui/imgui.cpp
    source/imgui/imgui_demo.cpp
    source/imgui/imgui_draw.cpp
    source/imgui/imgui_tables.cpp
    source/imgui/imgui_widgets.cpp
    source/imgui/backends/imgui_impl_glfw.cpp
    source/imgui/backends/imgui_impl_vulkan.cpp
)
add_library(ImGui::ImGui ALIAS imgui)
target_compile_features(imgui PUBLIC cxx_std_17)
target_include_directories(imgui PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/source/imgui")
target_link_libraries(imgui PUBLIC glfw Vulkan::Vulkan)

add_library(imguizmo STATIC
    source/imguizmo/ImGuizmo.cpp
    source/imguizmo/GraphEditor.cpp
)
add_library(ImGuizmo::ImGuizmo ALIAS imguizmo)
target_compile_features(imguizmo PUBLIC cxx_std_20)
target_compile_definitions(imguizmo PRIVATE IMGUI_DEFINE_MATH_OPERATORS)
target_include_directories(imguizmo PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/source/imguizmo")
target_link_libraries(imguizmo PUBLIC ImGui::ImGui)

add_library(bc7enc STATIC source/bc7enc/bc7enc.cpp source/bc7enc/rgbcx.cpp)
add_library(bc7enc::bc7enc ALIAS bc7enc)
target_compile_features(bc7enc PUBLIC cxx_std_20)
target_include_directories(bc7enc PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/source/bc7enc")
if(NOT MSVC)
    # MSVC Debug builds enable /RTC1, which cannot be combined with /O2.
    target_compile_options(bc7enc PRIVATE "$<$<CONFIG:Debug>:-O3>")
endif()

# Pinned Slang 2026.1 binary SDK, kept separate from the system Vulkan SDK.
add_library(luth_slang_compiler SHARED IMPORTED GLOBAL)
add_library(Slang::Compiler ALIAS luth_slang_compiler)
set_target_properties(luth_slang_compiler PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/source/slang/include"
)
if(WIN32)
    set(slang_dir "${CMAKE_CURRENT_SOURCE_DIR}/source/slang/lib/windows")
    set_target_properties(luth_slang_compiler PROPERTIES
        IMPORTED_LOCATION "${slang_dir}/slang-compiler.dll"
        IMPORTED_IMPLIB "${slang_dir}/slang-compiler.lib"
    )
    set(LUTH_SLANG_RUNTIME_FILES
        "${slang_dir}/slang-compiler.dll"
        "${slang_dir}/slang-glslang.dll"
        "${slang_dir}/slang-glsl-module.dll"
        "${slang_dir}/slang-rt.dll"
        CACHE INTERNAL "Pinned Slang runtime files"
    )
else()
    set(slang_dir "${CMAKE_CURRENT_SOURCE_DIR}/source/slang/lib/linux")
    set_target_properties(luth_slang_compiler PROPERTIES
        IMPORTED_LOCATION "${slang_dir}/libslang-compiler.so.0.2026.1.2"
        IMPORTED_NO_SONAME TRUE
    )
    set(LUTH_SLANG_RUNTIME_FILES
        "${slang_dir}/libslang-compiler.so.0.2026.1.2"
        "${slang_dir}/libslang-glslang-2026.1.2.so"
        "${slang_dir}/libslang-glsl-module-2026.1.2.so"
        "${slang_dir}/libslang-rt.so.0.2026.1.2"
        CACHE INTERNAL "Pinned Slang runtime files"
    )
endif()

foreach(target assimp glfw glm-header-only spdlog_header_only TracyClient spirv-cross-core spirv-cross-glsl Jolt imgui imguizmo bc7enc)
    if(TARGET ${target})
        set_property(TARGET ${target} PROPERTY FOLDER "Luth/Extern")
    endif()
endforeach()
