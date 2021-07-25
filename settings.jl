mutable struct Settings
    width::Int64
    height::Int64
    left::Float64
    right::Float64
    top::Float64
    bottom::Float64
    maxiter::Int64
    threshold::Float64
    z0::ComplexF64
    fn::Function
    transform::Function
    inv_transform::Function
    type::Symbol
    block_size::Tuple{Int64, Int64}
    mirror_x::Bool
    mirror_y::Bool
    data_type::Type
end

function Settings(;
    width::Int64=1920,
    height::Int64=1080,
    left::Float64=-2.0,
    right::Float64=2.0,
    top::Float64=2.0,
    bottom::Float64=-2.0,
    maxiter::Int64=100,
    threshold::Float64=2.0,
    z0::ComplexF64=0.0+0.0im,
    fn::Function=(zn, c) -> zn^2 + c,
    transform::Function=identity,
    inv_transform::Function=identity,
    type::Symbol=:mand,
    block_size::Tuple{Int64, Int64}=(512, 512),
    mirror_x::Bool=false,
    mirror_y::Bool=false,
    data_type::Type=Float32,
)
    return Settings(
        width,
        height,
        left,
        right,
        top,
        bottom,
        maxiter,
        threshold,
        z0,
        fn,
        transform,
        inv_transform,
        type,
        block_size,
        mirror_x,
        mirror_y,
        data_type,
    )
end

presets = Dict(
    :throne => Settings(1000, 1000, -2.4, 2.4, 2.4, -2.4, 500, 2, 0, (zn, c) -> zn^2+c, z -> tan(acos(z))^2, z -> cos(atan(sqrt(z))), :buddha, (256, 256), true, true, Float32)
)
