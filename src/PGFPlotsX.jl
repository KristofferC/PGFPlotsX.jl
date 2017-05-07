module PGFPlotsX

const PGFOption = Union{Pair, String}

PGFPLOTS_DEFAULT_PREAMBLE =
"""
\\usepackage{pgfplots}
"""

PGFPLOTS_CUSTOM_PREAMBLE = String[]


abstract type OptionType end

Base.getindex(a::OptionType, s::String) = a.options[s]
Base.setindex!(a::OptionType, s::String, v) = a.options[s] = v
Base.delete!(a::OptionType, s::String) = delete!(a.options, s)

include("utilities.jl")

function print_tex(io_main::IO, str::String)
    print_indent(io_main) do io
        print(io, str)
    end
end

"""
A `TikzElement` is a component of a `TikzPicture`. It can be a node or an `Axis` etc.
"""
abstract type TikzElement <: OptionType end

include("tikzpicture.jl")


# TikzElements

"""
An `AxisElement` is a component of an `Axis`. It can be a `Plot` or a `RawString` etc.
"""
abstract type AxisElement <: OptionType end

include("axiselements.jl")
include("axis.jl")

toaxis(plot::Plot) = Axis(plot)

end # module
