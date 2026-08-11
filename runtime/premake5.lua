project "Runtime"
   kind "ConsoleApp"
   language "C++"
   cppdialect "C++20"
   targetname "Luthien"

   targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.name}")
	objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.name}")

   filter "toolset:msc*"
      buildoptions { "/utf-8" }
   filter {}

   defines
   {
      "GLFW_INCLUDE_NONE",
      "FMT_HEADER_ONLY=1"
   }

   files
   {
      "source/**.h",
      "source/**.cpp"
   }

   filter "system:windows"
      files
      {
         "resource.h",
         "Luthien.rc",
         "icons/Luth.ico"
      }
   filter {}

   includedirs
   {
      "source",
      "%{wks.location}/luth/source",
      "%{wks.location}/luthien/source",
      "%{wks.location}/luth/extern/source",
      "%{wks.location}/luth/extern/config-headers",
      IncludeDir["assimp"],
      IncludeDir["glfw"],
      IncludeDir["glm"],
      IncludeDir["imgui"],
      IncludeDir["spdlog"],
      IncludeDir["vulkan"]
   }

   libdirs
   {
      LibraryDir["vulkan"]
   }

   -- Stage the optional Aftermath DLL next to Luthien.exe so the runtime loads it by name (mirrors the
   -- Slang copies above). Only when AFTERMATH_SDK is set; the build is otherwise Aftermath-free.
   local aftermathSDK = os.getenv("AFTERMATH_SDK")
   if aftermathSDK then
      postbuildcommands { "{COPY} " .. aftermathSDK:gsub("\\", "/") .. "/lib/x64/GFSDK_Aftermath_Lib.x64.dll %{cfg.targetdir}" }
   end

   links
   {
      "LuthienLib",
      "Luth",

      "assimp",
      "glfw",
      "glm",
      "imgui",
      "ImGuizmo",
      "Tracy",
      "spirv-cross",
      "Jolt",

      --"vulkan-1",
      --"shaderc_shared"
      --"Luthien",
      --"vulkan-1"
   }

   filter "system:windows"
      links { "vulkan-1" }
      postbuildcommands
      {
         -- Slang in-process compiler — the engine's only shader backend. slang-compiler.dll is the
         -- post-rename real compiler; it LoadLibrary's its siblings on demand, so stage all four.
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/slang-compiler.dll %{cfg.targetdir}",
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/slang-glslang.dll %{cfg.targetdir}",
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/slang-glsl-module.dll %{cfg.targetdir}",
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/slang-rt.dll %{cfg.targetdir}"
      }
   filter "system:linux"
      links { "vulkan", "dl", "pthread" }
      linkoptions
      {
         "-L" .. LibraryDir["vulkan"],
         "-Wl,-rpath-link," .. LibraryDir["vulkan"],
         "-l:libslang-compiler.so.0.2026.1.2",
         "-Wl,-rpath,'$$ORIGIN'"
      }
      postbuildcommands
      {
         -- Slang in-process compiler — the engine's only shader backend. libslang-compiler.so is the
         -- post-rename real compiler; it LoadLibrary's its siblings on demand, so stage all four.
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/libslang-compiler.so.0.2026.1.2 %{cfg.targetdir}",
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/libslang-glslang-2026.1.2.so %{cfg.targetdir}",
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/libslang-glsl-module-2026.1.2.so %{cfg.targetdir}",
         "{COPYFILE} " .. LibraryDir["vulkan"] .. "/libslang-rt.so.0.2026.1.2 %{cfg.targetdir}"
      }
   filter {}

   filter "configurations:Debug"
      defines { "LUTH_BUILD_DEBUG", "TRACY_ENABLE", "TRACY_FIBERS", "TRACY_ON_DEMAND" }
      runtime "Debug"
      symbols "on"

   filter "configurations:Release"
      defines { "LUTH_BUILD_RELEASE", "TRACY_ENABLE", "TRACY_FIBERS", "TRACY_ON_DEMAND" }
      runtime "Release"
      optimize "on"

   filter "configurations:Dist"
      defines { "LUTH_BUILD_DIST" }
      runtime "Release"
      optimize "on"
      
