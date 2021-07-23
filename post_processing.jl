function remove_horizontal_pixels(img::Array{Any,2})
    width, height = size(img)
    img = vcat(img[1:(fld(height, 2)-1), :], img[(fld(height, 2)+1):height, :])
end

function remove_vertical_pixels(img::Array{Any,2})
    width, height = size(img)
    img = hcat(img[:, 1:(fld(width, 2)-1)], img[:, (fld(width, 2)+1):width])
end

function colour(img::Array{<:Any,2}, settings::Settings)
    n = settings.maxiter
    black = RGB(zero(eltype(img)), zero(eltype(img)), zero(eltype(img)))
    function scheme1(pixel)
        if pixel == 1
            return black
        else
            return RGB(
                (sin(n*pixel / 24) * 100 + 150)/255,
                (sin(n*pixel / 12) * 100 + 150)/255,
                (cos(n*pixel / 24) * 100 + 150)/255,
            )
        end
    end
    return scheme1.(img)
end

function colour(img::Array{<:Any,3}, settings::Settings)
    function scheme1(pixel)
        return RGB(
                sqrt(pixel[1]),
                sqrt(pixel[2]),
                sqrt(pixel[3]),
            )
    end
    return [scheme1(img[x, y, :]) for x in 1:size(img)[1], y in 1:size(img)[2]]
end