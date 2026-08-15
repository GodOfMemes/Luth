#pragma once

#include "luth/core/types/LuthTypes.h"

namespace Luth
{
    enum class RenderFeatures
    {
        None = 0,
        RayTracing = 1 << 0
    };

    constexpr RenderFeatures operator|(RenderFeatures lhs, RenderFeatures rhs) noexcept
    {
        using T = std::underlying_type_t<RenderFeatures>;
        return static_cast<RenderFeatures>(
            static_cast<T>(lhs) | static_cast<T>(rhs)
        );
    }

    constexpr RenderFeatures operator&(RenderFeatures lhs, RenderFeatures rhs) noexcept
    {
        using T = std::underlying_type_t<RenderFeatures>;
        return static_cast<RenderFeatures>(
            static_cast<T>(lhs) & static_cast<T>(rhs)
        );
    }

    constexpr RenderFeatures operator^(RenderFeatures lhs, RenderFeatures rhs) noexcept
    {
        using T = std::underlying_type_t<RenderFeatures>;
        return static_cast<RenderFeatures>(
            static_cast<T>(lhs) ^ static_cast<T>(rhs)
        );
    }

    constexpr RenderFeatures operator~(RenderFeatures value) noexcept
    {
        using T = std::underlying_type_t<RenderFeatures>;
        return static_cast<RenderFeatures>(~static_cast<T>(value));
    }

    constexpr RenderFeatures& operator|=(RenderFeatures& lhs, RenderFeatures rhs) noexcept
    {
        return lhs = lhs | rhs;
    }

    constexpr RenderFeatures& operator&=(RenderFeatures& lhs, RenderFeatures rhs) noexcept
    {
        return lhs = lhs & rhs;
    }

    constexpr RenderFeatures& operator^=(RenderFeatures& lhs, RenderFeatures rhs) noexcept
    {
        return lhs = lhs ^ rhs;
    }

    constexpr bool HasFlag(RenderFeatures value, RenderFeatures flag) noexcept
    {
        return (value & flag) == flag;
    }
}