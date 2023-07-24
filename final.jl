using Images
using CUDA
using ImageView
using VideoIO

include("extensions.jl")
include("settings.jl")
include("kernels.jl")
include("generator.jl")
include("post_processing.jl")


# Black and white
settings = Settings(width=1920*2, height=1080*2, left=-2.5, right=1.5, top=1.125, bottom=-1.125)
settings.colour_scheme = 1
arr = create_image(settings)
img = colour(arr, settings)
save("mand1.png", img)

# Regular stepped and regular
# Need to comment out nu in the kernel for regular stepped
settings = Settings(width=1920*2, height=1080*2, left=-2.5, right=1.5, top=1.125, bottom=-1.125)
arr = create_image(settings)
img = colour(arr, settings)
save("mand2.png", img)
save("mand3.png", img)

# Buddha 
# Change kernel from quotients to num iterations
settings = Settings(
    type=:buddha, 
    threshold=200.,
    maxiter=600,
    width=1920*8, 
    height=1080*8, 
    left=-2.5-2, 
    right=1.5+2, 
    top=1.125*2, 
    bottom=-1.125*2,
)
arr = create_image(settings)
arr = arr[Int64(settings.height*1/4+1):Int64(settings.height*3/4), Int64(settings.width*1/4+1):Int64(settings.width*3/4), :]
img = colour(arr, settings)
save("mand4.jpg", img)
save("mand5.jpg", img)
save("mand6.jpg", img)


# cosine 
settings = Settings(
    width=1920*2,
    height=1080*2,
    fn=(zn, c) -> -2pi*cos(zn) + c,
    left=-1920/3100-0.16,
    right=1920/3100-0.16,
    top=1080/3100,
    bottom=-1080/3100,
    threshold=10000.,
    maxiter=10000,
)
n = 30*3
for i in 1:n
    settings.maxiter = floor(10 * (10000/10)^((i-1)/n))
    settings.threshold = 10 * (10000/10)^((i-1)/n)
    arr = create_image(settings)
    img = colour(arr, settings)
    save("cosine/mand$i.png", img)
end



# Powers 
settings = Settings(width=1920/2, height=1080/2, left=-2.5, right=1.5, top=1.125, bottom=-1.125)
n = 30*8
for i in 1:n
    seconds = n/30
    if seconds <= 8
        power = 2.0 + ((i-1)/n)^2 * (12.0 - 2.0)
        settings.fn = (x, c) -> x^power + c
        cpower = min(power, 3.0)
        settings.left = (-2.5 + (cpower-2)*(-2.0 - (-2.5)))  * (4/3) ^ (cpower-2)
        settings.right = (1.5 + (cpower-2)*(-2.0 - (-2.5)))  * (4/3) ^ (cpower-2)
        settings.top = 1.125 * (4/3) ^ (cpower-2)
        settings.bottom = -1.125 * (4/3) ^ (cpower-2)
    else
        # power = 
    end
    println(i)
    arr = create_image(settings)
    img = colour(arr, settings)
    save("imgs/mand$i.png", img)
end


# Throne
# Use quotient in kernel
function inner_kernel!(i, data, x_pixel, y_pixel)
    if i % 3 == 0
        data[x_pixel, y_pixel, 3] += 1
    end
    if i % 2 == 0
        data[x_pixel, y_pixel, 2] += 1
    end
    data[x_pixel, y_pixel, 1] += 1
end
# Set zoom to 1 and then 1.1
function f()
    theta = pi/2
    zoom = 1.1
    settings = Settings(
        width=1920,
        height=1080,
        left=-1920/1080*(2. + 0.4sin(theta))*zoom,
        right=1920/1080*(2. + 0.4sin(theta))*zoom,
        top=(2. + 0.4cos(theta))*zoom,
        bottom=-(2. + 0.4cos(theta))*zoom,
        maxiter=100_000,
        threshold=100.,
        transform=z -> tan(acos(z*exp(im*theta)))^2, 
        inv_transform=z -> cos(atan(sqrt(z)))/exp(im*theta),
        type=:buddha,
        mirror_x=true,
        mirror_y=true,
        data_type=Float64,
    )
    # settings = Settings(
    #     width=1920,
    #     height=1080,
    #     left=-1920/1080*2.0,
    #     right=1920/1080*2.0,
    #     top=2.4,
    #     bottom=-2.4,
    #     maxiter=100_000,
    #     threshold=100.,
    #     transform=z -> tan(acos(z))^2, 
    #     inv_transform=z -> cos(atan(sqrt(z))),
    #     type=:buddha,
    #     mirror_x=true,
    #     mirror_y=true,
    #     data_type=Float64,
    # )
    arr = create_image(settings)
    img = colour(arr, settings)
    #save("mand7.png", img)
    return img
end
f()

# Use count in kernel
function inner_kernel!(i, data, x_pixel, y_pixel)
    if i < 10 #i % 3 == 0
        data[x_pixel, y_pixel, 3] += 1
    end
    if i < 100 #i % 2 == 0
        data[x_pixel, y_pixel, 2] += 1
    end
    data[x_pixel, y_pixel, 1] += 1
end
settings = Settings(
    width=1920*12,
    height=1080*12,
    left=-1920/1080*2.4,
    right=1920/1080*2.4,
    top=2.,
    bottom=-2.,
    maxiter=100_000,
    threshold=10.,
    transform=z -> tan(acos(z*im))^2, 
    inv_transform=z -> cos(atan(sqrt(z)))/im,
    type=:buddha,
    mirror_x=true,
    mirror_y=true,
    data_type=Float32,
    colour_scheme=3,
)
arr = create_image(settings)
img = colour(arr, settings)
save("mand8.jpg", img)
function f(theta)
    # theta = pi/2
    settings = Settings(
        width=1920*2,
        height=1080*2,
        left=-1920/1080*(2. + 0.4sin(theta))*1.1,
        right=1920/1080*(2. + 0.4sin(theta))*1.1,
        top=(2. + 0.4cos(theta))*1.1,
        bottom=-(2. + 0.4cos(theta))*1.1,
        maxiter=1_000,
        threshold=10.,
        transform=z -> tan(acos(z*exp(im*theta)))^2, 
        inv_transform=z -> cos(atan(sqrt(z)))/exp(im*theta),
        type=:buddha,
        mirror_x=true,
        mirror_y=true,
        data_type=Float64,
    )
    arr = create_image(settings)
    img = colour(arr, settings)
    return img
end
# for i in 1:20
#     theta = i/20
#     img = f(theta)
#     save("throne/mand$i.png", img)
# end
img = f(pi/2)
save("mand8.png", img)
settings.maxiter = 1000
settings.threshold = 100.
settings.colour_scheme = 3
arr = create_image(settings)
img = colour(arr, settings)
save("mand9.png", img)




settings = presets[:snow_globe]
settings.type = :buddha
settings.threshold = 4.
settings.maxiter = 10000
settings.width = 4000
settings.height = 4000
settings.colour_scheme = 3
# settings.fn = (z, c) -> cos(z) + c'/(abs2(c)+0.01im)
arr = create_image(settings)
img = colour(arr, settings)
save("mand10.png", img)


settings = presets[:gates]
settings.type = :buddha
settings.threshold = 4.
settings.maxiter = 10000
settings.width = 4000
settings.height = 4000
# settings.colour_scheme = 3
# settings.fn = (z, c) -> cos(z) + c'/(abs2(c)+0.01im)
arr = create_image(settings)
img = colour(arr, settings)
save("mand11.png", img)


settings = presets[:titan]
settings.type = :buddha
settings.threshold = 2.
settings.maxiter = 1000
settings.width = 4000
settings.height = 8000
# settings.colour_scheme = 3
# settings.fn = (z, c) -> cos(z) + c'/(abs2(c)+0.01im)
arr = create_image(settings)
img = colour(arr, settings)
save("mand12.png", img)


settings = presets[:box]
settings.type = :buddha
settings.threshold = 10.
settings.maxiter = 10000
settings.width = 8000
settings.height = 4000
# settings.colour_scheme = 3
# settings.fn = (z, c) -> cos(z) + c'/(abs2(c)+0.01im)
arr = create_image(settings)
img = colour(arr, settings)
save("mand13.png", img)
settings.threshold = 10.
settings.colour_scheme = 0
arr = create_image(settings)
img = colour(arr, settings)
save("mand14.png", img)
settings.colour_scheme = 0
img = colour(arr, settings)
save("mand15.png", img)