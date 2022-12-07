module ColorsExt

import PGFPlotsX

PGFPlotsX.EXTENSIONS_SUPPORTED ? (using Colors) : (using ..Colors)

function _rgb_for_printing(c::Colors.Colorant)
    rgb = convert(Colors.RGB{Float64}, c)
    # round colors since pgfplots cannot parse scientific notation, eg 1e-10
    round.((Colors.red(rgb), Colors.green(rgb), Colors.blue(rgb)); digits = 4)
end

function PGFPlotsX.print_opt(io::IO, c::Colors.Colorant)
    rgb_64 = _rgb_for_printing(c)
    print(io, "rgb,1:",
            "red,"  , rgb_64[1], ";",
            "green,", rgb_64[2], ";",
            "blue," , rgb_64[3])
end

# For printing surface plots with explicit color, pgfplots manual 4.6.7.
# If there are any other uses outside options that need a different format,
# we should introduce a wrapper type.
function PGFPlotsX.print_tex(io::IO, c::Colors.Colorant)
    rgb_64 = _rgb_for_printing(c)
    print(io, "rgb=", rgb_64[1], ",", rgb_64[2], ",", rgb_64[3])
end

function PGFPlotsX.print_tex(io::IO, c::Tuple{String, Colors.Colorant}, ::Any)
    name, color = c
    rgb_64 = _rgb_for_printing(color)
    print(io, "\\definecolor{$name}{rgb}{$(rgb_64[1]), $(rgb_64[2]), $(rgb_64[3])}")
end

function PGFPlotsX.print_tex(io::IO,
                                c::Tuple{String, Vector{<:Colors.Colorant}},
                                ::Any)
    name, colors = c
    println(io, "\\pgfplotsset{ colormap={$name}{")
    for col in colors
        rgb_64 = _rgb_for_printing(col)
        println(io, "rgb=(", join(rgb_64, ","), ")")
    end
    println(io, "}}")
end

end
