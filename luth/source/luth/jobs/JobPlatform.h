#pragma once

#include "luth/core/types/LuthTypes.h"

#include <atomic>
#include <cstddef>
#include <cstdint>

#ifdef _WIN32
#include <intrin.h>
#include <windows.h>
#pragma comment(lib, "Synchronization.lib")
#else
#include <climits>
#include <cerrno>
#include <linux/futex.h>
#include <pthread.h>
#include <sys/syscall.h>
#include <time.h>
#include <unistd.h>
#endif

namespace Luth::JobSystem
{
    struct JobContext;
}

namespace Luth::JobSystem::Platform
{
#ifndef _WIN32
    inline pthread_key_t& ContextKeyStorage()
    {
        static pthread_key_t key;
        return key;
    }

    inline bool& ContextKeyCreatedStorage()
    {
        static bool created = false;
        return created;
    }
#endif

    inline bool InitializeContextStorage()
    {
    #ifdef _WIN32
        return true;
    #else
        pthread_key_t& key = ContextKeyStorage();
        bool& created = ContextKeyCreatedStorage();
        if (!created)
        {
            if (pthread_key_create(&key, nullptr) != 0)
                return false;
            created = true;
        }
        return true;
    #endif
    }

    inline void ShutdownContextStorage()
    {
    #ifndef _WIN32
        bool& created = ContextKeyCreatedStorage();
        if (created)
        {
            pthread_key_delete(ContextKeyStorage());
            created = false;
        }
    #endif
    }

    inline void SetCurrentContext(JobContext* ctx)
    {
    #ifdef _WIN32
        __writegsqword(0x28, reinterpret_cast<uintptr_t>(ctx));
    #else
        pthread_setspecific(ContextKeyStorage(), ctx);
    #endif
    }

    inline JobContext* GetCurrentContext()
    {
    #ifdef _WIN32
        return reinterpret_cast<JobContext*>(__readgsqword(0x28));
    #else
        return static_cast<JobContext*>(pthread_getspecific(ContextKeyStorage()));
    #endif
    }

    inline void WakeByAddressSingle(std::atomic<u32>* address)
    {
    #ifdef _WIN32
        ::WakeByAddressSingle(address);
    #else
        auto* addr = reinterpret_cast<int*>(address);
        syscall(SYS_futex, addr, FUTEX_WAKE_PRIVATE, 1, nullptr, nullptr, 0);
    #endif
    }

    inline void WakeByAddressAll(std::atomic<u32>* address)
    {
    #ifdef _WIN32
        ::WakeByAddressAll(address);
    #else
        auto* addr = reinterpret_cast<int*>(address);
        syscall(SYS_futex, addr, FUTEX_WAKE_PRIVATE, INT_MAX, nullptr, nullptr, 0);
    #endif
    }

    inline void WaitOnAddress(std::atomic<u32>* address, const u32* compare, size_t size, u32 timeoutMs)
    {
    #ifdef _WIN32
        ::WaitOnAddress(address, compare, size, timeoutMs);
    #else
        (void)size;
        timespec timeout{};
        timeout.tv_sec = timeoutMs / 1000;
        timeout.tv_nsec = static_cast<long>(timeoutMs % 1000) * 1000000L;
        auto* addr = reinterpret_cast<int*>(address);
        syscall(SYS_futex, addr, FUTEX_WAIT_PRIVATE, static_cast<int>(*compare), &timeout, nullptr, 0);
    #endif
    }
}
