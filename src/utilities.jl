
function print_options(io::IO, options::OrderedDict{Any, Any})
    print(io, "[")
    print_opt(io, options)
    print(io, "]\n")
end

# Print with indent
printi(io::IO, x, i = 0) = print(io, "    "^i, x)
printlni(io::IO, x, i = 0) = print(io, "    "^i, x)


function print_indent(io::IO, str::String)
    for line in split(str, "\n")
        println(io, "    ", line)
    end
end

function print_indent(f, io_main::IO)
    io = IOBuffer()
    f(io)
    print_indent(io_main, String(take!(io)))
end


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
      return :(PGFPlotsX.OrderedDict{Any, Any}($(map(prockey, xs)...)))
  end
end

macro pgf(ex)
    esc(prewalk(procmap, ex))
end

"""
    stringify(io::IO, p::Pair)

Converts a key => value(s) to a string valid as options for PGFPlots.


## Examples:

```
stringify(STDOUT, "legend style" => ["at" => (0.5,-0.15),
                                     "anchor" => "north",
                                     "legend columns" => -1]

stringify(STDOUT, "symbolic x coords" => ["excellent", "good", "neutral"])
```
"""

function dictify(args)
    d = OrderedDict{Any, Any}()
    for arg in args
        accum_opt!(d, arg)
    end
    return d
end

accum_opt!(d::AbstractDict, opt::String) = d[opt] = nothing
accum_opt!(d::AbstractDict, opt::Pair) = d[first(opt)] = last(opt)
function accum_opt!(d::AbstractDict, opt::AbstractDict)
    for (k, v) in opt
        d[k] = v
    end
end

function print_opt(io::IO, d::AbstractDict)
    replace_underline(x) = x
    replace_underline(x::Union{String, Symbol}) = replace(string(x), "_", " ")
    for (k, v) in d
        print(io, replace_underline(k))
        if v != nothing
            print(io, " = {")
            print_opt(io, v)
            print(io, "}")
        end
        print(io, ", ")
    end
end

print_opt(io::IO, s) = print(io, s)
print_opt(io::IO, v::Vector) = print(io, join(v, ","))

function print_opt(io::IO, t::Tuple)
    length(t) == 0 && return
    for i in 1:length(t)
        i != 1 && print(io, "{")
        stringify(io, t[i])
        i != length(t) && print(io, "}")
    end
end
