const AxisElementOrStr = Union{AxisElement, String}

immutable Axis <: TikzElement
    plots::Vector{AxisElementOrStr}
    options::Dict{String, Any}
end

Base.push!(axis::Axis, plot::AxisElementOrStr) = push!(axis.plots, plot)

function Axis(plots::Vector, args::Vararg{PGFOption})
    Axis(convert(Vector{AxisElementOrStr}, plots), dictify(args))
end

Axis(plot, args::Vararg{PGFOption}) = Axis([plot], dictify(args))

function Axis(args::Vararg{PGFOption})
    Axis(AxisElementOrStr[], args...)
end

function print_tex(io_main::IO, axis::Axis)
    print_indent(io_main) do io
        print(io, "\\begin{axis}")
        print_options(io, axis.options)
        for plot in axis.plots
            print_tex(io, plot)
        end
        print(io, "\\end{axis}")
    end
end

function totikzpicture(axis::Axis)
    tp = TikzPicture(preamble = vcat(PGFPLOTS_DEFAULT_PREAMBLE, PGFPLOTS_CUSTOM_PREAMBLE))
    push!(tp, axis)
    return tp
end

function save(filename::String, axis::Axis; include_preamble::Bool = true)
    save(filename, totikzpicture(axis); include_preamble = include_preamble)
end

Base.mimewritable(::MIME"image/svg+xml", ::Axis) = true

function Base.show(f::IO, ::MIME"image/svg+xml", axis::Axis)
    show(f, MIME("image/svg+xml"), totikzpicture(axis))
end
