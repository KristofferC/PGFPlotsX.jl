########
# Plot #
########

struct Plot <: AxisElement
    elements::AbstractVector{Any}
    options::OrderedDict{Any, Any}
    label
    incremental::Bool
    _3d::Bool
end

Base.push!(plot::Plot, element) = (push!(plot.elements, element); plot)
Base.append!(plot::Plot, element) = (append!(plot.elements, element); plot)

function Plot(elements::AbstractVector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(elements, dictify(args), label, incremental, false)
end

function Plot3(element::Vector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(element, dictify(args), label, incremental, true)
end

Plot(options::OrderedDict, element; kwargs...) = Plot(element, options; kwargs...)
Plot(element, args...; kwargs...) = Plot([element], args...; kwargs...)
Plot3(element, args...; kwargs...) = Plot3([element], args...; kwargs...)
Plot3(options::OrderedDict, element; kwargs...) = Plot3(element, options; kwargs...)

function save(filename::String, plot::Plot; kwargs...)
    save(filename, Axis(plot); kwargs...)
end

function print_tex(io_main::IO, p::Plot)
    print_indent(io_main) do io
        print(io, "\\addplot")
        if p._3d
            print(io, "3")
        end
        if p.incremental
            print(io, "+")
        end
        print_options(io, p.options)
        for element in p.elements
            print_tex(io, element, p)
        end
        print(io, ";")
        if p.label != nothing
            print(io, "\n\\addlegendentry{$(p.label)}")
        end
    end
end

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
    x_grid = @. first(tuple(x, y'))
    y_grid = @. last(tuple(x, y'))
    @argcheck size(x_grid) == size(y_grid) == size(z) "Incompatible sizes."
    insert_scanlines(Coordinates(vec(x_grid), vec(y_grid), vec(z); meta = meta),
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

struct Table <: OptionType
    data
    options::OrderedDict{Any, Any}

    # Some ambiguity fixing
    Table(data, options::OrderedDict{Any, Any}) = new(data, options)

    Table(data::Union{DataStructures.OrderedDict, Pair, String},
          options::DataStructures.OrderedDict{Any,Any}) = new(data, options)

    Table(data::String, options::DataStructures.OrderedDict{Any,Any}) = new(data, options)
end

function Table(data, args::Vararg{PGFOption})
    Table(data, dictify(args))
end


function Table(data::String, args::Vararg{PGFOption})
    Table(data, dictify(args))
end

function Table(args::Vararg{PGFOption}; kwargs...)
    Table(kwargs, dictify(args))
end

function print_tex(io_main::IO, t::Table)
    print_indent(io_main) do io
        print(io, "table ")
        print_options(io, t.options)
        print(io, "{")
        print_tex(io, t.data, t)
        print(io, "}")
    end
end

print_tex(io::IO, str::String, ::Table) = print(io, str)
function print_tex(io::IO, v::AbstractVector, ::Table)
    length(v) == 0 && return
    if v[1] isa Tuple # Assume the kw constructor was called
        # Do some basic checking
        # Print header
        vs = []
        first = true
        l = -1
        for s in v
            if !(length(s) == 2) || !(s[1] isa Symbol) || !(s[2] isa AbstractVector)
                error("Expected a call like Table(; a = [1,2,...], b = [2,3,...])")
            end

            if first
                l = length(s[2])
            end

            if !(l == length(s[2]))
                error("length of data in columns not the same")
            end

            print(io, s[1], "    ")
            push!(vs, s[2])
        end

        println(io)

        v_mat = permutedims(hcat(vs...), (2,1))

        for j in 1:size(v_mat, 2)
            for i in 1:size(v_mat, 1)
                print(io, v_mat[i, j], "    ")
            end
            println(io)
        end
    else
        println(io, join(v, "\n"))
    end
end

struct Graphics <: OptionType
    filename::String
    options::OrderedDict{Any, Any}
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


struct Legend
    labels::Vector{String}
end

print_tex(io_main::IO, l::Legend) = print(io_main, "\\legend{", join(l.labels, ", "), "}")
