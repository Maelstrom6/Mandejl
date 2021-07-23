using CUDA
using ImageView
using Images

include("extensions.jl")
include("settings.jl")
include("kernels.jl")
include("generator.jl")
include("post_processing.jl")

settings = Settings(1024, 1024, -2, 2, 2, -2, 100, 2, 0, (zn, c) -> (zn)^2 + c, identity, identity, :buddha, (512, 512), false, false, Float32)
img = create_image(settings)
imshow(colour(img, settings))
