"""
$(TYPEDEF)

An axis-like object that has `options` and `contents`. Each subtype `T` has the
constructor

```julia
T([options], contents...)
```

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

Base.push!(a::AxisLike, args...; kwargs...) = (push!(a.contents, args...; kwargs...); a)
Base.append!(a::AxisLike, args...; kwargs...) = (append!(a.contents, args...; kwargs...); a)

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

function save(filename::AbstractString, axislike::AxisLike; kwargs...)
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
    SmithChart([options], elements...)

Smith Chart axes, corresponds to `smithchart` in PGFPlots.
"""
@define_axislike SmithChart "smithchart"

"""
    TernaryAxis([options], elements...)

Ternary axes, corresponds to `ternaryaxis` in PGFPlots.
"""
@define_axislike TernaryAxis "ternaryaxis"

"""
    GroupPlot([options], contents...)

A group plot, using the `groupplots` library of PGFPlots.

The `contents` after the global options are processed as follows:

1. [`Options`](@ref) (ie from `@pgf {}`) will emit a `\\nextgroupplot` with the given options,

2. `nothing` is emitted as a `\\nextgroupplot[group/empty plot]`,

3. [`Axis`](@ref), [`SemiLogXAxis`](@ref), [`SemiLogYAxis`](@ref) and [`LogLogAxis`](@ref)
   are emitted as `\\nextgroupplot[options...]`, followed by the contents,

4. other values, eg `Plot` are emitted using [`print_tex`](@ref).
"""
@define_axislike GroupPlot "groupplot"

function print_tex(io::IO, groupplot::GroupPlot)
    @unpack options, contents = groupplot
    isempty(contents) && return
    print(io, raw"\begin{groupplot}")
    print_options(io, options)
    print_indent(io) do io
        for elt in contents
            if elt isa Options
                print(io, raw"\nextgroupplot")
                print_options(io, elt)
            elseif typeof(elt) in (Axis, SemiLogXAxis, SemiLogYAxis, LogLogAxis)
                print(io, raw"\nextgroupplot")
                # add extra option for SemiLogXAxis, SemiLogYAxis, LogLogAxis
                opts = elt.options
                if elt isa SemiLogXAxis
                    opts = merge(Options("xmode=log,ymode=normal" => nothing), opts)
                elseif elt isa SemiLogYAxis
                    opts = merge(Options("xmode=normal,ymode=log" => nothing), opts)
                elseif elt isa LogLogAxis
                    opts = merge(Options("xmode=log,ymode=log" => nothing), opts)
                end
                print_options(io, opts)
                for c in elt.contents
                    print_tex(io, c)
                end
            elseif elt isa Plot
                print_tex(io, elt)
            elseif elt isa Nothing
                println(io, raw"\nextgroupplot[group/empty plot,xmin=0,xmax=1,ymin=0,ymax=1]")
            else
                print_tex(io, elt)
            end
        end
    end
    println(io, raw"\end{groupplot}")
end
