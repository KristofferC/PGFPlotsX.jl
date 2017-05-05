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
