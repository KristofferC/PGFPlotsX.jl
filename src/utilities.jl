
function print_options(io::IO, options::Dict{String, Any})
    print(io, "[")
    stringify(io, options)
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
    d = Dict{String, Any}()
    for arg in args
        accum_opt!(d, arg)
    end
    return d
end

accum_opt!(d::Dict, opt::String) = d[opt] = nothing
accum_opt!(d::Dict, opt::Pair) = d[first(opt)] = valuify(last(opt))

valuify(x) = x
valuify(opts::Vector) = dictify(opts)


function stringify(io::IO, d::Dict)
    for (k, v) in d
        print(io, k)
        if v != nothing
            print(io, " = {")
            stringify(io, v)
            print(io, "}")
        end
        print(io, ", ")
    end
end

stringify(io::IO, s) = print(io::IO, s)
