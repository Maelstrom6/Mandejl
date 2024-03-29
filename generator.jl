"""
Identifies blocks to make from width and height. List of x, y, width, height pairs.
"""
function identify_blocks(settings::Settings)
    width = settings.width
    height = settings.height
    mirror_x = settings.mirror_x
    mirror_y = settings.mirror_y
    block_size = settings.block_size
    block_multiple_y = mirror_x ? 2 : 1
    block_multiple_x = mirror_y ? 2 : 1

    blocks = Tuple{Int64, Int64, Int64, Int64}[]
    for x_block in 0:fld(width, block_size[1] * block_multiple_x)
        for y_block in 0:fld(height, block_size[2] * block_multiple_y)
            x_offset = x_block * block_size[1]
            y_offset = y_block * block_size[2]
            block_width = min(block_size[1], fld(width, block_multiple_x) - x_offset)
            block_height = min(block_size[2], fld(height, block_multiple_y) - y_offset)
            if block_width * block_height > 0
                push!(blocks, (x_offset, y_offset, block_width, block_height))
            end
        end
    end

    return blocks
end

"""
Run some functions just before going to post-processing.

This includes mirroring, scaling and transposing.
"""
function pre_post_processing!(img::Array{<:Any,2}, settings::Settings)
    if settings.mirror_x
        img = img + reverse(img, dims=2)
    end
    if settings.mirror_y
        img = img + reverse(img, dims=1)
    end

    m = maximum(img)
    if m > 0
        img = img ./ m
    end

    img[.!(isfinite.(img))] .= zero(eltype(img))
    return permutedims(img, [2, 1])
end

function pre_post_processing!(img::Array{<:Any,3}, settings::Settings)
    if settings.mirror_x
        img = img + reverse(img, dims=2)
    end
    if settings.mirror_y
        img = img + reverse(img, dims=1)
    end

    m = maximum(img)
    if m > 0
        img = img ./ m
    end

    img[.!(isfinite.(img))] .= zero(eltype(img))
    return permutedims(img, [2, 1, 3])
end

function create_image(settings::Settings)
    width = settings.width
    height = settings.height
    left = settings.left
    right = settings.right
    top = settings.top
    bottom = settings.bottom
    maxiter = settings.maxiter
    threshold = settings.threshold
    z0 = settings.z0
    fn = settings.fn
    transform = settings.transform
    inv_transform = settings.inv_transform

    blocks = identify_blocks(settings)

    if settings.type in [:mand, :orbit_x, :orbit_o, :orbit_dot]
        img = CUDA.zeros(settings.data_type, (settings.width, settings.height))
    else
        img = CUDA.zeros(settings.data_type, (settings.width, settings.height, 3))
    end

    kernel! = kernels[settings.type]
    for (i, block) in enumerate(blocks)
        @cuda blocks=block[3] threads=block[4] kernel!(img, block[1], block[2],
        width, height, left, right, top,
        bottom, maxiter, threshold, z0, fn,
        transform, inv_transform)
    end
    img = Array(img)

    pre_post_processing!(img, settings)
end
