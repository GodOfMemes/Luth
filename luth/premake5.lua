project "Luth"
   kind "StaticLib"
   language "C++"
   cppdialect "C++20"

   targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.name}")
	objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.name}")

   pchheader "luthpch.h"
   pchsource "source/luthpch.cpp"

   filter "toolset:msc*"
      buildoptions { "/utf-8" }
   filter "system:linux"
      defines { "STBI_NO_SIMD" }
      buildoptions { "-march=x86-64-v3" }
   filter {}

   defines
   {
      "GLFW_INCLUDE_NONE",
      "FMT_HEADER_ONLY=1",
      "SPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS",
      -- Jolt instruction-set defines (must mirror luth/extern/premake5-jolt.lua so
      -- Jolt headers compile consistently across the lib and its consumers)
      "JPH_USE_AVX2",
      "JPH_USE_AVX",
      "JPH_USE_SSE4_1",
      "JPH_USE_SSE4_2",
      "JPH_USE_FMADD",
      "JPH_USE_F16C",
      "JPH_USE_LZCNT",
      "JPH_USE_TZCNT"
   }

   files
   {
      "source/**.h",
      "source/**.cpp",
      "source/**.asm",
   }

   filter "system:windows"
      removefiles { "source/luth/platform/LinWindow.cpp" }
   filter "system:linux"
      removefiles { "source/luth/platform/WinWindow.cpp" }
   filter {}
   
   includedirs
   {
      "source",
      "extern/source",
      "extern/config-headers",
      IncludeDir["assimp"],
      IncludeDir["glfw"],
      IncludeDir["glm"],
      IncludeDir["imgui"],
      IncludeDir["imguizmo"],
      IncludeDir["spdlog"],
      IncludeDir["tracy"],
      IncludeDir["vulkan"],
      IncludeDir["spirv_cross"],
      IncludeDir["jolt"]
   }

   libdirs
   {
      "extern/source/vulkan/lib",
   }

   local vulkanSDK = os.getenv("VULKAN_SDK")
   if vulkanSDK then
      libdirs 
      { 
         vulkanSDK .. "/Lib",
         vulkanSDK .. "/lib" 
      }
   end

   links
   {
      "assimp",
      "glfw",
      "glm",
      "imgui",
      "ImGuizmo",
      "Tracy",
      --"vulkan-1",
      "shaderc_shared",
      "spirv-cross",
      "Jolt",
      --"ws2_32",
      --"dbghelp"
   }

   filter "system:windows"
      links { "vulkan-1", "ws2_32", "dbghelp" }
   filter "system:linux"
      links { "vulkan" }
   filter {}

   filter "configurations:Debug"
      defines { "LUTH_BUILD_DEBUG", "TRACY_ENABLE", "TRACY_ON_DEMAND",
                "JPH_ENABLE_ASSERTS", "JPH_DEBUG_RENDERER" }
      runtime "Debug"
      symbols "on"

   filter "configurations:Release"
      defines { "LUTH_BUILD_RELEASE", "TRACY_ENABLE", "TRACY_ON_DEMAND",
                "JPH_DEBUG_RENDERER", "NDEBUG" }
      runtime "Release"
      optimize "on"

   filter "configurations:Dist"
      defines { "LUTH_BUILD_DIST", "NDEBUG" }
      runtime "Release"
      optimize "on"

   -- DebugASan: debug-style defines + Release CRT + /fsanitize=address. MSVC's Debug CRT
   -- is incompatible with ASan; Release CRT is mandatory. Requires MSVC 16.9+.
   filter "configurations:DebugASan"
      defines { "LUTH_BUILD_DEBUG", "TRACY_ENABLE", "TRACY_ON_DEMAND",
                "JPH_ENABLE_ASSERTS", "JPH_DEBUG_RENDERER" }
      symbols "on"
   filter { "configurations:DebugASan", "toolset:msc*" }
      runtime "Release"
      editandcontinue "Off"
      buildoptions {
         "/fsanitize=address"
      }

   filter { "configurations:DebugASan", "system:linux" }
      runtime "Release"
      buildoptions {
         "-fsanitize=address",
         "-fno-omit-frame-pointer"
      }
      linkoptions {
         "-fsanitize=address"
      }

   filter {}
