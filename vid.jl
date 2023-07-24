settings = Settings(width=1920/2, height=1080/2, left=-2.5, right=1.5, top=1.125, bottom=-1.125)
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


settings = presets[:cave]
settings.width *= 2
settings.height *= 2
settings.mirror_y = false
settings.type = :buddha
settings.threshold = 2
settings.maxiter = 600.

for i in 1:10
    a = i/50
    settings.transform = z -> a*z + (1-a)/z
    settings.inv_transform = z -> (z + sqrt(z^2 - 4a + 4a^2))/(2a)
    arr = create_image(settings)
    img = colour(arr, settings)
    img2 = img

    settings.inv_transform = z -> (z - sqrt(z^2 - 4a + 4a^2))/(2a)
    arr = create_image(settings)
    img = colour(arr, settings)

    # img/2 + img2/2
    save("cave/mand$i.jpg", img/2 + img2/2)
end


settings.left *= 2
settings.right *= 2
settings.top *= 2
settings.bottom *= 2

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
settings