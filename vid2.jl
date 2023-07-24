settings = Settings(width=1920*2, height=1080*2, left=-2.5, right=1.5, top=1.125, bottom=-1.125)

settings = presets[:throne]
settings.left = -2
settings.right = 2
settings.width = 4000
settings.height = 4000
settings.threshold = 1000
settings.maxiter = 1000
settings.inv_transform = function x(z)
    result = cos(atan(sqrt(z)))
    if abs2(result) < 1/50
        return 1000
    end
    return result
end
settings.inv_transform = (z) -> cos(atan(sqrt(z))) + 0.001/cos(atan(sqrt(z)))
settings.colour_scheme = 0

arr = create_image(settings)
img = colour(arr, settings)

save("mand1.png", img)

settings = presets[:v2]
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


settings.type = :buddha
settings.type = :orbit_x
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
    # settings.top, settings.bottom = 1.125+(power-2)*(1.5-1.125), settings.bottom-(settings.top-settings.bottom)/2
    # settings.right, settings.left = settings.right+(settings.right-settings.left)/2, settings.left-(settings.right-settings.left)/2

    println(i)
    arr = create_image(settings)
    img = colour(arr, settings)
    save("imgs/mand$i.png", img)
end
