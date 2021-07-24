function pixel2point_wrapper(width, height, left, right, top, bottom)
    return function pixel2point(x, y)
        return (left + (right - left) * x / width) + (top + (bottom - top) * y / height)im
    end
end

function point2pixel_wrapper(width, height, left, right, top, bottom)
    return function point2pixel(point)
        x_point = real(point)
        y_point = imag(point)
        return round(Int, (x_point - left) * width / (right - left)), round(Int, (y_point - top) * height / (bottom - top))
    end
end

function is_in_main_bulb(c::ComplexF64)
    w = 0.25 - c
    if CUDA.abs2(w) < ((CUDA.cos(CUDA.abs(CUDA.angle(w)) / 2)) ^ 2) ^ 2
        return true
    end

    # if in secondary bulb
    if CUDA.abs2(c + 1) < 0.25 ^ 2
        return true
    end
    return false
end

function identify_ids(offset_x, offset_y)
    id_x = blockIdx().x + offset_x
    id_y = threadIdx().x + offset_y
    return id_x, id_y
end

return function buddha!(data, offset_x, offset_y, width, height, left, right, top,
    bottom, maxiter, threshold, z0, fn,
    transform=identity, inv_transform=identity)

    pixel2point = pixel2point_wrapper(width, height, left, right, top, bottom)
    point2pixel = point2pixel_wrapper(width, height, left, right, top, bottom)
    id_x, id_y = identify_ids(offset_x, offset_y)
    c = transform(pixel2point(id_x, id_y))

    escaped = false

    # cycle detection algorithm initial values
    check_step = 1
    epsilon = (right - left) / 1000000000  # scales as you zoom in
    zn_cycle = c

    if is_in_main_bulb(c)
        return nothing
    end

    zn = z0
    zn = fn(zn, c)  # iterate once so we don't add to visited_coords for no reason

    # First loop to determine if part of the set
    for i in 1:maxiter
        zn = fn(zn, c)

        # finite iteration algorithm
        if abs2(zn) > threshold ^ 2
            escaped = true
            break
        end

        # cycle detection algorithm
        if i > check_step
            if abs2(zn - zn_cycle) < epsilon ^ 2
                break
            end
            if i == check_step * 2
                check_step *= 2
                zn_cycle = zn
            end
        end
    end

    if !escaped
        return nothing
    end

    # Second loops to record the orbit of the escapees
    zn = z0
    zn = fn(zn, c)  # iterate once so we don't add to visited_coords for no reason

    for i in 1:maxiter
        zn = fn(zn, c)

        coord = inv_transform(zn)
        x_pixel, y_pixel = point2pixel(coord)
        @inbounds if (1 <= y_pixel <= height) && (1 <= x_pixel <= width)
            if i <= 10
                data[x_pixel, y_pixel, 3] += 1
            end
            if i <= 100
                data[x_pixel, y_pixel, 2] += 1
            end
            data[x_pixel, y_pixel, 1] += 1
        end

        # the finite iteration algorithm
        if abs2(zn) > threshold ^ 2
            break
        end
    end
    return nothing
end

function mandelbrot!(data, offset_x, offset_y,width, height, left, right, top,
    bottom, maxiter, threshold, z0, fn,
    transform::Function=identity, inv_transform::Function=identity)
    pixel2point = pixel2point_wrapper(width, height, left, right, top, bottom)
    id_x, id_y = identify_ids(offset_x, offset_y)
    c = transform(pixel2point(id_x, id_y))

    escaped = false

    if is_in_main_bulb(c)
        @inbounds data[id_x, id_y] = maxiter
        return nothing
    end

    # cycle detection algorithm initial values
    check_step = 1
    epsilon = (right - left) / 1000000000  # scales as you zoom in
    zn_cycle = c

    zn = z0
    zn = fn(zn, c)  # iterate once so we don't add to visited_coords for no reason

    for i in 1:maxiter
        zn = fn(zn, c)

        # finite iteration algorithm
        if abs2(zn) > threshold ^ 2
            escaped = true
            # the smoothing factor
            nu = CUDA.log2(CUDA.log2(abs(zn)))
            @inbounds data[id_x, id_y] = i - nu
            break
        end

        # cycle detection algorithm
        if i > check_step
            if abs2(zn - zn_cycle) < epsilon ^ 2
                break
            end
            if i == check_step * 2
                check_step *= 2
                zn_cycle = zn
            end
        end
    end

    if !escaped
        @inbounds data[id_x, id_y] = maxiter
    end
    return nothing
end

kernels = Dict(
    :mand => mandelbrot!,
    :buddha => buddha!,
)
