__precompile__()

module PGFPlotsX

import MacroTools: prewalk, @capture, @forward

using ArgCheck: @argcheck
using DataStructures: OrderedDict
import DefaultApplication
using DocStringExtensions: SIGNATURES, TYPEDEF
using Parameters: @unpack
using StatsBase: midpoints
using Requires: @require
using Unicode: lowercase

export TikzDocument, TikzPicture
export Axis, SemiLogXAxis, SemiLogYAxis, LogLogAxis, PolarAxis, GroupPlot
export Plot, PlotInc, Plot3, Plot3Inc, Expression, Coordinate, Coordinates,
    TableData, Table, Graphics, Legend, LegendEntry
export @pgf, pgfsave, print_tex, latexengine, latexengine!, push_preamble!

const DEBUG = haskey(ENV, "PGFPLOTSX_DEBUG")

"""
A file which is spliced directly to the preamble. Customize the file at this
path for site-specific setting that apply for every plot.
"""
const CUSTOM_PREAMBLE_PATH = joinpath(@__DIR__, "..", "deps", "custom_preamble.tex")
const AbstractDict = Union{Dict, OrderedDict}

if !isfile(joinpath(@__DIR__, "..", "deps", "deps.jl"))
    error("""please run Pkg.build("PGFPlotsX") before loading the package""")
end
include("../deps/deps.jl")

"""
    print_tex(io, elt, [container])

Print `elt` to `io` as LaTeX code. The optional third argument allows methods to
work differently depending on the container.

This method should indent as if at the top level, containers indent their
contents as necessary. See [`print_indent`](@ref).
"""
print_tex(io::IO, a, b) = print_tex(io, a)
print_tex(a) = print_tex(stdout, a)

include("options.jl")
include("utilities.jl")

"""
    $SIGNATURES

Print a string *as is*, terminated with a newline.

!!! note

    This is used as a workaround for LaTeX code that does not have a
    corresponding type, eg as elements in [`Axis`](@ref). `raw` or
    `LaTeXStrings` are useful to avoid piling up backslashes. The newline is
    added to separate tokens.
"""
print_tex(io::IO, str::AbstractString) = println(io, str)

"""
    $SIGNATURES

Real numbers are printed as is, except for non-finite representation.
"""
function print_tex(io::IO, x::Real)
    if isfinite(x)
        print(io, x)
    elseif isnan(x)
        print(io, "nan")
    elseif isinf(x)
        s = x > 0 ? "+" : "-"
        print(io, "$(s)inf")
    else
        throw(ArgumentError("Don't know how to print $x for LaTeX."))
    end
end

print_tex(io::IO, ::Missing) = print(io, "nan")

print_tex(io::IO,   v) = throw(ArgumentError(string("No tex function available for data of type $(typeof(v)). ",
                                                  "Define one by overloading print_tex(io::IO, data::T) ",
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

if DEFAULT_ENGINE == "PDFLATEX"
    latexengine!(PDFLATEX)
end

end # module
