@require Colors begin
    function PGFPlotsX.print_opt(io::IO, c::Colors.Colorant)
        rgb = convert(Colors.RGB, c)
        rgb_64 = convert.(Float64, (rgb.r, rgb.g, rgb.b))
        print(io, "rgb,1:", "red,"  , rgb_64[1], ";",
                            "green,", rgb_64[2], ";",
                            "blue," , rgb_64[3])
    end

    function PGFPlotsX.print_tex(io::IO, c::Tuple{String, Colors.Colorant}, ::)
        name, color = c
        rgb = convert(Colors.RGB, color)
        rgb_64 = convert.(Float64, (rgb.r, rgb.g, rgb.b))
        print(io, "\\definecolor{$name}{rgb}{$(rgb_64[1]), $(rgb_64[2]), $(rgb_64[3])}")
    end

    function PGFPlotsX.print_tex(io::IO, c::Tuple{String, Vector{<:Colors.Colorant}}, ::)
        name, colors = c
        println(io, "\\pgfplotsset{ colormap={$name}{")
        for col in colors
            rgb = convert(Colors.RGB, col)
            rgb_64 = convert.(Float64, (rgb.r, rgb.g, rgb.b))
            println(io, "rgb=(", join(rgb_64, ","), ")")
        end
        println(io, "}}")
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
                println(io) # Break this line
            end
        end
    end
end

# TODO: Check if the bins are completely correct
@require StatsBase begin
    function PGFPlotsX.print_tex(io::IO, c::StatsBase.Histogram, ::PGFPlotsX.Table)
        dim = length(c.edges)
        if dim != 1
            error("dim != 1 not supported")
        end
        edge = c.edges[1]
        for v in 1:length(c.weights)
            println(io, 0.5 * (edge[v] + edge[v+1]), "    ", c.weights[v])
        end
    end
end
