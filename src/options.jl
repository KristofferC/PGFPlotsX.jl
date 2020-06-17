struct Options
    dict::OrderedDict{Any, Any}
    print_empty::Bool
end

# Wrapper to wrap arguments in the `@pgf {theme...,}` syntax to
# insert all entries in `theme` into the Option
struct MergeEntry
    d::Options
end

"""
    $SIGNATURES

Options passed to PGFPlots for various structures (`table`, `plot`, etc).

Contents emitted in `key = value` form, or `key` when `value ≡ nothing`. Also
see the [`@pgf`](@ref) convenience macro.

When `print_empty = false` (the default), empty options are not printed. Use
`print_empty = true` to force printing a `[]` in this case.
"""
function Options(args::Union{Pair,MergeEntry}...; print_empty::Bool = false)
    d = OrderedDict()
    for arg in args
        if arg isa Pair
            k, v = arg
            d[k] = v
        elseif arg isa MergeEntry
            for (k, v) in arg.d.dict
                d[k] = v
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

Base.copy(options::Options) = deepcopy(options)

Base.merge(a::Options, b::Options) =
    Options(merge(a.dict, b.dict), a.print_empty || b.print_empty)

function prockey(key)
    if isa(key, Symbol) || isa(key, String)
        return :($(string(key)) => nothing)
    elseif @capture(key, (a_ : b_) | (a_ => b_) | (a_ = b_))
        return :($(string(a))=>$b)
    elseif @capture(key, g_...)
        return :($MergeEntry($g))
    end
    error("Invalid pgf option $key")
end

function procmap(d)
    if @capture(d, f_(xs__))
        return :($f($(map(procmap, xs)...)))
    elseif !@capture(d, {xs__})
        return d
    else
        return :($(Options)($(map(prockey, xs)...); print_empty = true))
    end
end

"""
    @pgf { ... }

    @pgf some(nested(form({ ... })),
              with_multiple_options({ ... }))

Construct [`Options`](@ref) from comma-delimited `key` (without value),
`key = value`, `key : value`, or `key => value` pairs enclosed in `{ ... }`,
anywhere in the expression.

The argument is traversed recursively, allowing `{ ... }` expressions in
multiple places.

Multi-word keys need to be either quoted, or written with underscores replacing
spaces.

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

function Base.merge!(a::OptionType, options::Options)
    for (k, v) in options.dict
        a[k] = v
    end
    return a
end

"""
    $(SIGNATURES)

Print options between `[]`. For each option, the value is printed using
[`print_opt`](@ref). Unless `newline == true` (the default), a newline follows
the `]`, otherwise a space.

Note that you can also use `print_tex` for this purpose, in which case a newline is not
printed.
"""
function print_options(io::IO, options::Options; newline = true)
    @unpack dict, print_empty = options
    if isempty(dict)
        print_empty && print(io, "[]")
    else
        print(io, "[")
        print_opt(io, options)
        print(io, "]")
    end
    newline ? println(io) : print(io, " ")
end

print_tex(io::IO, options::Options) = print_options(io, options; newline = false)

accum_opt!(d::AbstractDict, opt::String) = d[opt] = nothing
accum_opt!(d::AbstractDict, opt::Pair) = d[first(opt)] = last(opt)
function accum_opt!(d::AbstractDict, opt::AbstractDict)
    for (k, v) in opt
        d[k] = v
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
    replace_underline(x) = x
    replace_underline(x::Union{String, Symbol}) = replace(string(x), "_" => " ")
    for (i, (k, v)) in enumerate(dict)
        print_opt(io, replace_underline(k))
        if v != nothing
            print(io, "={")
            print_opt(io, v)
            print(io, "}")
        end
        if i != length(dict)
          print(io, ", ")
        end
    end
end

print_opt(io::IO, s) = print_tex(io, s)
print_opt(io::IO, v::AbstractVector) = print(io, join(v, ","))

function print_opt(io::IO, t::Tuple)
    length(t) == 0 && return
    for i in 1:length(t)
        i != 1 && print(io, "{")
        print_opt(io, t[i])
        i != length(t) && print(io, "}")
    end
end

print_opt(io::IO, str::AbstractString) = print(io, str)
