const TikzElementOrStr = Union{TikzElement, String}

"""
    TikzPicture([options], contents...)

Corresponds to a `tikzpicture` block in PGFPlots.

Elements can also be added with `push!` after construction.
"""
struct TikzPicture <: OptionType
    options::Options
    elements::Vector{TikzElementOrStr} # Plots, nodes etc
    function TikzPicture(options::Options, elements::TikzElementOrStr...)
        new(options, collect(TikzElementOrStr, elements))
    end
end

TikzPicture(elements::TikzElementOrStr...) = TikzPicture(Options(), elements...)

Base.push!(t::TikzPicture, args...; kwargs...) = (push!(t.elements, args...; kwargs...); t)
Base.append!(t::TikzPicture, args...; kwargs...) = (append!(t.elements, args...; kwargs...); t)

function print_tex(io::IO, tp::TikzPicture)
    @unpack options, elements = tp
    print(io, "\\begin{tikzpicture}")
    print_options(io, options)
    for element in elements
        print_tex(io, element, tp)
    end
    println(io, "\\end{tikzpicture}")
end

function save(filename::AbstractString, tp::TikzPicture; kwargs...)
    save(filename, TikzDocument(tp); kwargs...)
end
