import PrecompileTools

PrecompileTools.@setup_workload begin
    x = [0.0, 0.5, 1.0]
    PrecompileTools.@compile_workload begin
        axis = @pgf Axis(
            {
                xlabel = "x",
                ylabel = raw"$f(x)$",
                legend_pos = "north west",
            },
            PlotInc({ no_marks }, Coordinates(x, x)),
            Plot(Coordinates(x, x; yerror = x)),
            Plot(Table([:x => x, :y => x])),
            Plot3(Table(x, x, x .* x')),
            Plot(Expression("x^2")),
            Legend(["a", "b"]),
            LegendEntry("c"),
            VLine({ dashed }, 0.5),
        )
        td = TikzDocument(TikzPicture(axis))
        print_tex(IOBuffer(), td)
        # cover the `IOStream` methods used when saving to a file
        mktemp() do _, io
            savetex(io, td)
        end
    end
end
