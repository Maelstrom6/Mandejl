using Pkg
Pkg.activate(".")
Pkg.add(["Images"])
Pkg.add("CUDA")
Pkg.add("ImageView")
Pkg.add("VideoIO")

using Images
using CUDA
using ImageView
using VideoIO

include("extensions.jl")
include("settings.jl")
include("kernels.jl")
include("generator.jl")
include("post_processing.jl")

f1 = [
    inv,
    sin,
    cos,
    tan,
    # asin,
    # acos,
    # atan,
    exp,
    log,
    sqrt,
    z -> z^2,
]

f2 = [
    +,
    # -,
    # *,
    # /,
]

i=0
for h in f1
    for g in f1
        for f in f2
            i += 1
            println("$i $f($g($h(zn)), c)")
            # fn = (zn, c) -> f(g(h(zn)), c)
            # settings = Settings(fn=fn)
            # img = create_image(settings)
            # img = colour(img, settings)
            # save("$i.png", img)
        end
    end
end

settings = Settings(width=1920*2, height=1080*2, type=:buddha, left=-3., right=0.2, top=1.6, bottom=-1.6, fn=(zn, c) -> tan(zn)^2 + c, maxiter=1000, threshold=5.0, block_size=(50, 50), data_type=Float64)
img = create_image(settings)
img = colour(img, settings)
save("y.png", img)

settings = Settings(2000*4, 1000*4, -4, 4, 2, -2, 2000, 4, 0, (zn, c) -> zn^2 + c, z -> tan(asin(z))^2, z -> sin(atan(sqrt(z))), :buddha, (256, 256), true, true, Float64)
# settings = Settings(width=1920*4, height=1080*4, type=:buddha, left=-2.0, right=1.4, top=1.6, bottom=-1.6, fn=(zn, c) -> zn^2 + c, maxiter=10000, threshold=5.0, block_size=(50, 50), data_type=Float32)
img = create_image(settings)
img = colour(img, settings)
save("buddha.png", img)

for (name, settings) in presets
    println(name)
    img = create_image(settings)
    img = colour(img, settings)
    imshow(img)
end

# settings = Settings(1920, 1920, -2, 2, 2, -2, 1000, 2, 0, (zn, c) -> zn^2 + c, z -> 1/z, z -> 1/z, :buddha, (2048, 512), false, false, Float16)
settings = Settings(type=:buddha, maxiter=1000, left=-2.0, right=2.62222, top=1.3, bottom=-1.3, data_type=Float32)
settings = Settings(4000, 4000, -2.0, 2.0, 2.0, -2.0, 1000, 2.0, 0.0 + 0.0im, (zn, c) -> zn^2+c, identity, identity, :buddha, (256, 256), false, true, Float16)
settings.type = :buddha
settings.height = settings.width
settings.inv_transform = z -> sqrt(log1p(z))
img = create_image(settings)
# img = remove_horizontal_pixels(remove_vertical_pixels(img))
img = colour(img, settings)
img = blur(img, 2)
img = imresize(img, (1000, 1000))
imshow(img)





framerate=24
settings = Settings(type=:buddha, maxiter=1, left=-2.0, right=2.62222, top=1.3, bottom=-1.3, data_type=Float32)
img = create_image(settings)
open_video_out("video.mp4", colour(img, settings), framerate=framerate, target_pix_fmt=VideoIO.AV_PIX_FMT_YUV420P) do writer
    for t in 2:1000
        println("t=$t")
        settings = Settings(type=:buddha, maxiter=t, left=-2.0, right=2.62222, top=1.3, bottom=-1.3, data_type=Float32)
        img = create_image(settings)
        frame = colour(img, settings)
        write(writer, frame)
    end
end
