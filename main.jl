using CUDA
using ImageView
using Images

include("extensions.jl")
include("settings.jl")
include("kernels.jl")
include("generator.jl")
include("post_processing.jl")

settings = Settings(1024, 1024, -2, 2, 2, -2, 100, 2, 0, (zn, c) -> (zn)^2 + c, identity, identity, :final, (512, 512), false, false, Float32)
img = create_image2(settings)
imshow(colour(img, settings))

using VideoIO
    # RGB{N0f8}(x/200, x/200, x/200)


framerate=24
settings = Settings(512, 512, -2, 2, 2, -2, 100, 2, 0, (zn, c) -> (zn)^2 + c, identity, identity, :buddha, (512, 512), false, false, Float32)
img = create_image2(settings)
open_video_out("video.mp4", colour(img, settings), framerate=framerate, target_pix_fmt=VideoIO.AV_PIX_FMT_YUV420P) do writer
    for t in 1:100
        settings = Settings(512, 512, -2, 2.0, 2.0, -2.0, 100, 2, 0, (zn, c) -> (zn)^2 + c + t/1000, identity, identity, :buddha, (512, 512), false, false, Float32)
        img = create_image2(settings)
        frame = colour(img, settings)
        write(writer, frame)
    end
end

framestack = map(x->fill(VideoIO.RGB{N0f8}(x/200, 0, 0), (100, 100)), 1:100) #vector of 2D arrays
open_video_out("video.mp4", framestack[1], framerate=framerate, target_pix_fmt=VideoIO.AV_PIX_FMT_YUV420P) do writer
    for frame in framestack
        write(writer, frame)
    end
end
