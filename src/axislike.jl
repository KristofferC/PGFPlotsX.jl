abstract type AxisLike <: TikzElement end

Base.push!(axislike::AxisLike, plot) = (push!(axislike.plots, plot); axislike)
Base.append!(axislike::AxisLike, plot) = (append!(axislike.plots, plot); axislike)


function (T::Type{<:AxisLike})(plots::AbstractVector, args::Vararg{PGFOption})
    T(plots, dictify(args))
end

(T::Type{<:AxisLike})(plot, args::Vararg{PGFOption}) = T([plot], dictify(args))

function (T::Type{<:AxisLike})(args::Vararg{PGFOption})
    T([], args...)
end

function print_tex(io_main::IO, axislike::AxisLike)
    print_indent(io_main) do io
        print(io, "\\begin{", _tex_name(axislike), "}")
        print_options(io, axislike.options)
        for (i, plot) in enumerate(axislike.plots)
            between = _in_between(axislike, i)
            if !isempty(between)
                print_tex(io, between)
            end
            print_tex(io, plot, axislike)
        end
        print(io, "\\end{", _tex_name(axislike), "}")
    end
end

function save(filename::String, axislike::AxisLike; kwargs...)
    save(filename, TikzPicture(axislike); kwargs...)
end

_in_between(::Any, ::Any) = ""

########
# Axis #
########

struct Axis <: AxisLike
    plots::Vector{Any}
    options::OrderedDict{Any, Any}

    # get rid of default constructor or ambiguities
    Axis(v::Vector, o::OrderedDict{Any, Any}) = new(v, o)
end

_tex_name(::Axis) = "axis"

#############
# GroupPlot #
#############

struct GroupPlot <: AxisLike
    plots::Vector{Any}
    axisoptions::Vector{OrderedDict{Any, Any}}
    options::OrderedDict{Any, Any}
    # nextgroupplot::Vector{OrderedDict{Any, Any}} # options for \nextgroupplot
    # get rid of default constructor or ambiguities
    GroupPlot(v::Vector, o::OrderedDict{Any, Any}) = new(convert(Vector{Any}, v), [OrderedDict() for i in 1:length(v)], o)
    GroupPlot(o::OrderedDict{Any, Any}) = new(Any[], OrderedDict{Any, Any}[], o)
end

function print_tex(io::IO, v::Vector, gp::GroupPlot)
    for p in v
        print_tex(io, p, gp)
    end
end

Base.push!(gp::GroupPlot, plot) = (push!(gp.plots, plot); push!(gp.axisoptions, OrderedDict()); gp)
Base.push!(gp::GroupPlot, plot, args...) = (push!(gp.plots, plot); push!(gp.axisoptions, dictify(args)); gp)

_tex_name(::GroupPlot) = "groupplot"
#TODO Should these take IO instead?
function _in_between(gp::GroupPlot, i::Int)
     io = IOBuffer()
     print(io, "\\nextgroupplot")
     print_options(io, gp.axisoptions[i])
     return String(take!(io))
end

#############
# PolarAxis #
#############

struct PolarAxis <: AxisLike
    plots::Vector{Any}
    options::OrderedDict{Any, Any}
    # nextgroupplot::Vector{OrderedDict{Any, Any}} # options for \nextgroupplot
    # get rid of default constructor or ambiguities
    PolarAxis(v::Vector, o::OrderedDict{Any, Any}) = new(convert(Vector{Any}, v), o)
end

_tex_name(::PolarAxis) = "polaraxis"
