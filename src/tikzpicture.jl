const TikzElementOrStr = Union{TikzElement, String}

struct TikzPicture <: OptionType
    elements::Vector{TikzElementOrStr} # Plots, nodes etc
    options::OrderedDict{Any, Any}
end

function TikzPicture(options::Vararg{PGFOption})
    TikzPicture(TikzElementOrStr[], dictify(options))
end

TikzPicture(element::TikzElementOrStr, args...) = TikzPicture([element], args...)

function TikzPicture(elements::Vector, options::Vararg{PGFOption})
    TikzPicture(convert(Vector{TikzElementOrStr}, elements), dictify(options))
end

Base.push!(tp::TikzPicture, element::TikzElementOrStr) = push!(tp.elements, element)

function print_tex(io::IO, tp::TikzPicture)
    print(io, "\\begin{tikzpicture}")
    print_options(io, tp.options)
    for element in tp.elements
        print_tex(io, element, tp)
    end
    println(io, "\\end{tikzpicture}")
end

function save(filename::String, tp::TikzPicture; kwargs...)
    save(filename, TikzDocument(tp); kwargs...)
end
