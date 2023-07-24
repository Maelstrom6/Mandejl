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
