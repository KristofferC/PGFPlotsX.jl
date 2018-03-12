"""
$(TYPEDEF)

An axis-like object that has `options` and `contents`. Each subtype `T` has the
constructor

```julia T([options], contents...) ```

and supports [`axislike_environment(T)`](@ref).

`contents` usually consists of `Plot` objects, but can also contain strings,
which are printed *as is* (use these for legends etc). Some subtypes have
special semantics, see their documentation.
"""
abstract type AxisLike <: TikzElement end

"""
    axislike_environment(::Type{<: AxisLike})

Return the corresponding LaTeX environment name.
"""
function axislike_environment end

Base.push!(axislike::AxisLike, items...) = (push!(axislike.contents, items...); axislike)
Base.append!(axislike::AxisLike, items) = (append!(axislike.contents, items); axislike)

(T::Type{<:AxisLike})(contents...) = T(Options(), contents...)

function print_tex(io::IO, axislike::T) where {T <: AxisLike}
    @unpack options, contents = axislike
    name = axislike_environment(T)
    print(io, "\\begin{", name, "}")
    print_options(io, options)
    print_indent(io) do io
        for elt in contents
            print_tex(io, elt, axislike)
        end
    end
    println(io, "\\end{", name, "}")
end

function save(filename::String, axislike::AxisLike; kwargs...)
    save(filename, TikzPicture(axislike); kwargs...)
end

macro define_axislike(name, latex_environment)
    @argcheck latex_environment isa String
    _name = esc(name)
    quote
        Base.@__doc__ struct $(_name) <: AxisLike
            options::Options
            contents::Vector{Any}
            function $(_name)(options::Options, contents...)
                new(options, collect(contents))
            end
        end
        ($(esc(:axislike_environment)))(::Type{$(_name)}) = $(latex_environment)
    end
end

"""
    Axis([options], elements...)

Linear axes, corresponds to `axis` in PGFPlots.
"""
@define_axislike Axis "axis"

"""
    SemiLogXAxis([options], elements...)

Log `x` and linear `y` axes, corresponds to `semilogxaxis` in PGFPlots.
"""
@define_axislike SemiLogXAxis "semilogxaxis"

"""
    SemiLogYAxis([options], elements...)

Linear `x` and log `y` axes, corresponds to `semilogyaxis` in PGFPlots.
"""
@define_axislike SemiLogYAxis "semilogyaxis"

"""
    LogLogAxis([options], elements...)

Log-log axes, corresponds to `loglogaxis` in PGFPlots.
"""
@define_axislike LogLogAxis "loglogaxis"

"""
    PolarAxis([options], elements...)

Polar axes, corresponds to `polaraxis` in PGFPlots.
"""
@define_axislike PolarAxis "polaraxis"

"""
    GroupPlot([options], contents...)

A group plot, using the `groupplots` library of PGFPlots.

The `contents` after the global options are processed as follows:

1. [`Options`](@ref) (ie from `@pgf {}`) will emit a `\\nextgroupplot` with the given options,

2. `nothing` is emitted as a `\\nextgroupplot[group/empty plot]`,

3. other values, eg `Plot` are emitted using [`print_tex`](@ref).
"""
@define_axislike GroupPlot "groupplot"

function print_tex(io::IO, groupplot::GroupPlot)
    @unpack options, contents = groupplot
    print(io, "\\begin{groupplot}")
    print_options(io, options)
    print_indent(io) do io
        for elt in contents
            if elt isa Options
                print(io, "\\nextgroupplot")
                print_options(io, elt)
            elseif elt isa Plot
                print_tex(io, elt)
            elseif elt isa Void
                print(io, raw"\nextgroupplot[group/empty plot]")
            else
                print_tex(io, elt)
            end
        end
    end
    println(io, "\\end{groupplot}")
end
