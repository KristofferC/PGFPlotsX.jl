@require Colors begin
    function PGFPlotsX.print_opt(io::IO, c::Colors.Colorant)
        rgb = convert(Colors.RGB, c)
        rgb_64 = convert.(Float64, (rgb.r, rgb.g, rgb.b))
        print(io, "rgb,1:", "red,"  , rgb_64[1], ";",
                            "green,", rgb_64[2], ";",
                            "blue," , rgb_64[3])
    end

    function PGFPlotsX.print_tex(io::IO, c::Tuple{String, Colors.Colorant}, ::Any)
        name, color = c
        rgb = convert(Colors.RGB, color)
        rgb_64 = convert.(Float64, (rgb.r, rgb.g, rgb.b))
        print(io, "\\definecolor{$name}{rgb}{$(rgb_64[1]), $(rgb_64[2]), $(rgb_64[3])}")
    end

    function PGFPlotsX.print_tex(io::IO, c::Tuple{String, Vector{<:Colors.Colorant}}, ::Any)
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
    """
    $SIGNATURES

Construct table data from a `DataFrame`.
    """
    PGFPlotsX.TableData(df::DataFrames.DataFrame; rowsep = ROWSEP) =
        TableData(hcat(DataFrames.columns(df)...), string.(names(df)), 0, rowsep)
end

@require Contour begin
    function PGFPlotsX.TableData(c::Contour.ContourCollection; rowsep = ROWSEP)
        colx = Any[]
        coly = Any[]
        colz = Any[]
        ns = Int[]
        for cl in Contour.levels(c)
            lvl = Contour.level(cl) # the z-value of this contour level
            for line in Contour.lines(cl)
                xs, ys = Contour.coordinates(line) # coordinates of this line segment
                n = length(xs)
                append!(colx, xs)
                append!(coly, ys)
                append!(colz, fill(lvl, n))
                push!(ns, n)
            end
        end
        TableData(hcat(colx, coly, colz), ["x", "y", "z"], cumsum(ns), rowsep)
    end
end

@require StatsBase begin
    # workaround for https://github.com/JuliaStats/StatsBase.jl/issues/344
    const _midpoints = x -> middle.(x[2:end], x[1:(end-1)])

    function PGFPlotsX.TableData(h::StatsBase.Histogram{T, 1}; kwargs...) where T
        PGFPlotsX.TableData(hcat(h.edges[1], vcat(h.weights, 0)), nothing, 0; kwargs...)
    end

    function PGFPlotsX.TableData(histogram::StatsBase.Histogram{T, 2}; kwargs...) where T
        PGFPlotsX.TableData(_midpoints(histogram.edges[1]),
                            _midpoints(histogram.edges[2]),
                            histogram.weights; kwargs...)
    end

    function PGFPlotsX.Coordinates(histogram::StatsBase.Histogram{T, 2}) where T
        PGFPlotsX.Coordinates(_midpoints(histogram.edges[1]),
                              _midpoints(histogram.edges[2]),
                              histogram.weights)
    end
end
