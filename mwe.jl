using CUDA

function kernel!(data, offset_x, offset_y, width, height, left, right, top, bottom, fn)
    # The index of the array that we are currently working on
    id_x = blockIdx().x + offset_x
    id_y = threadIdx().x + offset_y
    # Convert a pixel to a complex coordinate
    c = (left + (right - left) * id_x / width) + (top + (bottom - top) * id_y / height)im
    escaped = false
    zn = 0+0im

    for i in 1:100
        zn = fn(zn, c)

        if abs2(zn) > 4
            escaped = true
            data[id_x, id_y] = i
            break
        end
    end

    if !escaped
        data[id_x, id_y] = 100
    end
    return nothing
end

# The size of the array and the coordinates of the left most pixel, etc.
width, height, left, right, top, bottom = 3840, 2160, -2, 2, 2, -2
# Each tuple contains offset_x, offset_y, width, height
# Pregenerated with the given width and height
blocks = [(0, 0, 512, 512), (0, 512, 512, 512), (0, 1024, 512, 512), (0, 1536, 512, 512), (0, 2048, 512, 112), (512, 0, 512, 512), (512, 512, 512, 512), (512, 1024, 512, 512), (512, 1536, 512, 512), (512, 2048, 512, 112), (1024, 0, 512, 512), (1024, 512, 512, 512), (1024, 1024, 512, 512), (1024, 1536, 512, 512), (1024, 2048, 512, 112), (1536, 0, 512, 512), (1536, 512, 512, 512), (1536, 1024, 512, 512), (1536, 1536, 512, 512), (1536, 2048, 512, 112), (2048, 0, 512, 512), (2048, 512, 512, 512), (2048, 1024, 512, 512), (2048, 1536, 512, 512), (2048, 2048, 512, 112), (2560, 0, 512, 512), (2560, 512, 512, 512), (2560, 1024, 512, 512), (2560, 1536, 512, 512), (2560, 2048, 512, 112), (3072, 0, 512, 512), (3072, 512, 512, 512), (3072, 1024, 512, 512), (3072, 1536, 512, 512), (3072, 2048, 512, 112), (3584, 0, 256, 512), (3584, 512, 256, 512), (3584, 1024, 256, 512), (3584, 1536, 256, 512), (3584, 2048, 256, 112)]
img = CUDA.zeros(Float64, (width, height))

for block in blocks
    @cuda threads=block[4] blocks=block[3] kernel!(img, block[1], block[2],
    width, height, left, right, top, bottom, (zn, c) -> zn^2.1 + c)
end
img = Array(img)  # Convert back to host memory
