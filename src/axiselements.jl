abstract type PlotElement <: OptionType end

const PlotElementOrStr = Union{PlotElement, String}

immutable Plot <: AxisElement
    elements::Vector{PlotElementOrStr}
    options::Dict{String, Any}
    label
    incremental::Bool # use \addplot+
    _3d::Bool
end

Base.push!(plot::Plot, element::PlotElementOrStr) = push!(plot.elements, element)

function Plot(element::PlotElementOrStr, args...; kwargs...)
    Plot([element], args...; kwargs...)
end

function Plot(elements::Vector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(convert(Vector{PlotElementOrStr}, elements), dictify(args), label, incremental, false)
end


function Plot3(element::PlotElementOrStr, args...; kwargs...)
    Plot3([element], args...; kwargs...)
end

function Plot3(element::Vector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(element, dictify(args), label, incremental, true)
end


Plot(element, args...; kwargs...) = Plot([element], args...; kwargs...)
Plot3(element, args...; kwargs...) = Plot3([element], args...; kwargs...)

function save(filename::String, plot::Plot; include_preamble::Bool = true)
    save(filename, toaxis(plot); include_preamble = include_preamble)
end


Base.mimewritable(::MIME"image/svg+xml", ::Plot) = true

function Base.show(f::IO, ::MIME"image/svg+xml", plot::Plot)
    show(f, MIME("image/svg+xml"), toaxis(plot))
end


function print_tex(io_main::IO, p::Plot)
    print_indent(io_main) do io
        print(io, "\\addplot")
        if p._3d
            print(io, "3")
        end
        if p.incremental
            print(io, "+")
        end
        print_options(io, p.options)
        for element in p.elements
            print_tex(io, element)
        end
        print(io, ";")
        if p.label != nothing
            println(io, "\\addlegendentry{$(p.label)}")
        end
    end
end


immutable PGFFunction <: PlotElement
    str::String
end

function print_tex(io_main::IO, f::PGFFunction)
    print_indent(io_main) do io
        print(io, "{", f.str, "}")
    end
end

immutable PGFCoordinates <: PlotElement
    data
    PGFCoordinates(mat::Matrix) = new(mat)
    PGFCoordinates(mat::Vector{<:Tuple}) = new(mat)
end

function PGFCoordinates(x::Vector, y::Vector)
    mat = transpose(hcat(x, y))
    PGFCoordinates(mat)
end


function print_tex(io_main::IO, t::PGFCoordinates)
    print_indent(io_main) do io
        print(io, "coordinates ")
        print(io, "{\n")
        print_coordinates(io, t.data)
        print(io, "\n}")
    end
end

function print_coordinates(io, m::Matrix)
    for j in 1:size(m, 2)
        print(io, "(")
        for i in 1:size(m, 1)
            i != 1 && print(io, ", ")
            print(io, m[i, j])
        end
        print(io, ")")
        if j != size(m, 2)
            print(io, "\n")
        end
    end
end

function print_coordinates(io, v::Vector{<:Tuple})
    for j in 1:length(v)
        print(io, "(")
        first = true
        for c in v[j]
            !first && print(io, ", ")
            print(io, c)
            first = false
        end
        print(io, ")")
        if j != length(v)
            print(io, "\n")
        end
    end
end

immutable PGFTable <: PlotElement
    filename::String
    options::Dict{String, Any}
end

function PGFTable(filename::String, args::Vararg{PGFOption})
    PGFTable(filename, dictify(args))
end

function print_tex(io_main::IO, t::PGFTable)
    print_indent(io_main) do io
        print(io, "table ")
        print_options(io, t.options)
        print(io, "{", t.filename, "}")
    end
end
