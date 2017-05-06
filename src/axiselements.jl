immutable RawString <: AxisElement
    str::String
end

function print_tex(io_main::IO, rs::RawString)
    print_indent(io_main) do io
        print(io, rs.str)
    end
end

abstract PlotElement

immutable Plot <: AxisElement
    element::PlotElement
    options::Vector{String}
    incremental::Bool # use \addplot+
end


function Plot(element, args::Vararg{Pair}; incremental = false)
    Plot(element, create_options(args), incremental)
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


immutable PGFFunction <: PlotElement
    str::String
end

function print_tex(io_main::IO, f::PGFFunction)
    print_indent(io_main) do io
        print(io, "{", f.str, "};")
    end
end

immutable PGFTable <: PlotElement
    filename::String
end

function print_tex(io_main::IO, t::PGFTable)
    print_indent(io_main) do io
        print(io, "table {", t.filename, "};")
    end
end
