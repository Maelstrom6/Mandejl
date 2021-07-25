using CUDA
using ImageView
using Images
using VideoIO

include("extensions.jl")
include("settings.jl")
include("kernels.jl")
include("generator.jl")
include("post_processing.jl")


# settings = Settings(1920, 1920, -2, 2, 2, -2, 1000, 2, 0, (zn, c) -> zn^2 + c, z -> 1/z, z -> 1/z, :buddha, (2048, 512), false, false, Float16)
settings = Settings()
settings = Settings(4000, 4000, -2.0, 2.0, 2.0, -2.0, 1000, 2.0, 0.0 + 0.0im, (zn, c) -> zn^2+c, identity, identity, :buddha, (256, 256), false, true, Float16)
settings.type = :buddha
settings.fn = (zn, znm1, c) -> zn + znm1 + c
settings.height = settings.width
settings.inv_transform = z -> sqrt(log1p(z))
img = create_image(settings)
# img = remove_horizontal_pixels(remove_vertical_pixels(img))
img = colour(img, settings)
img = blur(img, 2)
img = imresize(img, (1000, 1000))
imshow(img)





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
