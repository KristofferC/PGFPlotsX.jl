##############
# Expression #
##############

"""
    Expression(expressions::Vector{String})

    Expression(strings::String...)

An `Expression` is a string or multiple strings, representing a function, and is
written in a way LaTeX understands.
"""
struct Expression <: OptionType
    fs::Vector{String}
end

Expression(str::String...) = Expression(collect(String, str))

function print_tex(io::IO, f::Expression)
    multiple_f = length(f.fs) != 1
    multiple_f && println(io, "(")
    for (i, fstr) in enumerate(f.fs)
        print(io, "{", fstr, "}")
        if i != length(f.fs)
            println(io, ",")
        end
    end
    multiple_f && print(io, ")")
    nothing
end

##############
# Coordinate #
##############

"""
    EmptyLine()

Placeholder for an empty line.

In 2D plots, PGFPlots treats empty lines as *jumps* by default.

In 3D plots (eg `surf` and similar), it is used as a scanline separator to
establish the dimensions of the matrix.
"""
struct EmptyLine end

print_tex(io::IO, ::EmptyLine) = println(io)

struct Coordinate{N}
    data::NTuple{N, Real}
    error::Union{Nothing, NTuple{N, Real}}
    errorplus::Union{Nothing, NTuple{N, Real}}
    errorminus::Union{Nothing, NTuple{N, Real}}
    meta::Any
    function Coordinate(data::NTuple{N, Real},
                        error::Union{Nothing, NTuple{N, Real}},
                        errorplus::Union{Nothing, NTuple{N, Real}},
                        errorminus::Union{Nothing, NTuple{N, Real}}, meta) where N
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

Convert the argument, which can be any iterable object, to coordinates.

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
    ensure_c(::Union{EmptyLine, Nothing, Tuple{}}) = EmptyLine()
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

expand_errors(_::Nothing...) = nothing

expand_errors(data::Union{Real, Nothing}...) = map(x -> x isa Nothing ? 0 : x, data)

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
`z[i,j]` corresponds to `x[i]` and `y[j]`. Empty scanlines are inserted,
consistently with the `mesh/ordering=x varies` option of PGFPlots (the
default).

```julia
x = range(0; stop = 1, length = 10)
y = range(-1; stop = 2, length = 13)
z = sin.(x) + cos.(y')
Coordinates(x, y, z)
```
"""
function Coordinates(x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
                     meta::Union{Nothing, AbstractMatrix} = nothing)
    meta ≠ nothing && @argcheck size(meta) == size(z)
    insert_scanlines(Coordinates(matrix_xyz(x, y, z)...;
                                 meta = meta ≠ nothing ? vec(meta) : meta),
                     length(x))
end

function print_tex(io::IO, coordinates::Coordinates)
    println(io, "coordinates {")
    print_indent(io) do io
        for coordinate in coordinates.data
            print_tex(io, coordinate)
        end
    end
    println(io, "}")
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


"Default for additional row separator `\\`."
const ROWSEP = true

"""
Tabular data with optional column names.

This corresponds to the part of tables between `{}`'s in PGFPlots, without the
options or `table`, so that it can also be used for “inline” tables.
[`Table`](@ref) will call the constructor for this type to convert arguments
after `options`.

`data` is a matrix, which contains the contents of the table, which will be
printed using `print_tex`. `colnames` is a vector of column names (converted to
string), or `nothing` for a table with no column names.

When `rowsep` is `true`, an additional `\\\\` is used as a row separator. The
default is `true`, this is recommended to avoid “fragility” issues with inline
tables.

!!! note

    `Table` queries `TableData` for its `rowsep`, and adds the relevant option
    accordingly. When using “inline” tables, eg in options, you have to specify
    this manually for the container. See the gallery for examples.

After each index in `scanlines`, extra row separators are inserted. This can be
used for skipping coordinates or implicitly defining the dimensions of a matrix
for `surf` and `mesh` plots. They are expanded using [`expand_scanlines`](@ref).
"""
struct TableData
    data::AbstractMatrix
    colnames::Union{Nothing, Vector{<: AbstractString}}
    scanlines::AbstractVector{Int}
    rowsep::Bool
    function TableData(data::AbstractMatrix,
                       colnames::Union{Nothing, Vector{<: AbstractString}},
                       scanlines::AbstractVector{Int},
                       rowsep::Bool = ROWSEP)
        if colnames ≠ nothing
            @argcheck allunique(colnames) "Column names are not unique."
            @argcheck length(colnames) == size(data, 2)
        end
        new(data, colnames, scanlines, rowsep)
    end
end

function TableData(data::AbstractMatrix, colnames, scanlines, rowsep = ROWSEP)
    TableData(data,
              colnames ≡ nothing ? colnames : collect(string(c) for c in colnames),
              expand_scanlines(scanlines, size(data, 1)), rowsep)
end

function print_tex(io::IO, tabledata::TableData)
    @unpack data, colnames, scanlines, rowsep = tabledata
    _colsep() = print(io, "  ")
    _rowsep() = print(io, rowsep ? "\\\\\n" : "\n")
    if colnames ≠ nothing
        for colname in colnames
            print(io, colname)
            _colsep()
        end
    end
    _rowsep()
    for row_index in axes(data, 1)
        for col_index in axes(data, 2)
            print_tex(io, data[row_index, col_index])
            _colsep()
        end
        _rowsep()
        if row_index ∈ scanlines
            _rowsep()
        end
    end
end

"""
    $SIGNATURES

Columns, given as vectors.

Use of this constructor is encouraged for conversion, passing on keyword
arguments.
"""
TableData(columns::Vector{<: AbstractVector}, colnames = nothing, scanlines = 0;
          rowsep::Bool = ROWSEP) =
    TableData(hcat(columns...), nothing, 0, rowsep)

TableData(itr; kwargs...) = TableData(collect(itr); kwargs...) # fallback

"""
    $SIGNATURES

`data` provided directly as a matrix.
"""
function TableData(data::AbstractMatrix;
                   colnames = nothing, scanlines = 0, rowsep = ROWSEP)
    TableData(data, colnames, scanlines, rowsep)
end

"""
    $SIGNATURES

Named columns provided as a vector of pairs, eg `[:x => 1:10, :y => 11:20]`.
Symbols or strings are accepted as column names.
"""
function TableData(name_column_pairs::Vector{<: Pair};
                   scanlines = 0, rowsep::Bool = ROWSEP)
    TableData(hcat(last.(name_column_pairs)...), first.(name_column_pairs),
              scanlines, rowsep)
end

TableData(rest::AbstractVector...; kwargs...) = TableData(collect(rest); kwargs...)

TableData(name_column_pairs::Pair...; kwargs...) =
    TableData(collect(name_column_pairs); kwargs...)

"""
    $SIGNATURES

Use the keyword arguments as columns.

Note that this precludes the possibily of providing other keywords; see the
other constructors.
"""
TableData(; named_columns...) = TableData(Pair(nc...) for nc in named_columns)

TableData(::AbstractVector; kwargs...) =
    throw(ArgumentError("Could not determine whether columns are named from the element type."))

function TableData(x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
                   meta::Union{Nothing, AbstractMatrix} = nothing,
                   rowsep::Bool = ROWSEP)
    colnames = ["x", "y", "z"]
    columns = hcat(matrix_xyz(x, y, z)...)
    if meta ≠ nothing
        @argcheck size(z) == size(meta) "Incompatible sizes."
        push!(colnames, "meta")
        columns = hcat(columns, vec(meta))
    end
    TableData(columns, colnames, length(x), rowsep)
end

struct Table <: OptionType
    options::Options
    content::Union{TableData, AbstractString}
    Table(options::Options, content::Union{TableData, AbstractString}) =
        new(options, content)
end

"""
    Table([options], ...; ...)

Tabular data with options, corresponding to `table[options] { ... }` in
PGFPlots.

`options` stores the options. If that is followed by an `AbstractString`, that
will be used as a filename to read data from, otherwise all the arguments are
passed on to [`TableData`](@ref).

 Examples:

```julia
Table(["x" => 1:10, "y" => 11:20])        # from a vector

Table([1:10, 11:20])                      # same contents, unnamed

Table(Dict(:x => 1:10, :y = 11:20))       # a Dict with symbols

@pgf Table({ "x index" = 2, "y index" = 1" }, randn(10, 3))

let x = range(0; stop = 1, length = 10), y = range(-2; stop =  3, length = 15)
    Table(x, y, sin.(x + y'))             # edges & matrix
end
```
"""
Table(options::Options, args...; kwargs...) =
    Table(options, TableData(args...; kwargs...))

Table(args...; kwargs...) = Table(Options(), args...; kwargs...)

"""
    $SIGNATURES

Options to mix in for the container. Currently used for `TableData` and `Table`.
"""
container_options(tabledata::TableData, ::Table) =
    Options("row sep" => tabledata.rowsep ? "\\\\" : "newline")

container_options(::AbstractString, ::Table) = Options() # included from file

function print_tex(io::IO, table::Table)
    @unpack options, content = table
    all_options = merge(container_options(content, table), options)
    print(io, "table")
    if content isa String
        print_options(io, all_options, newline = false)
        print(io, "{")
        print(io, content)
        print(io, "}")
    else
        print_options(io, all_options, newline = true)
        println(io, "{")
        print_indent(io, content)
        println(io, "}")
    end
end

############
# Graphics #
############

"""
    Graphics([options], filename)

`Graphics` data simply wraps an image (eg a `.png` file).
"""
struct Graphics <: OptionType
    options::Options
    filename::String
end

function Graphics(filename::String, args::Vararg{PGFOption})
    Graphics(dictify(args), filename)
end

function print_tex(io::IO, t::Graphics)
    print(io, "graphics")
    print_options(io, t.options; newline = false)
    println(io, "{", t.filename, "}")
end

########
# Plot #
########

"Types accepted by `Plot` for the field `data`."
const PlotData = Union{Coordinates, Table, Expression, Graphics}

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

@forward Plot.trailing Base.push!, Base.append!

"""
    Plot([options::Options], data, trailing...)

A plot with the given `data` (eg [`Coordinates`](@ref), [`Table`](@ref),
[`Expression`](@ref), …) and `options`, which is empty by default.

Corresponds to `\\addplot` in PGFPlots.

`trailing` can be used to provide *trailing path commands* (eg `\\closedcycle`,
see the PGFPlots manual), which are emitted using `print_tex`, before the
terminating `;`.
"""
Plot(options::Options, data::PlotData, trailing...) =
    Plot(false, false, options, data, trailing)

Plot(data::PlotData, trailing...) =
    Plot(false, false, Options(), data, trailing)

"""
    PlotInc([options::Options], data, trailing...)

Corresponds to the `\\addplot+` form in PGFPlots.

For the interpretation of the other arguments, see `Plot(::Options, ::PlotData, ...)`.
"""
PlotInc(options::Options, data::PlotData, trailing...) =
    Plot(false, true, options, data, trailing)

PlotInc(data::PlotData, trailing...) =
    Plot(false, true, Options(), data, trailing)

"""
    Plot3([options::Options], data, trailing...)

Corresponds to the `\\addplot3` form in PGFPlots.

For the interpretation of the other arguments, see `Plot(::Options, ::PlotData, ...)`.
"""
Plot3(options::Options, data::PlotData, trailing...) =
    Plot(true, false, options, data, trailing)

Plot3(data::PlotData, trailing...) =
    Plot(true, false, Options(), data, trailing)

"""
    Plot3Inc([options::Options], data, trailing...)

Corresponds to the `\\addplot3+` form in PGFPlots.

For the interpretation of the other arguments, see `Plot(::Options, ::PlotData, ...)`.
"""
Plot3Inc(options::Options, data::PlotData, trailing...) =
    Plot(true, true, options, data, trailing)

Plot3Inc(data::PlotData, trailing...) =
    Plot(true, true, Options(), data, trailing)

function save(filename::String, plot::Plot; kwargs...)
    save(filename, Axis(plot); kwargs...)
end

function print_tex(io::IO, plot::Plot)
    @unpack is3d, incremental, options, data, trailing = plot
    print(io, "\\addplot")
    is3d && print(io, "3")
    incremental && print(io, "+")
    print_options(io, options)
    print_indent(io) do io
        print_tex(io, data)
        for t in trailing
            print_tex(io, t)
        end
        println(io, ";")
    end
end

struct Legend
    labels::Vector{String}
end

"""
    $SIGNATURES

Corresponds to `\\legend{ ... }` in PGFPlots. Specifies multiple legends for
an axis, its position is irrelevant.

`labels` are wrapped in `{}`s, so they can contain `,`.
"""
Legend(labels::AbstractString...) = Legend(collect(String, labels))

print_tex(io::IO, l::Legend) =
    println(io, "\\legend{{", join(l.labels, "}, {"), "}}")

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
PGFPlots.
"""
LegendEntry(options::Options, name::AbstractString, isexpanded = false)

LegendEntry(name::AbstractString, isexpanded = false) =
    LegendEntry(Options(), name, isexpanded)

function print_tex(io::IO, legendentry::LegendEntry)
    @unpack options, name, isexpanded = legendentry
    print(io, "\\addlegendentry")
    isexpanded && print(io, "expanded")
    print_options(io, options; newline = false)
    print(io, "{")
    print(io, name)
    println(io, "}")
end
