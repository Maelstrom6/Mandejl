using Images
using CUDA
using ImageView
using VideoIO

include("extensions.jl")
include("settings.jl")
include("kernels.jl")
include("generator.jl")
include("post_processing.jl")

settings = Settings()
settings = Settings(width=1920*2, height=1080*2, left=-2.5, right=1.5, top=1.125, bottom=-1.125, colour_scheme=1)


# settings = Settings(width=1920*2, height=1080*2, type=:buddha, left=-3., right=0.2, top=1.6, bottom=-1.6, fn=(zn, c) -> tan(zn)^2 + c, maxiter=1000, threshold=5.0, block_size=(50, 50), data_type=Float64)
arr = create_image(settings)
img = colour(arr, settings)

settings.colour_scheme = 0
arr = create_image(settings)
img = colour(arr, settings)

settings.type = :buddha
settings.maxiter = 400
settings.threshold = 10
settings.width = 1920*8
settings.height =1080*8
settings.top, settings.bottom = settings.top+(settings.top-settings.bottom)/2, settings.bottom-(settings.top-settings.bottom)/2
settings.right, settings.left = settings.right+(settings.right-settings.left)/2, settings.left-(settings.right-settings.left)/2

arr = create_image(settings)
arr = arr[Int64(settings.height*1/4+1):Int64(settings.height*3/4), Int64(settings.width*1/4+1):Int64(settings.width*3/4), :]
img = colour(arr, settings)

settings.transform = x -> 1/x
settings.inv_transform = x -> 1/x
settings.type = :mand
arr = create_image(settings)
img = colour(arr, settings)

settings = Settings(width=1080, height=1080, top=2., bottom=-2., left=-2., right=2., transform=x -> cos(1/x)-1)
arr = create_image(settings)
img = colour(arr, settings)

settings.top *= 0.5
settings.bottom *= 0.5
settings.left *= 0.5
settings.right *= 0.5
# settings = Settings(width=1080, height=1080, top=2., bottom=-2., left=-2., right=2., transform=x -> sin(1/x))
arr = create_image(settings)
img = colour(arr, settings)

blur(img, 4)

save("mand4_3.png", img)