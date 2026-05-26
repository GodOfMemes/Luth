#include "luthpch.h"
#include "luth/jobs/FiberStackAllocator.h"
#include "luth/core/diagnostics/Log.h"

#ifdef _WIN32
#include <windows.h>
#else
#include <cerrno>
#include <sys/mman.h>
#endif

namespace Luth::JobSystem
{
    // 16 KB guard at the low end. Single 4 KB page would fault on most overflows but
    // a leaf with a large alloca could jump past it; 4 pages gives the fault detector
    // enough cushion without meaningfully eating into the per-fiber footprint.
    static constexpr size_t kGuardSize = 16 * 1024;

    FiberStack AllocateFiberStack(size_t usableSize)
    {
        FiberStack s{};

        const size_t totalSize = usableSize + kGuardSize;
        #ifdef _WIN32
        void* region = ::VirtualAlloc(nullptr, totalSize,
                                       MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
        if (!region)
        {
            LH_CORE_CRITICAL("VirtualAlloc failed for fiber stack ({0} bytes); err {1}",
                             totalSize, ::GetLastError());
            return s;
        }

        DWORD oldProtect = 0;
        if (!::VirtualProtect(region, kGuardSize, PAGE_NOACCESS, &oldProtect))
        {
            LH_CORE_CRITICAL("VirtualProtect failed for fiber stack guard; err {0}",
                             ::GetLastError());
            ::VirtualFree(region, 0, MEM_RELEASE);
            return s;
        }
        #else
        void* region = mmap(nullptr, totalSize, PROT_READ | PROT_WRITE,
                              MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (region == MAP_FAILED)
        {
            LH_CORE_CRITICAL("mmap failed for fiber stack ({0} bytes); err {1}",
                             totalSize, static_cast<unsigned long>(errno));
            return s;
        }

        if (mprotect(region, kGuardSize, PROT_NONE) != 0)
        {
            LH_CORE_CRITICAL("mprotect failed for fiber stack guard; err {0}",
                             static_cast<unsigned long>(errno));
            munmap(region, totalSize);
            return s;
        }
        #endif
        s.Region       = region;
        s.RegionSize   = totalSize;
        s.UsableBottom = static_cast<u8*>(region) + kGuardSize;
        s.UsableSize   = usableSize;
        s.StackTop     = static_cast<u8*>(region) + totalSize;

        return s;
    }

    void FreeFiberStack(FiberStack& stack)
    {
        if (stack.Region)
        {
            #if defined(_WIN32)
            ::VirtualFree(stack.Region, 0, MEM_RELEASE);
            #else
            munmap(stack.Region, stack.RegionSize);
            #endif
        }
        stack = {};
    }
}
