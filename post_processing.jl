function remove_horizontal_pixels(img::Array{<:Any,2})
    height, width = size(img)
    img = vcat(img[1:(fld(height, 2)-1), :], img[(cld(height, 2)+2):height, :])
end

function remove_vertical_pixels(img::Array{<:Any,2})
    height, width = size(img)
    img = hcat(img[:, 1:(fld(width, 2)-1)], img[:, (cld(width, 2)+2):width])
end

function remove_horizontal_pixels(img::Array{<:Any,3})
    height, width, depth = size(img)
    img = vcat(img[1:(fld(height, 2)-1), :, :], img[(cld(height, 2)+2):height, :, :])
end

function remove_vertical_pixels(img::Array{<:Any,3})
    height, width, depth = size(img)
    img = hcat(img[:, 1:(fld(width, 2)-1), :], img[:, (cld(width, 2)+2):width, :])
end

function blur(img::Matrix{RGB{N0f8}}, radius=1)
    return imfilter(img, Kernel.gaussian(radius))
end

function colour(img::Array{<:Any,2}, settings::Settings)
    n = settings.maxiter
    colour_scheme = settings.colour_scheme
    black = RGB{N0f8}(zero(eltype(img)), zero(eltype(img)), zero(eltype(img)))
    white = RGB{N0f8}(one(eltype(img)), one(eltype(img)), one(eltype(img)))
    function scheme1(pixel)
        if colour_scheme == 0
            if pixel == 1
                return black
            else
                return RGB{N0f8}(
                    (sin(n*pixel / 24) * 100 + 150)/255,
                    (sin(n*pixel / 12) * 100 + 150)/255,
                    (cos(n*pixel / 24) * 100 + 150)/255,
                )
            end
        elseif colour_scheme == 1
            if pixel == 1
                return black
            else
                return white
            end
        end
    end
    return scheme1.(img)
end

function colour(arr::Array{<:Any,3}, settings::Settings)
    if settings.colour_scheme == 0
        function scheme1(pixel)
            return RGB{N0f8}(
                    sqrt(pixel[1]),
                    sqrt(pixel[2]),
                    sqrt(pixel[3]),
                )
        end
        return [scheme1(arr[x, y, :]) for x in 1:size(arr)[1], y in 1:size(arr)[2]]
    elseif settings.colour_scheme == 1
        m = [maximum(arr[:, :, i]) for i in 1:3]
        scheme(pixel) = RGB{N0f8}((log1p.(pixel) / log1p(1))...)
        return [scheme(arr[x, y, :]) for x in 1:size(arr)[1], y in 1:size(arr)[2]]
    else
        scheme3(pixel) = RGB{N0f8}((pixel .^ (1/settings.colour_scheme))...)
        # function scheme(pixel)
        #     return RGB{N0f8}(
        #             (pixel[1])^(1/settings.colour_scheme),
        #             (pixel[2])^(1/settings.colour_scheme),
        #             (pixel[3])^(1/settings.colour_scheme),
        #         )
        # end
        return [scheme3(arr[x, y, :]) for x in 1:size(arr)[1], y in 1:size(arr)[2]]
    end
end
