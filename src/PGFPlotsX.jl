module PGFPlotsX

import MacroTools: prewalk, @capture

using DataStructures

export @pgf

const PGFOption = Union{Pair, String, OrderedDict}
const AbstractDict = Union{Dict, OrderedDict}

DEFAULT_PREAMBLE =
"""
\\usepackage{pgfplots}
\\pgfplotsset{compat=1.13}
"""

CUSTOM_PREAMBLE = String[]


abstract type OptionType end

Base.getindex(a::OptionType, s::String) = a.options[s]
Base.setindex!(a::OptionType, v, s::String) = a.options[s] = v
Base.delete!(a::OptionType, s::String) = delete!(a.options, s)
Base.copy(a::OptionType) = deepcopy(a)

include("utilities.jl")

function print_tex(io_main::IO, str::String)
    print_indent(io_main) do io
        print(io, str)
    end
end


"""
An `AxisElement` is a component of an `Axis`. It can be a `Plot` or a `RawString` etc.
"""
abstract type AxisElement <: OptionType end

include("axiselements.jl")

"""
A `TikzElement` is a component of a `TikzPicture`. It can be a node or an `Axis` etc.
"""
abstract type TikzElement <: OptionType end

include("axis.jl")

include("tikzpicture.jl")
include("tikzdocument.jl")

end # module
