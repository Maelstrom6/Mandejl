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
    colour_scheme::Int64
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
    block_size::Tuple{Int64, Int64}=(256, 256),
    mirror_x::Bool=false,
    mirror_y::Bool=false,
    data_type::Type=Float32,
    colour_scheme::Int64=0,
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
        colour_scheme,
    )
end

# Warning: when changing fn to something other than the regular,
# increasing the threshold is usually required
# however, there is a small chance that it may lead to illegal memory addresses
# since exp(exp(100)) is not possible to be held inside Float64.
presets = Dict(
    # mine
    :throne => Settings(1000, 1000, -2.4, 2.4, 2.4, -2.4, 500, 2, 0, (zn, c) -> zn^2+c, z -> tan(acos(z))^2, z -> cos(atan(sqrt(z))), :buddha, (256, 256), true, true, Float32, 0),
    :box => Settings(2000, 1000, -4, 4, 2, -2, 500, 2, 0, (zn, c) -> zn^2 + c, z -> tan(asin(z))^2, z -> sin(atan(sqrt(z))), :buddha, (256, 256), true, true, Float32, 0),
    :cave => Settings(1000, 1000, -4, 4, 4, -4, 500, 2, 0, (zn, c) -> zn^2+c, z -> 1/z, z -> 1/z, :buddha, (256, 256), true, false, Float32, 0),
    :tree => Settings(1000, 1000, -4, 4, 4, -4, 500, 2, 0, (zn, c) -> zn^2+c, z -> atan(sin(exp(z))), z -> log(asin(tan(z))), :mand, (256, 256), true, false, Float32, 0),
    :spider => Settings(1000, 1000, -16, 16, 16, -16, 500, 2, 0, (zn, c) -> zn^2+c, z -> log(z)/6, z -> exp(6z), :mand, (256, 256), true, false, Float64, 0),
    :bedbug => Settings(1000, 1000, -4, 4, 4, -4, 500, 2, 0, (zn, c) -> zn^2+c, z -> tan(acos(atan(z))), z -> tan(cos(atan(z))), :buddha, (256, 256), true, false, Float32, 0),
    :snow_globe => Settings(1000, 1000, -4, 4, 4, -4, 500, 2, 0, (zn, c) -> zn^2+c, z -> exp(2asin(z)), z -> sin(log(z)/2), :buddha, (256, 256), true, false, Float32, 0),
    :gates => Settings(1000, 1000, -4, 4, 4, -4, 500, 2, 0, (zn, c) -> zn^2+c, z -> 1/sin(cos(z)), z -> acos(asin(1/z)), :buddha, (256, 256), true, false, Float32, 0),
    :titan => Settings(1080, 1920, -3, 3, 16/3, -16/3, 500, 2, 0, (zn, c) -> zn^2+c, z -> 1/tan(sqrt(z)), z -> (atan(1/z))^2, :buddha, (256, 256), true, false, Float32, 0),
    :peanut => Settings(fn=(zn, c) -> sin(zn^2) + c),
    :lilypads => Settings(fn=(zn, c) -> sin(zn)^2 + c, threshold=10000.0, maxiter=5000, block_size=(50, 50)),
    :temple => Settings(type=:buddha, left=-3., right=0.2, top=1.6, bottom=-1.6, fn=(zn, c) -> tan(zn)^2 + c, maxiter=500, threshold=5.0, data_type=Float64),
    # https://www.deviantart.com/matplotlib
    :diamond => Settings(500, 1000, -1, 1, 2, -2, 100, 1000, 0, (zn, c) -> cos(zn/c), identity, identity, :mand, (256, 256), false, false, Float32, 0),
    :kidney => Settings(500, 500, -1, 1, 1, -1, 2000, 1000, 0, (zn, c) -> cos(zn) + 1/c, identity, identity, :mand, (256, 256), false, false, Float32, 0),
    :starfish => Settings(500, 500, -2.8, 1.3, 2, -2, 1000, 100, 0, (zn, c) -> c^(zn-1)*exp(-c), identity, identity, :mand, (256, 256), false, false, Float32, 0),
    :scorpion => Settings(500, 500, -50, 50, 50, -50, 200, 300, 1.0+0.1im, (zn, c) -> sinh(zn) + c^-2, identity, identity, :mand, (256, 256), false, false, Float32, 0),
    # https://www.reddit.com/r/mathpics/comments/bokheg/mandelbrot_set_of_z_pi_cosz_c/
    :v2 => Settings(500, 500, -1, 1, 1, -1, 1000, 100, 0, (zn, c) -> 2pi*cos(zn) + c, identity, identity, :mand, (256, 256), false, false, Float32, 0),
)
