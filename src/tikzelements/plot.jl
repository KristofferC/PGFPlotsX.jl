abstract PlotElement

immutable PGFFunction <: PlotElement
    str::String
end

immutable PGFTable <: PlotElement
    filename::String
end

immutable Plot
    element::PlotElement
    options::Dict{String, Any}
    incremental::Bool # use \addplot+
end


function Plot(element, args::Vararg{PGFOption}; incremental = false)
    Plot(element, dictify(args), incremental)
end

function print_tex(io_main::IO, p::Plot)
    print_indent(io_main) do io
        print(io, "\\addplot")
        if p.incremental
            print(io, "+")
        end
        print_options(io, p.options)
        print_tex(io, p.element)
    end
end

## PlotElements

function print_tex(io_main::IO, f::PGFFunction)
    print_indent(io_main) do io
        print(io, "{", f.str, "};")
    end
end

function print_tex(io_main::IO, t::PGFTable)
    print_indent(io_main) do io
        print(io, "table {", t.filename, "};")
    end
end
