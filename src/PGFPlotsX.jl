module PGFPlotsX

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
    @eval Base.Experimental.@optlevel 1
end

using ArgCheck: @argcheck
using Dates
using OrderedCollections: OrderedDict
using DefaultApplication: DefaultApplication
using DocStringExtensions: SIGNATURES, TYPEDEF
using MacroTools: prewalk, @capture
using Parameters: @unpack
using Tables: Tables

export TikzDocument, TikzPicture
export Axis, SemiLogXAxis, SemiLogYAxis, LogLogAxis, PolarAxis, SmithChart, GroupPlot, TernaryAxis
export Plot, PlotInc, Plot3, Plot3Inc, Expression, Coordinate, Coordinates,
    TableData, Table, Graphics, Legend, LegendEntry, VLine, HLine, VBand, HBand
export @pgf, pgfsave, print_tex, latexengine, latexengine!, push_preamble!, export2tikz

struct PGFPlotsXDisplay <: AbstractDisplay end

"""
A file which is spliced directly to the preamble. Customize the file at this
path for site-specific setting that apply for every plot.
"""
const CUSTOM_PREAMBLE_PATH = joinpath(@__DIR__, "..", "deps", "custom_preamble.tex")

"""
    print_tex(io, elt, [container])

Print `elt` to `io` as LaTeX code. The optional third argument allows methods to
work differently depending on the container.

`print_tex(String, ...)` returns the LaTeX code as a `String`.

This method should indent as if at the top level, containers indent their
contents as necessary. See [`print_indent`](@ref).
"""
print_tex(io::IO, a, b) = print_tex(io, a)

print_tex(a) = print_tex(stdout, a)

function print_tex(::Type{String}, args...)
    io = IOBuffer()
    print_tex(io, args...)
    String(take!(io))
end

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
$(SIGNATURES)

Vectors are emitted elementwise without any extra whitespace as LaTeX code, using the
`print_tex` method for each element.
"""
print_tex(io::IO, vector::AbstractVector) = foreach(elt -> print_tex(io, elt), vector)

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

print_tex(io::IO, dt::Date) = Dates.format(io, dt, dateformat"YYYY-mm-dd")

print_tex(io::IO, dt::DateTime) = Dates.format(io, dt, dateformat"YYYY-mm-dd HH:MM")

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
include("build.jl")
include("precompile_PGFPlotsX.jl")
_precompile_()

# TODO: Replace with proper version
const EXTENSIONS_SUPPORTED = isdefined(Base, :get_extension)

if !EXTENSIONS_SUPPORTED
    using Requires: @require
end

function __init__()
    pushdisplay(PGFPlotsXDisplay())
    atreplinit(i -> begin
        if PlotDisplay() in Base.Multimedia.displays
            popdisplay(PGFPlotsXDisplay())
        end
        pushdisplay(PGFPlotsXDisplay())
    end)

    @static if !EXTENSIONS_SUPPORTED
        @require Colors="5ae59095-9a9b-59fe-a467-6f913c188581" include("../ext/ColorsExt.jl")
        @require Contour="d38c429a-6771-53c6-b99e-75d170b6e991" include("../ext/ContourExt.jl")
        @require StatsBase="2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91" include("../ext/StatsBaseExt.jl")
        @require Measurements="eff96d63-e80a-5855-80a2-b1b0885c5ab7" include("../ext/MeasurementsExt.jl")
    end
end


# Allow creation of external data file for light tikz files
# if export_data2file is true, table data are written into a file.
# if export2tex is called, the daa files are moved toward the folder of the file
function ExternalDataFile(content)
    filepath = get_filepath()
    open(filepath,"w") do io
        print_tex(io,content; rowsep_off=true)
    end
    push!(external_file_storage,filepath)
    return filepath
end
get_filepath() = Base.Filesystem.tempname(;cleanup=true)
# global variables to store exported datafile paths
global external_file_storage = Vector{AbstractString}()
global export_data2file = true

function export2tikz(fn::AbstractString,p; datapath="fig_data", relpath="", ext="tikz")
    bn = splitext(basename(fn))[1]
    fn = string(splitext(abspath(expanduser(fn)))[1],".", ext)
    io = IOBuffer()
    show(io, MIME("application/x-tex"), p)
    s = String(take!(io));
    close(io)

    dirpath = joinpath(dirname(fn),datapath)
    if !isdir(dirpath)
        mkdir(dirpath)
    end 
    for (i,filepath) in enumerate(external_file_storage)
        new_filename = joinpath(dirpath,"$(bn)_$i.tsv")
        new_filename_relative = joinpath(relpath,datapath,"$(bn)_$i.tsv")
        ss = replace(s, filepath => new_filename_relative)
        open(fn,"w") do io
            write(io,ss)
        end
        mv(filepath, new_filename; force=true)
    end
    empty!(external_file_storage);
    nothing
end 


end # module
