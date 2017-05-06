function print_options(io::IO, options::String)
    print(io, "[", options, "]\n")
end

function print_options(io::IO, options::Vector{String})
    print(io, "[", join(options, ", "), "]\n")
end

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

function create_options(args)
    options = String[]
    io = IOBuffer()
    for arg in args
        stringify(io, arg)
        push!(options, String(take!(io)))
    end
    return options
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
function stringify(io::IO, p::Pair)
    print(io, first(p), " = {")
    stringify(io, last(p))
    print(io, "}")
end

stringify(io::IO, s) = print(io::IO, s)

function stringify(io::IO, opts::Vector)
    for opt in opts
        stringify(io, opt)
        println(io, ",")
    end
end
