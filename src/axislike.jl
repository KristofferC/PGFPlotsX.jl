const AxisLikeElementOrStr = Union{AxisElement, String}

abstract type AxisLike <: TikzElement end

Base.push!(axislike::AxisLike, plot::AxisLikeElementOrStr) = push!(axislike.plots, plot)

function (T::Type{<:AxisLike})(plots::AbstractVector, args::Vararg{PGFOption})
    T(convert(Vector{AxisLikeElementOrStr}, plots), dictify(args))
end

(T::Type{<:AxisLike})(plot::AxisLikeElementOrStr, args::Vararg{PGFOption}) = T([plot], dictify(args))

function (T::Type{<:AxisLike})(args::Vararg{PGFOption})
    T(AxisLikeElementOrStr[], args...)
end

function print_tex(io_main::IO, axislike::AxisLike)
    print_indent(io_main) do io
        print(io, "\\begin{", _tex_name(axislike), "}")
        print_options(io, axislike.options)
        for plot in axislike.plots
            between = _in_between(axislike)
            if !isempty(between)
                print_tex(io, between)
            end
            print_tex(io, plot)
        end
        print(io, "\\end{", _tex_name(axislike), "}")
    end
end

function save(filename::String, axislike::AxisLike; include_preamble::Bool = true)
    save(filename, TikzPicture(axislike); include_preamble = include_preamble)
end

Base.mimewritable(::MIME"image/svg+xml", ::AxisLike) = true

function Base.show(f::IO, ::MIME"image/svg+xml", axes::AbstractVector{T} where T <: AxisLike)
    show(f, MIME("image/svg+xml"), TikzPicture(convert(Vector{AxisLike}, axes)))
end

Base.show(f::IO, ::MIME"image/svg+xml", axislike::AxisLike) = show(f, MIME("image/svg+xml"), [axislike])


########
# Axis #
########

immutable Axis <: AxisLike
    plots::Vector{AxisLikeElementOrStr}
    options::OrderedDict{Any, Any}

    # get rid of default constructor or ambiguities
    Axis(v::Vector{AxisLikeElementOrStr}, o::OrderedDict{Any, Any}) = new(v, o)
end

_tex_name(::Axis) = "axis"
_in_between(::Axis) = ""

#############
# GroupPlot #
#############

immutable GroupPlot <: AxisLike
    plots::Vector{AxisLikeElementOrStr}
    options::OrderedDict{Any, Any}
    # nextgroupplot::Vector{OrderedDict{Any, Any}} # options for \nextgroupplot
    # get rid of default constructor or ambiguities
    GroupPlot(v::Vector{AxisLikeElementOrStr}, o::OrderedDict{Any, Any}) = new(v, o)
end

_tex_name(::GroupPlot) = "groupplot"
_in_between(::GroupPlot) = "\\nextgroupplot"

#############
# PolarAxis #
#############

immutable PolarAxis <: AxisLike
    plots::Vector{AxisLikeElementOrStr}
    options::OrderedDict{Any, Any}
    # nextgroupplot::Vector{OrderedDict{Any, Any}} # options for \nextgroupplot
    # get rid of default constructor or ambiguities
    PolarAxis(v::Vector{AxisLikeElementOrStr}, o::OrderedDict{Any, Any}) = new(v, o)
end

_tex_name(::PolarAxis) = "polaraxis"
_in_between(::PolarAxis) = ""
