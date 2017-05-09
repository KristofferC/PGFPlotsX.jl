@require Colors begin
    print("Colors loaded")
    function PGFPlotsX.print_opt(io::IO, c::Colors.RGB)
        rgb = convert(Colors.RGB, c)
        rgb_64 = convert.(Float64, (rgb.r, rgb.g, rgb.b))
        print(io, "rgb,1:", "red,"  , rgb_64[1], ";",
                            "green,", rgb_64[2], ";",
                            "blue," , rgb_64[3])
    end
end

@require DataFrames begin
    print("DataFrames loaded")
    function PGFPlotsX.print_tex(io::IO, df::DataFrames.DataFrame, ::PGFPlotsX.Table)
        tmp = tempname() * ".tsv"
        DataFrames.writetable(tmp, df; quotemark = ' ')
        print(io, readstring(tmp))
    end
end
