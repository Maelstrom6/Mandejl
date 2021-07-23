struct Settings
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
