type TikzPicture
    elements::Vector{TikzElement} # Plots, nodes etc
    options::Vector{String}
    preamble::Vector{String}
end

function TikzPicture(elements = TikzElement[]; options=String[], preamble=String[])
    TikzPicture(elements, options, preamble)
end

Base.push!(tp::TikzPicture, element::TikzElement) = push!(tp.elements, element)

function savetex(filename::String, tp::TikzPicture; include_preamble::Bool = true)
    open("$(filename).tex", "w") do tex
        savetex(tex, tp; include_preamble = include_preamble)
    end
end

function savetex(io::IO, tp::TikzPicture; include_preamble::Bool = true)
    if include_preamble
        println(io, "\\documentclass[tikz]{standalone}")
        for preamble in tp.preamble
            println(io, preamble)
        end
        println(io, "\\begin{document}")
    end
    print(io, "\\begin{tikzpicture}")
    print_options(io, tp.options)
    for element in tp.elements
        print_tex(io, element)
    end
    println(io, "\\end{tikzpicture}")
    if include_preamble
        println(io, "\\end{document}")
    end
end
