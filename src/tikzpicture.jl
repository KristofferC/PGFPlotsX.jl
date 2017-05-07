latexengine() = "lualatex"

const TikzElementOrStr = Union{TikzElement, String}

type TikzPicture  <: OptionType
    elements::Vector{TikzElementOrStr} # Plots, nodes etc
    options::Dict{String, Any}
    preamble::Vector{String}
end

function TikzPicture(options::Vararg{PGFOption}; preamble = String[])
    TikzPicture(TikzElementOrStr[], dictify(options), preamble)
end

function TikzPicture(elements::Vector, options::Vararg{PGFOption}; preamble = String[])
    TikzPicture(elements, dictify(options), preamble)
end

Base.push!(tp::TikzPicture, element::TikzElementOrStr) = push!(tp.elements, element)

##########
# Output #
##########

function save(filename::String, tp::TikzPicture; include_preamble::Bool = true)
    file_ending = split(basename(filename), '.')[end]
    filename_stripped = filename[1:end-4] # This is ugly, whatccha gonna do about it?
    if !(file_ending in ("tex", "svg", "pdf"))
        throw(ArgumentError("allowed file endings are .tex, .svg, .pdf"))
    end
    if file_ending == "tex"
        savetex(filename_stripped, tp; include_preamble = include_preamble)
    elseif file_ending == "svg"
        savesvg(filename_stripped, tp)
    elseif file_ending == "pdf"
        savepdf(filename_stripped, tp)
    end
    return
end

# TeX
function savetex(filename::String, tp::TikzPicture; include_preamble::Bool = true)
    open("$(filename).tex", "w") do tex
        savetex(tex, tp; include_preamble = include_preamble)
    end
end

function savetex(io::IO, tp::TikzPicture; include_preamble::Bool = true)
    if include_preamble
        println(io, "\\RequirePackage{luatex85}")
        println(io, "\\documentclass{standalone}")
        println(io, "\\usepackage{tikz}")
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

# Copyright TikzPictures.jl (see LICENSE.md)

function latexerrormsg(s)
    beginError = false
    for l in split(s, '\n')
        if beginError
            if !isempty(l) && l[1] == '?'
                return
            else
                println(l)
            end
        else
            if !isempty(l) && l[1] == '!'
                println(l)
                beginError = true
            end
        end
    end
end

function savepdf(filename::String, tp::TikzPicture)
    folder, file = dirname(filename), basename(filename)
    if isempty(folder)
        folder = "."
    end
    # TODO: Check no tikz elements?
    try
        tmp = joinpath(folder, basename(tempname()))
        savetex(tmp, tp)
        latexcmd = `$(latexengine()) --output-directory=$folder $tmp`
        latex_success = success(latexcmd)
        log = readstring("$tmp.log")

        rm("$(tmp).tex")
        rm("$(tmp).aux")
        rm("$(tmp).log")

        if !latex_success
            latexerrormsg(log)
            error("LaTeX error")
        end

        mv(tmp * ".pdf", filename * ".pdf"; remove_destination = true)

    catch
        println("Error saving as PDF.")
        rethrow()
    end
end


function savesvg(filename::String, tp::TikzPicture)
    try
        tmp = tempname()
        keep_pdf = isfile(filename * ".pdf")

        savepdf(tmp, tp)

        success(`pdf2svg $tmp.pdf $filename.svg`) || error("pdf2svg failure")
        rm("$tmp.pdf")
    catch
        println("Error saving as SVG")
        rethrow()
    end
end

Base.mimewritable(::MIME"image/svg+xml", ::TikzPicture) = true


global _tikzid = round(UInt64, time() * 1e6)

function Base.show(f::IO, ::MIME"image/svg+xml", tp::TikzPicture)
    global _tikzid
    filename = tempname()
    savesvg(filename, tp)
    s = readstring("$filename.svg")
    s = replace(s, "glyph", "glyph-$(_tikzid)-")
    s = replace(s, "\"clip", "\"clip-$(_tikzid)-")
    s = replace(s, "#clip", "#clip-$(_tikzid)-")
    s = replace(s, "\"image", "\"image-$(_tikzid)-")
    s = replace(s, "#image", "#image-$(_tikzid)-")
    s = replace(s, "linearGradient id=\"linear", "linearGradient id=\"linear-$(_tikzid)-")
    s = replace(s, "#linear", "#linear-$(_tikzid)-")
    s = replace(s, "image id=\"", "image style=\"image-rendering: pixelated;\" id=\"")
    _tikzid += 1
    println(f, s)
    rm("$filename.svg")
end
