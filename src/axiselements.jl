########
# Plot #
########

immutable Plot <: AxisElement
    elements::AbstractVector{Any}
    options::OrderedDict{Any, Any}
    label
    incremental::Bool
    _3d::Bool
end

Base.push!(plot, element) = push!(plot.elements, element)


function Plot(elements::AbstractVector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(elements, dictify(args), label, incremental, false)
end

function Plot3(element::Vector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(element, dictify(args), label, incremental, true)
end

Plot(element, args...; kwargs...) = Plot([element], args...; kwargs...)
Plot3(element, args...; kwargs...) = Plot3([element], args...; kwargs...)

function save(filename::String, plot::Plot; include_preamble::Bool = true)
    save(filename, Axis(plot); include_preamble = include_preamble)
end

Base.mimewritable(::MIME"image/svg+xml", ::Plot) = true

Base.show(f::IO, ::MIME"image/svg+xml", plot::Plot) = show(f, MIME("image/svg+xml"), [plot])

function Base.show(f::IO, ::MIME"image/svg+xml", plot::AbstractVector{Plot})
    show(f, MIME("image/svg+xml"), Axis(plot))
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
            print_tex(io, element, p)
        end
        print(io, ";")
        if p.label != nothing
            println(io, "\\addlegendentry{$(p.label)}")
        end
    end
end


##############
# Expression #
##############

immutable Expression <: OptionType
    fs::Vector{String}
end

Expression(str::String) = Expression([str])

function print_tex(io_main::IO, f::Expression)
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

immutable Coordinates <: OptionType
    data::Matrix{Any}
    metadata::Union{Void, Vector}
end

function Coordinates(vec::AbstractVector; metadata = nothing)
    if length(vec) == 0
        mat = Matrix[]
    else
        # TODO, should not be @asserts but real checks
        @assert typeof(vec[1]) <: Tuple
        l = length(vec[1])
        mat = Matrix(l, length(vec))
        for (i, v) in enumerate(vec)
            @assert typeof(v) <: Tuple
            @assert length(v) == l
            for (j, c) in enumerate(v)
                mat[j, i] = c
            end
        end
    end
    Coordinates(mat, metadata)
end


Coordinates(x::AbstractVector, y::AbstractVector; metadata = nothing) = Coordinates(transpose(hcat(x, y)), metadata)
Coordinates(x::AbstractVector, y::AbstractVector, z::AbstractVector; metadata = nothing) = Coordinates(transpose(hcat(x, y, z)), metadata)

Coordinates(x::AbstractVector, f::Function; metadata = nothing) = Coordinates(x, f.(x); metadata = metadata)
Coordinates(x::AbstractVector, y::AbstractVector, f::Function; metadata = nothing) = Coordinates(x, y, f.(x, y); metadata = metadata)


function print_tex(io_main::IO, t::Coordinates)
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


immutable Table <: OptionType
    data
    options::OrderedDict{Any, Any}

    # Some ambiguity fixing
    Table(data, options::OrderedDict{Any, Any}) = new(data, options)

    Table(data::Union{DataStructures.OrderedDict, Pair, String},
          options::DataStructures.OrderedDict{Any,Any}) = new(data, options)

    Table(data::String, options::DataStructures.OrderedDict{Any,Any}) = new(data, options)
end

function Table(data, args::Vararg{PGFOption})
    Table(data, dictify(args))
end


function Table(data::String, args::Vararg{PGFOption})
    Table(data, dictify(args))
end

function Table(args::Vararg{PGFOption}; kwargs...)
    Table(kwargs, dictify(args))
end

function print_tex(io_main::IO, t::Table)
    print_indent(io_main) do io
        print(io, "table ")
        print_options(io, t.options)
        print(io, "{\n")
        print_tex(io, t.data, t)
        print(io, "\n}")
    end
end

print_tex(io::IO, str::String, ::Table) = print(io, str)
function print_tex(io::IO, v::AbstractVector, ::Table)
    length(v) == 0 && return
    if v[1] isa Tuple # Assume the kw constructor was called
        # Do some basic checking
        # Print header
        vs = []
        first = true
        l = -1
        for s in v
            if !(length(s) == 2) || !(s[1] isa Symbol) || !(s[2] isa AbstractVector)
                error("Expected a call like Table(; a = [1,2,...], b = [2,3,...])")
            end

            if first
                l = length(s[2])
            end

            if !(l == length(s[2]))
                error("length of data in columns not the same")
            end

            print(io, s[1], "    ")
            push!(vs, s[2])
        end

        println(io)

        v_mat = hcat(vs...)'

        for j in 1:size(v_mat, 2)
            for i in 1:size(v_mat, 1)
                print(io, v_mat[i, j], "    ")
            end
            if j != size(v_mat, 2)
                println(io)
            end
        end
    else
        print(io, join(v, "\n"))
    end
end

immutable Graphics <: OptionType
    filename::String
    options::OrderedDict{Any, Any}
end

function Graphics(filename::String, args::Vararg{PGFOption})
    Graphics(filename, dictify(args))
end

function print_tex(io_main::IO, t::Graphics)
    print_indent(io_main) do io
        print(io, "graphics ")
        print_options(io, t.options)
        print(io, "{", t.filename, "}")
    end
end
