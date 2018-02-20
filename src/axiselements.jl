##############
# Expression #
##############

struct Expression <: OptionType
    fs::Vector{String}
end

Expression(str::String) = Expression([str])

function print_tex(io_main::IO, f::Expression)
    multiple_f = length(f.fs) != 1
    print_indent(io_main) do io
        multiple_f && print(io, "(\n")
        for (i, fstr) in enumerate(f.fs)
            print(io, "{", fstr, "}")
            if i != length(f.fs)
                print(io, ",\n")
            end
        end
        multiple_f && print(io, ")")
    end
end

##############
# Coordinate #
##############

"""
    EmptyLine()

Placeholder for an empty line.

In 2D plots, `pgfplots` treats empty lines as *jumps* by default.

In 3D plots (eg `surf` and similar), it is used as a scanline separator to
establish the dimensions of the matrix.
"""
struct EmptyLine end

print_tex(io::IO, ::EmptyLine) = println(io)

struct Coordinate{N}
    data::NTuple{N, Real}
    error::Union{Void, NTuple{N, Real}}
    errorplus::Union{Void, NTuple{N, Real}}
    errorminus::Union{Void, NTuple{N, Real}}
    meta::Any
    function Coordinate(data::NTuple{N, Real},
                        error::Union{Void, NTuple{N, Real}},
                        errorplus::Union{Void, NTuple{N, Real}},
                        errorminus::Union{Void, NTuple{N, Real}}, meta) where N
        @argcheck 2 ≤ N ≤ 3 "A Coordinate has to be two- or three dimensional."
        @argcheck all(isfinite, data) "Non-finite coordinate values."
        @argcheck(!(error ≠ nothing &&
                    (errorplus ≠ nothing || errorminus ≠ nothing)),
                  "You can specify *either* `error`, or `errorplus`/`errorminus`.")
        error ≠ nothing && @argcheck all(isfinite, error)
        errorplus ≠ nothing && @argcheck all(isfinite, errorplus)
        errorminus ≠ nothing && @argcheck all(isfinite, errorminus)
        new{N}(data, error, errorplus, errorminus, meta)
    end
end

"""
    $SIGNATURES

Construct a coordinate, with optional error bars and metadata. `data` should be
a 2- or 3-element tuples of finite real numbers.

You can specify *either*

1. `error`, which will then be used for error bars in both directions, or

2. `errorplus` and/or `errorminus`, for asymmetrical error bars.

Error values can be tuples of the same kind as `data`, or `nothing`.

Metadata can be provided in `meta`.

Users rarely need to use this constructor, see methods of [`Coordinates`](@ref)
for constructing coordinates from arrays.
"""
Coordinate(data; error = nothing, errorplus = nothing, errorminus = nothing,
           meta = nothing) = Coordinate(data, error, errorplus, errorminus, meta)

function print_tex(io::IO, data::NTuple{N, Real}) where N
    print(io, "(")
    for (i, x) in enumerate(data)
        i == 1 || print(io, ", ")
        print(io, x)
    end
    print(io, ")")
end

function print_tex(io::IO, coordinate::Coordinate)
    @unpack data, error, errorplus, errorminus, meta = coordinate
    print_tex(io, data)
    function _print_error(prefix, error)
        if error ≠ nothing
            print(io, " $(prefix) ")
            print_tex(io, error)
        end
    end
    _print_error("+-", error)
    _print_error("+=", errorplus)
    _print_error("-=", errorminus)
    if meta ≠ nothing
        print(io, " [")
        print(io, meta)
        print(io, "]")
    end
    println(io)
end

struct Coordinates{N}
    data::AbstractVector{Union{EmptyLine, Coordinate{N}}}
end

"""
    $SIGNATURES

Convert the argument, which is can be any iterable object, to coordinates.

Specifically,

- `Coordinate` and `EmptyLine` are passed through *as is*,

- 2- or 3-element tuples of finite real numbers are interpreted as coordinates,

- `nothing`, `()`, and coordinates with non-finite numbers become empty lines.

The resulting coordinates are checked for dimension consistency.

## Examples

The following are equivalent:
```julia
Coordinates((x, 1/x) for x in -5:5)
Coordinates(x == 0 ? () : (x, 1/x) for x in -5:5)
Coordinates(x == 0 ? EmptyLine() : Coordinate((x, 1/x)) for x in -5:5)
```
"""
function Coordinates(itr)
    common_N = 0
    check_N(N) = common_N == 0 ? common_N = N :
        @argcheck N == common_N "Incompatible dimensions."
    ensure_c(::Union{EmptyLine, Void, Tuple{}}) = EmptyLine()
    ensure_c(c::Coordinate{N}) where N = (check_N(N); c)
    function ensure_c(data::NTuple{N, Real}) where N
        check_N(N)
        if all(isfinite, data)
            Coordinate(data)
        else
            EmptyLine()
        end
    end
    ensure_c(x) = throw(ArgumentError("Can't interpret $x as a coordinate."))
    data = [ensure_c(data) for data in itr]
    Coordinates{common_N}(data)
end

expand_errors(_::Void...) = nothing

expand_errors(data::Union{Real, Void}...) = map(x -> x isa Void ? 0 : x, data)

coordinate_or_emptyline(data, args...) =
    all(isfinite, data) ? Coordinate(data, args...) : EmptyLine()

"""
    $SIGNATURES

Two dimensional coordinates from two vectors, with error bars.
"""
function Coordinates(x::AbstractVector, y::AbstractVector;
                     xerror = nothing, yerror = nothing,
                     xerrorplus = nothing, yerrorplus = nothing,
                     xerrorminus = nothing, yerrorminus = nothing,
                     meta = nothing)
    Coordinates{2}(@. coordinate_or_emptyline(tuple(x, y),
                                              expand_errors(xerror, yerror),
                                              expand_errors(xerrorplus, yerrorplus),
                                              expand_errors(xerrorminus, yerrorminus),
                                              meta))
end

"""
    $SIGNATURES

Three dimensional coordinates from two vectors, with error bars.
"""
function Coordinates(x::AbstractVector, y::AbstractVector, z::AbstractVector;
                     xerror = nothing, yerror = nothing, zerror = nothing,
                     xerrorplus = nothing, yerrorplus = nothing, zerrorplus = nothing,
                     xerrorminus = nothing, yerrorminus = nothing, zerrorminus = nothing,
                     meta = nothing)
    Coordinates{3}(@. coordinate_or_emptyline(tuple(x, y, z),
                                              expand_errors(xerror,
                                                            yerror,
                                                            zerror),
                                              expand_errors(xerrorplus,
                                                            yerrorplus,
                                                            zerrorplus),
                                              expand_errors(xerrorminus,
                                                            yerrorminus,
                                                            zerrorminus),
                                              meta))
end

"""
    $SIGNATURES

Return new coordinates, inserting [`EmptyLine`](@ref) after every `stride`
lines.
"""
function insert_scanlines(coordinates::Coordinates{N}, stride) where N
    data = Vector{Union{EmptyLine, Coordinate{N}}}()
    for (i, coordinate) in enumerate(coordinates.data)
        push!(data, coordinate)
        if i % stride == 0
            push!(data, EmptyLine())
        end
    end
    Coordinates(data)
end

"""
    $SIGNATURES

Construct coordinates from a matrix of values and edge vectors, such that
``z[i,j]`` corresponds to `x[i]` and `y[j]`. Empty scanlines are inserted,
consistently with the `mesh/ordering=x varies` option of `pgfplots` (the
default).

```jldoctest
x = linspace(0, 1, 10)
y = linspace(-1, 2, 13)
z = sin.(x) + cos.(y')
Coordinates(x, y, z)
"""
function Coordinates(x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
                     meta::Union{Void, AbstractMatrix} = nothing)
    meta ≠ nothing && @argcheck size(meta) == size(z)
    insert_scanlines(Coordinates(matrix_xyz(x, y, z)...;
                                 meta = meta ≠ nothing ? vec(meta) : meta),
                     length(x))
end

function print_tex(io::IO, coordinates::Coordinates)
    print_indent(io) do io
        println(io, "coordinates {")
        for coordinate in coordinates.data
            print_tex(io, coordinate)
        end
        print(io, "}")
    end
end

#########
# Table #
#########

"""
    $SIGNATURES

Expand scanlines, which is a vector of scanline positions or an integer for
repeated scanlines, into a `Vector{Int}`.
"""
expand_scanlines(n::Int, nrow) = n > 0 ? (n:n:nrow) : Vector{Int}()

expand_scanlines(v::Vector{Int}, _) = v

expand_scanlines(itr, _) = collect(Int, itr)

struct Table <: OptionType
    options::Options
    data::AbstractMatrix
    colnames::Union{Void, Vector{String}}
    scanlines::AbstractVector{Int}
    function Table(options::Options, data::AbstractMatrix,
                   colnames::Union{Void, Vector{String}},
                   scanlines::AbstractVector{Int})
        nrow, ncol = size(data)
        if colnames ≠ nothing
            @argcheck allunique(colnames) "Column names are not unique."
            @argcheck length(colnames) == ncol
        end
        new(options, data, colnames, scanlines)
    end
end

"""
    $SIGNATURES

Data structure for emitting coordinates as a `table` in `pgfplots`.

`options` stores the options. `data` is a matrix, which contains the contents of
the table, which will be printed using `print_tex`. `colnames` is a vector of
column names (converted to string), or `nothing` for a table with no column
names.

`scanlines` specifies the row indexes after which a newline will be insterted,
this can be used for skipping coordinates or implicitly defining the dimensions
of a matrix for `surf` and `mesh` plots. They are expanded using
[`expand_scanlines`](@ref).
"""
function Table(options::Options, data::AbstractMatrix, colnames, scanlines)
    Table(options, data,
          colnames ≡ nothing ? colnames : collect(String, colnames),
          expand_scanlines(scanlines, size(data, 1)))
end

"""
    $SIGNATURES

Convert the arguments to `data`, `colnames`, `scanlines` suitable for use in
`Table`, and return these in a tuple.

This method should be defined for conversion into `Table`s, with wrapper methods
handing options.
"""
table_fields(rest...) = table_fields(collect(rest)) # fallback

table_fields(itr) = table_fields(collect(itr))

"""
    $SIGNATURES

`data` provided directly as a matrix, `colnames` and `scanlines` are optional.
"""
table_fields(data::AbstractMatrix; colnames = nothing, scanlines = 0) =
    data, colnames, scanlines

"""
    $SIGNATURES

Named columns provided as a vector of pairs, eg `[:x => 1:10, :y => 11:20]`.
Symbols or strings are accepted as column names.
"""
table_fields(name_column_pairs::Vector{<: Pair}) =
    hcat(last.(name_column_pairs)...), first.(name_column_pairs), 0

"""
    $SIGNATURES

Unnamed columns, given as vectors.
"""
table_fields(columns::Vector{<: AbstractVector}) = hcat(columns...), nothing, 0

"""
    $SIGNATURES

Use the keyword arguments as columns.
"""
table_fields(; named_columns...) = table_fields(Pair(nc...) for nc in named_columns)

table_fields(::AbstractVector) =
    throw(ArgumentError("Could not determine whether columns are named from the element type."))

function table_fields(x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
                      meta::Union{Void, AbstractMatrix} = nothing)
    colnames = ["x", "y", "z"]
    columns = hcat(matrix_xyz(x, y, z)...)
    if meta ≠ nothing
        @argcheck size(z) == size(meta) "Incompatible sizes."
        push!(colnames, "meta")
        columns = hcat(columns, vec(meta))
    end
    columns, colnames, length(x)
end

"""
    Table([options], args...)

Construct a table from the given arguments. Examples:

```julia
Table(["x" => 1:10, "y" => 11:20])        # from a vector

Table([1:10, 11:20])                      # same contents, unnamed

Table(Dict(:x => 1:10, :y = 11:20))       # a Dict with symbols

Table(@pgf { "x index" = 2, "y index" = 1" }, randn(10, 3))

let x = linspace(0, 1, 10), y = linspace(-2, 3, 15)
    Table(x, y, sin.(x + y'))             # edges & matrix
end
```

[`table_fields`](@ref) is used to convert the arguments after options. See its
methods for possible conversions.
"""
Table(options::Options, args...; kwargs...) =
    Table(options, table_fields(args...; kwargs...)...)

Table(args...; kwargs...) =
    Table(Options(), table_fields(args...; kwargs...)...)

function print_tex(io_main::IO, table::Table)
    @unpack options, data, colnames, scanlines = table
    print_indent(io_main) do io
        print(io, "table ")
        print_options(io, options)
        print(io, "{")
        _sep() = print(io, "  ")
        if colnames ≠ nothing
            for colname in colnames
                print(io, colname)
                _sep()
            end
        end
        println(io)
        for row_index in indices(data, 1)
            for col_index in indices(data, 2)
                print_tex(io, data[row_index, col_index])
                _sep()
            end
            println(io)
            if row_index ∈ scanlines
                println(io)
            end
        end
        print(io, "}")
    end
end

#############
# TableFile #
#############

"""
$(TYPEDEF)

Placeholder for a table for which data is read directly from a file. Use the
[`Table`](@ref) constructor.
"""
struct TableFile <: OptionType
    options::Options
    path::AbstractString
end

"""
    $SIGNATURES

For reading tables directly from files. See the `pgfplots` manual for the
accepted format.

If you don't use an absolute path, it will be converted to one.
"""
Table(options::Options, path::AbstractString) = TableFile(options, abspath(path))

Table(path::AbstractString) = Table(Options(), path)

function print_tex(io_main::IO, tablefile::TableFile)
    @unpack options, path = tablefile
    print_indent(io_main) do io
        print(io, "table ")
        print_options(io, options)
        print(io, "{$(path)}")
    end
end

############
# Graphics #
############

struct Graphics <: OptionType
    filename::String
    options::Options
end

function Graphics(filename::String, args::Vararg{PGFOption})
    Graphics(filename, dictify(args))
end

function print_tex(io_main::IO, t::Graphics)
    print_indent(io_main) do io
        print(io, "graphics ")
        print_options(io, t.options)
        print(io, "{", t.filename, "}")
    end
end

########
# Plot #
########

"Types accepted by `Plot` for the field `data`."
const PlotData = Union{Coordinates, Table, TableFile, Expression, Graphics}

"""
$(TYPEDEF)

Corresponds to the `\\addplot[3][+]` family of `pgfplot` commands.

Instead of the default constructor, use `Plot([options], data, trailing...)` and
similar (`PlotInc`, `Plot3`, `Plot3Inc`) in user code.
"""
struct Plot <: OptionType
    is3d::Bool
    incremental::Bool
    options::Options
    data::PlotData
    trailing::AbstractVector{Any} # FIXME can/should we be more specific?
end

Plot(is3d::Bool, incremental::Bool, options::Options, data::PlotData,
     trailing::Tuple) = Plot(is3d, incremental, options, data, collect(trailing))

Base.push!(plot::Plot, element) = (push!(plot.trailing, element); plot)
Base.append!(plot::Plot, element) = (append!(plot.trailing, element); plot)

"""
    Plot([options::Options], data, trailing...)

A plot with the given `data` (eg [`Coordinates`](@ref), [`Table`](@ref),
[`Expression`](@ref), …) and `options`, which is empty by default.

Corresponds to `\\addplot` in `pgfplots`.

`trailing` can be used to provide *trailing path commands* (eg `\\closedcycle`,
see the `pgfplots` manual), which are emitted using `print_tex`, before the
terminating `;`.
"""
Plot(options::Options, data::PlotData, trailing...) =
    Plot(false, false, options, data, trailing)

Plot(data::PlotData, trailing...) =
    Plot(false, false, Options(), data, trailing)

"""
    PlotInc([options::Options], data, trailing...)

Corresponds to the `\\addplot+` form in `pgfplots`.

For the interpretation of the other arguments, see `Plot(::Options, ::PlotData, ...)`.
"""
PlotInc(options::Options, data::PlotData, trailing...) =
    Plot(false, true, options, data, trailing)

PlotInc(data::PlotData, trailing...) =
    Plot(false, true, Options(), data, trailing)

"""
    Plot3([options::Options], data, trailing...)

Corresponds to the `\\addplot3` form in `pgfplots`.

For the interpretation of the other arguments, see `Plot(::Options, ::PlotData, ...)`.
"""
Plot3(options::Options, data::PlotData, trailing...) =
    Plot(true, false, options, data, trailing)

Plot3(data::PlotData, trailing...) =
    Plot(true, false, Options(), data, trailing)

"""
    Plot3([options::Options], data, trailing...)

Corresponds to the `\\addplot3+` form in `pgfplots`.

For the interpretation of the other arguments, see `Plot(::Options, ::PlotData, ...)`.
"""
Plot3Inc(options::Options, data::PlotData, trailing...) =
    Plot(true, true, options, data, trailing)

Plot3Inc(data::PlotData, trailing...) =
    Plot(true, true, Options(), data, trailing)

function save(filename::String, plot::Plot; kwargs...)
    save(filename, Axis(plot); kwargs...)
end

function print_tex(io_main::IO, plot::Plot)
    print_indent(io_main) do io
        @unpack is3d, incremental, options, data, trailing = plot
        print(io, "\\addplot")
        is3d && print(io, "3")
        incremental && print(io, "+")
        print_options(io, options)
        print_tex(io, data)
        for t in trailing
            print_tex(io, t)
        end
        print(io, ";")
    end
end

struct Legend
    labels::Vector{String}
end

print_tex(io_main::IO, l::Legend) = print(io_main, "\\legend{", join(l.labels, ", "), "}")

###############
# LegendEntry #
###############

struct LegendEntry
    options::Options
    name::AbstractString
    isexpanded::Bool
end

"""
    LegendEntry([options::Options], name, [isexpanded])

Corresponds to the `\\addlegendentry` and `\\addlegendentryexpanded` forms of
`pgfplots`.
"""
LegendEntry(options::Options, name::AbstractString, isexpanded = false)

LegendEntry(name::AbstractString, isexpanded = false) =
    LegendEntry(Options(), name, isexpanded)

function print_tex(io_main::IO, legendentry::LegendEntry)
    print_indent(io_main) do io
        @unpack options, name, isexpanded = legendentry
        print(io, "\\addlegendentry")
        isexpanded && print(io, "expanded")
        print_options(io, options)
        print(io, "{")
        print(io, name)
        print(io, "}")
    end
end
