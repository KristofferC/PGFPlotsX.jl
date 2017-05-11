@require Colors begin
    function PGFPlotsX.print_opt(io::IO, c::Colors.RGB)
        rgb = convert(Colors.RGB, c)
        rgb_64 = convert.(Float64, (rgb.r, rgb.g, rgb.b))
        print(io, "rgb,1:", "red,"  , rgb_64[1], ";",
                            "green,", rgb_64[2], ";",
                            "blue," , rgb_64[3])
    end
end

@require DataFrames begin
    function PGFPlotsX.print_tex(io::IO, df::DataFrames.DataFrame, ::PGFPlotsX.Table)
        tmp = tempname() * ".tsv"
        DataFrames.writetable(tmp, df; quotemark = ' ')
        print(io, readstring(tmp))
    end
end

@require Contour begin
    function PGFPlotsX.print_tex(io::IO, c::Contour.ContourCollection, ::PGFPlotsX.Table)
        for cl in Contour.levels(c)
            lvl = Contour.level(cl) # the z-value of this contour level
            for line in Contour.lines(cl)
                xs, ys = Contour.coordinates(line) # coordinates of this line segment
                for (x, y) in zip(xs, ys)
                    println(io, join((x, y, lvl), " "))
                end
            end
        end
    end
end
