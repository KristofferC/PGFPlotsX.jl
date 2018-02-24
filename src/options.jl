"""
Options passed to `pgfplots` for various structures (`table`, `plot`, etc).

Contents emitted in `key = value` form, or `key` when `value ≡ nothing`. Also
see the [`@pgf`](@ref) convenience macro.
"""
const Options = OrderedDict{Any, Any}

function prockey(key)
    if isa(key, Symbol) || isa(key, String)
        return :($(string(key)) => nothing)
    elseif @capture(key, (a_ : b_) | (a_ => b_) | (a_ = b_))
        return :($(string(a))=>$b)
    end
    error("Invalid pgf option $key")
end

function procmap(d)
  if @capture(d, f_(xs__))
      return :($f($(map(procmap, xs)...)))
  elseif !@capture(d, {xs__})
      return d
  else
      return :($(Options)($(map(prockey, xs)...)))
  end
end

"""
    @pgf { ... }

    @pgf some(nested(form({ ... })))

Construct [`Options`](@ref) from comma-delimited `key` (without value),
`key = value`, `key : value`, or `key => value` pairs enclosed in `{ ... }`,
anywhere in the expression.

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

Base.getindex(a::OptionType, s::String) = a.options[s]
Base.setindex!(a::OptionType, v, s::String) = (a.options[s] = v; a)
Base.delete!(a::OptionType, s::String) = (delete!(a.options, s); a)
Base.copy(a::OptionType) = deepcopy(a)
function Base.merge!(a::OptionType, d::Options)
    for (k, v) in d
        a[k] = v
    end
    return a
end

function print_options(io::IO, options::Options)
    print(io, " [")
    print_opt(io, options)
    println(io, "]")
end

accum_opt!(d::AbstractDict, opt::String) = d[opt] = nothing
accum_opt!(d::AbstractDict, opt::Pair) = d[first(opt)] = last(opt)
function accum_opt!(d::AbstractDict, opt::AbstractDict)
    for (k, v) in opt
        d[k] = v
    end
end

function dictify(args)
    d = Options()
    for arg in args
        accum_opt!(d, arg)
    end
    return d
end

function print_opt(io::IO, d::AbstractDict)
    replace_underline(x) = x
    replace_underline(x::Union{String, Symbol}) = replace(string(x), "_", " ")
    for (i, (k, v)) in enumerate(d)
        print(io, replace_underline(k))
        if v != nothing
            print(io, "={")
            print_opt(io, v)
            print(io, "}")
        end
        if i != length(d)
          print(io, ", ")
        end
    end
end

print_opt(io::IO, s) = print_tex(io, s)
print_opt(io::IO, v::Vector) = print(io, join(v, ","))

function print_opt(io::IO, t::Tuple)
    length(t) == 0 && return
    for i in 1:length(t)
        i != 1 && print(io, "{")
        print_opt(io, t[i])
        i != length(t) && print(io, "}")
    end
end
