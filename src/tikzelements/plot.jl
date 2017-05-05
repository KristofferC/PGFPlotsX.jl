abstract PlotElement

immutable PGFFunction <: PlotElement
    str::String
end

immutable Plot
    data::PlotElement
    options::Vector{String}
    incremental::Bool # use \addplot+
end

function Plot(data, options = String[]; incremental = false)
    Plot(data, options, incremental)
end

function print_tex(io_main::IO, p::Plot)
    print_indent(io_main) do io
        print(io, "\\addplot")
        if p.incremental
            print(io, "+")
        end
        print_options(io, p.options)
        print_tex(io, p.data)
    end
end

## PlotElements

function print_tex(io_main::IO, f::PGFFunction)
    print_indent(io_main) do io
        print(io, "{", f.str, "};")
    end
end
