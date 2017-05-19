########
# Plot #
########

struct Plot <: AxisElement
    elements::AbstractVector{Any}
    options::OrderedDict{Any, Any}
    label
    incremental::Bool
    _3d::Bool
end

Base.push!(plot::Plot, element) = (push!(plot.elements, element); plot)
Base.append!(plot::Plot, element) = (append!(plot.elements, element); plot)

function Plot(elements::AbstractVector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(elements, dictify(args), label, incremental, false)
end

function Plot3(element::Vector, args::Vararg{PGFOption}; incremental = true, label = nothing)
    Plot(element, dictify(args), label, incremental, true)
end

Plot(element, args...; kwargs...) = Plot([element], args...; kwargs...)
Plot3(element, args...; kwargs...) = Plot3([element], args...; kwargs...)

function save(filename::String, plot::Plot; kwargs...)
    save(filename, Axis(plot); kwargs...)
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
            print(io, "\n\\addlegendentry{$(p.label)}")
        end
    end
end

##############
# Expression #
##############

struct Expression <: OptionType
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

struct Coordinates <: OptionType
    data::Matrix{Any}
    xerror::AbstractVector
    yerror::AbstractVector
    xerrorplus::AbstractVector
    xerrorminus::AbstractVector
    yerrorplus::AbstractVector
    yerrorminus::AbstractVector
    metadata::Union{Void, Vector}


end

function Coordinates(mat::Matrix; metadata = nothing, xerror::AbstractVector = [],
                                            yerror::AbstractVector = [],
                                            xerrorplus::AbstractVector = [],
                                            xerrorminus::AbstractVector = [],
                                            yerrorplus::AbstractVector = [],
                                            yerrorminus::AbstractVector = [])
    Coordinates(mat,
    xerror,
    yerror,
    xerrorplus,
    xerrorminus,
    yerrorplus,
    yerrorminus,
    metadata)
end

function Coordinates(vec::AbstractVector; kwargs...)
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
    Coordinates(mat; kwargs...)
end



Coordinates(x::AbstractVector, y::AbstractVector; kwargs...) = Coordinates(transpose(hcat(x, y)); kwargs...)

Coordinates(x::AbstractVector, y::AbstractVector, z::AbstractVector; metadata = nothing) = Coordinates(transpose(hcat(x, y, z)); metadata = metadata)

Coordinates(x::AbstractVector, f::Function; metadata = nothing) = Coordinates(x, f.(x); metadata = metadata)

Coordinates(x::AbstractVector, y::AbstractVector, f::Function; metadata = nothing) = Coordinates(x, y, f.(x, y); metadata = metadata)


function _print_error(io, i, xerror, yerror, xerrorplus, xerrorminus, yerrorplus, yerrorminus)

end

function print_tex(io_main::IO, t::Coordinates)

    n_coords = size(t.data, 2)
    isdef(x) = length(x) != 0

    for err in [t.xerror, t.yerror, t.xerrorplus, t.xerrorminus, t.yerrorplus, t.yerrorminus]
        if isdef(err) && length(err) != n_coords
            error("length of vector with error not same as number of points")
        end
    end

    if isdef(t.xerror) && (isdef(t.xerrorplus) || isdef(t.xerrorminus))
        error("cannot specify both symmetric `xerror` and nonsymmetric `xerrorplus` / `xerrormins`")
    end

    if isdef(t.yerror) && (isdef(t.yerrorplus) || isdef(t.yerrorminus))
        error("cannot specify both symmetric `yerror` and nonsymmetric `yerrorplus` / `yerrormins`")
    end

    get_err(i, a) = !isdef(a) ? 0.0 : a[i]

    print_err(io, i, x, y, char) = print(io, char, "(", get_err(i, x), ", ", get_err(i, y), ")")
    print_sym(io, i, x, y) = print_err(io, i, x, y, "+-")
    print_sym_l(io, i, x, y) = print_err(io, i, x, y, "-=")
    print_sym_r(io, i, x, y) = print_err(io, i, x, y, "+=")

    if isdef(t.xerror) || isdef(t.yerror) # Symmetric error
        print_error = (io, i, t) -> print_sym(io, i, t.xerror, t.yerror)
    elseif !isdef(t.xerrorplus) && !isdef(t.yerrorplus) && (isdef(t.xerrorminus) || isdef(t.yerrorminus)) # Only minus error
        print_error = (io, i, t) -> print_sym_l(io, i, t.xerrorminus, t.yerrorminus)
    elseif !isdef(t.xerrorminus) && !isdef(t.yerrorminus) && (isdef(t.xerrorplus) || isdef(t.yerrorplus)) # Only plus error
        print_error = (io, i, t) -> print_sym_r(io, i, t.xerrorplus, t.yerrorplus)
    elseif (isdef(t.xerrorplus) || isdef(t.yerrorplus)) && (isdef(t.xerrorminus) || isdef(t.yerrorminus)) # Both error
        print_error = (io, i, t) -> (print_sym_l(io, i, t.xerrorminus, t.yerrorminus); print(io, " "); print_sym_r(io, i, t.xerrorplus, t.yerrorplus))
    else
        print_error = (io, i, t) -> return
    end

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

            print_error(io, j, t)


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


struct Table <: OptionType
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
        print(io, "{")
        print_tex(io, t.data, t)
        print(io, "}")
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
            println(io)
        end
    else
        println(io, join(v, "\n"))
    end
end

struct Graphics <: OptionType
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
