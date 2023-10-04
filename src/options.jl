struct Options
    dict::OrderedDict{String, Any}
    print_empty::Bool
end

# normalize keys to String
normalize_key(x::Symbol) = replace(string(x), "_" => " ")
normalize_key(x::String) = x
normalize_key(x::AbstractString) = String(x)
normalize_key(x) = error("Invalid pgf key $x")

function Base.show(io::IO, ::MIME"text/plain", options::Options)
    print_options(io, options; newline = false)
end

# Wrapper to wrap arguments in the `@pgf {theme...,}` syntax to
# insert all entries in `theme` into the Option
struct MergeEntry
    d::Options
end

"""
    $(SIGNATURES)

Options passed to PGFPlots for various structures (`table`, `plot`, etc).

Contents emitted in `key = value` form, or `key` when `value ≡ nothing`. Example:

```jldoctest
julia> PGFPlotsX.Options(:color => "red", :only_marks => nothing)
[color={red}, only marks]
```

The constuctor is not exported but part of the API, for use in packages that depend on
PGFPlotsX, or code producing complicated plots. It is recommended that the [`@pgf`](@ref)
macro is used in scripts and interactive code.

When `print_empty = false` (the default), empty options are not printed. Use
`print_empty = true` to force printing a `[]` in this case.
"""
function Options(args::Union{Pair,MergeEntry}...; print_empty::Bool = false)
    d = OrderedDict{String,Any}()
    for arg in args
        if arg isa Pair
            k, v = arg
            d[normalize_key(k)] = v
        elseif arg isa MergeEntry
            for (k, v) in arg.d.dict
                d[normalize_key(k)] = v
            end
        else
            error("unhandled arg type $arg")
        end
    end
    return Options(d, print_empty)
end

Base.getindex(o::Options, args...; kwargs...) = getindex(o.dict, args...; kwargs...)
Base.setindex!(o::Options, args...; kwargs...) = (setindex!(o.dict, args...; kwargs...); o)
Base.delete!(o::Options, args...; kwargs...) = (delete!(o.dict, args...; kwargs...); o)
Base.haskey(o::Options, args...; kwargs...) = haskey(o.dict, args...; kwargs...)

Base.copy(options::Options) = deepcopy(options)

function Base.merge(options::Options, others::Options...)
    args = (options, others...)
    Options(mapreduce(opts -> opts.dict, merge, args),
            mapreduce(opts -> opts.print_empty, |, args))
end

function prockey(key)
    if isa(key, Symbol) || isa(key, String)
        return :($(normalize_key(key)) => nothing)
    elseif @capture(key, @raw_str(str_))
        return :($(normalize_key(str)) => nothing)
    elseif @capture(key, (a_ : b_) | (a_ => b_) | (a_ = b_))
        return :($(normalize_key(a))=>$b)
    elseif @capture(key, g_...)
        return :($MergeEntry($g))
    end
    error("Invalid pgf option $key")
end

if !isdefined(Base, :mapany)
    mapany(f, itr) = map!(f, Vector{Any}(undef, length(itr)::Int), itr)  # convenient for Expr.args
else
    using Base: mapany
end

function procmap(d)
    if @capture(d, f_(xs__))
        return :($f($(mapany(procmap, xs)...)))
    elseif !@capture(d, {xs__})
        return d
    else
        return :($(Options)($(mapany(prockey, xs)...); print_empty = true))
    end
end

"""
    @pgf { ... }

    @pgf some(nested(form({ ... })),
              with_multiple_options({ ... }))

Construct [`Options`](@ref) from comma-delimited `key` (without value),
`key = value`, `key : value`, or `key => value` pairs enclosed in `{ ... }`,
anywhere in the expression.

Keys can be

1. symbols, which are converted to strings, with `_` replaced by spaces,

2. strings or raw strings, used as is

The argument is traversed recursively, allowing `{ ... }` expressions in
multiple places.

Multi-word keys need to be either quoted, or written as strings with underscores.

```julia
@pgf {
    "only marks",
    mark_size = "0.6pt",
    mark = "o",
    color => "black",
}
```

Another `Options` can be spliced into one being created using `...`, e.g.

```
theme = @pgf {xmajorgrids, x_grid_style = "white"}

axis_opt = @pgf {theme..., title = "My figure"}
```

Use `{}` for empty options that print as `[]` in LaTeX.
"""
macro pgf(ex)
    esc(prewalk(procmap, ex))
end

"""
Types also accepted as options.
"""
const PGFOption = Union{Pair, String, Options}

# TODO: Make OptionType a trait somehow?
"""
Subtypes have an `options::Options` field.
"""
abstract type OptionType end

Base.getindex(o::OptionType, args...; kwargs...) = getindex(o.options, args...; kwargs...)
Base.setindex!(o::OptionType, args...; kwargs...) = (setindex!(o.options, args...; kwargs...); o)
Base.delete!(o::OptionType, args...; kwargs...) = (delete!(o.options, args...; kwargs...); o)

Base.copy(a::OptionType) = deepcopy(a)

function Base.merge!(options::Union{Options,OptionType}, others::Options...)
    for other in others
        for (k, v) in other.dict
            options[k] = v
        end
    end
    options
end

"""
    $(SIGNATURES)

Print options between `brackets` (defaults to "[]"). For each option, the value is printed
using [`print_opt`](@ref). Unless `newline == true` (the default), a newline follows the
closing bracket, otherwise a space.

# Notes

1. you can also use `print_tex` for this purpose, in which case a newline is not printed.

2. customizing brackets is only needed in some corner cases, cf [LegendImage](@ref).
"""
function print_options(io::IO, options::Options; newline = true, brackets = "[]")
    @argcheck length(brackets) == 2
    @unpack dict, print_empty = options
    if isempty(dict)
        print_empty && print(io, brackets)
    else
        print(io, brackets[1])
        print_opt(io, options)
        print(io, brackets[2])
    end
    newline ? println(io) : print(io, " ")
end

print_tex(io::IO, options::Options) = print_options(io, options; newline = false)

accum_opt!(d::AbstractDict, opt::Union{String,Symbol}) = d[normalize_key(opt)] = nothing
accum_opt!(d::AbstractDict, opt::Pair) = d[normalize_key(first(opt))] = last(opt)
function accum_opt!(d::AbstractDict, opt::AbstractDict)
    for (k, v) in opt
        d[normalize_key(k)] = v
    end
end

function Base.append!(options::Options, opts)
    for opt in opts
        accum_opt!(options.dict, opt)
    end
    options
end

function Base.push!(options::Options, opts::Union{String,Pair}...)
    append!(options, opts)
end

function dictify(args)
    options = Options()
    for arg in args
        accum_opt!(options.dict, arg)
    end
    options
end

function print_opt(io::IO, options::Options)
    @unpack dict = options
    for (i, (k, v)) in enumerate(dict)
        print_opt(io, k)
        if v != nothing
            print(io, "={")
            print_opt(io, v)
            print(io, "}")
        end
        if i != length(dict)
            if v isa Options
                print(io, ",\n ")
            else
                print(io,",")
            end
        end
    end
end

print_opt(io::IO, s) = print_tex(io, s)

function print_opt(io::IO, v::AbstractVector)
    for (i, o) in enumerate(v)
        i == 1 || print(io, ",")
        print_opt(io, o)
    end
end

function print_opt(io::IO, t::Tuple)
    length(t) == 0 && return
    for i in 1:length(t)
        i != 1 && print(io, "{")
        print_opt(io, t[i])
        i != length(t) && print(io, "}")
    end
end

print_opt(io::IO, str::AbstractString) = print(io, str)
