module PGFPlotsX

import MacroTools: prewalk, @capture

using DataStructures
using Requires

export @pgf

const DEBUG = haskey(ENV, "PGFPLOTSX_DEBUG")

const CUSTOM_PREAMBLE_PATH = joinpath(@__DIR__, "..", "deps", "custom_preamble.tex")

const PGFOption = Union{Pair, String, OrderedDict}
const AbstractDict = Union{Dict, OrderedDict}

print_tex(io::IO, a, b) = print_tex(io, a)

# TODO: Make OptionType a trait somehow?
abstract type OptionType end

Base.getindex(a::OptionType, s::String) = a.options[s]
Base.setindex!(a::OptionType, v, s::String) = (a.options[s] = v; a)
Base.delete!(a::OptionType, s::String) = (delete!(a.options, s); a)
Base.copy(a::OptionType) = deepcopy(a)
function Base.merge!(a::OptionType, d::OrderedDict)
    for (k, v) in d
        a[k] = v
    end
    return a
end

include("utilities.jl")

function print_tex(io_main::IO, str::String)
    print_indent(io_main) do io
        print(io, str)
    end
end

print_tex(io::IO,   v) = throw(ArgumentError(string("No tex function available for data of type $(typeof(v)).",
                                                  "Define one by overloading print_tex(io::IO, data::T, ::$(typeof(typ))), ",
                                                  "where T is the type of the data to dispatch on.")))



"""
An `AxisElement` is a component of an `Axis`. It can be a `Plot` or a `RawString` etc.
"""
abstract type AxisElement <: OptionType end

include("axiselements.jl")

"""
A `TikzElement` is a component of a `TikzPicture`. It can be a node or an `Axis` etc.
"""
abstract type TikzElement <: OptionType end

include("axislike.jl")

include("tikzpicture.jl")
include("tikzdocument.jl")
include("requires.jl")
include("build.jl")

end # module
