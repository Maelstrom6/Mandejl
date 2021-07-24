using CUDA
using ImageView
using Images
using VideoIO

include("extensions.jl")
include("settings.jl")
include("kernels.jl")
include("generator.jl")
include("post_processing.jl")

settings = Settings(3840, 2160, -2, 2, 2, -2, 10000, 2, 0, (zn, c) -> zn^2 + c, identity, identity, :mand, (256, 256), false, false, Float16)
img = create_image(settings)
imshow(colour(img, settings))



framerate=24
settings = Settings(512, 512, -2, 2, 2, -2, 100, 2, 0, (zn, c) -> (zn)^2 + c, identity, identity, :buddha, (512, 512), false, false, Float32)
img = create_image(settings)
open_video_out("video.mp4", colour(img, settings), framerate=framerate, target_pix_fmt=VideoIO.AV_PIX_FMT_YUV420P) do writer
    for t in 0:0.005:1
        settings = Settings(512, 512, -2, 2.0, 2.0, -2.0, 100, 2, 0, (zn, c) -> (zn)^2 + c, z -> t*cos(z) + (1-t)*z, identity, :buddha, (512, 512), false, false, Float32)
        img = create_image(settings)
        frame = colour(img, settings)
        write(writer, frame)
    end
end
