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
    fs::Vector{String}
end

PGFFunction(str::String) = PGFFunction([str])

function print_tex(io_main::IO, f::PGFFunction)
    multiple_f = length(f.fs) != 1
    print_indent(io_main) do io
        multiple_f && print(io, "(\n")
        for (i, fstr) in enumerate(f.fs)
            print(io, "{", fstr, "}")
            if i != length(f.fs)
                print(io, ",\n")
            end
        end
        multiple_f && print(io, ")")
    end
end

immutable PGFCoordinates <: PlotElement
    data::Matrix
    metadata::Union{Void, Vector}
end

function PGFCoordinates(vec::Vector{<:Tuple}; metadata = nothing)
    if length(vec) == 0
        mat = Matrix[]
    else
        l = length(vec[1])
        mat = Matrix(l, length(vec))
        for (i, v) in enumerate(vec)
            @assert length(v) == l
            for (j, c) in enumerate(v)
                mat[j, i] = c
            end
        end
    end
    PGFCoordinates(mat, metadata)
end


function PGFCoordinates(x::Vector, y::Vector; metadata = nothing)
    mat = transpose(hcat(x, y))
    PGFCoordinates(mat, metadata)
end


function print_tex(io_main::IO, t::PGFCoordinates)
    print_indent(io_main) do io
        print(io, "coordinates ")
        print(io, "{\n")
        m = t.data
        for j in 1:size(m, 2)
            print(io, "(")
            for i in 1:size(m, 1)
                i != 1 && print(io, ", ")
                print(io, m[i, j])
            end
            print(io, ")")
            if t.metadata != nothing
                print(io, " [", t.metadata[j], "]")
            end
            if j != size(m, 2)
                print(io, "\n")
            end
        end

        print(io, "\n}")
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

immutable PGFGraphics <: PlotElement
    filename::String
    options::Dict{String, Any}
end

function PGFGraphics(filename::String, args::Vararg{PGFOption})
    PGFGraphics(filename, dictify(args))
end

function print_tex(io_main::IO, t::PGFGraphics)
    print_indent(io_main) do io
        print(io, "graphics ")
        print_options(io, t.options)
        print(io, "{", t.filename, "}")
    end
end
