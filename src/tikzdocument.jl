const TikzPictureOrStr = Union{TikzPicture, String}

type TikzDocument <: OptionType
    elements::Vector{TikzPictureOrStr} # Plots, nodes etc
    preamble::Vector{String}

    function TikzDocument(elements::Vector{TikzPictureOrStr}, preamble::Union{String, Vector{String}})
        new(elements, vcat(DEFAULT_PREAMBLE, CUSTOM_PREAMBLE, preamble))
    end
end

function TikzDocument(; preamble = String[])
    TikzDocument(TikzPictureOrStr[], preamble)
end

TikzDocument(element::TikzPictureOrStr, args...) = TikzDocument([element], args...)

function TikzDocument(elements::Vector; preamble = String[])
    TikzDocument(convert(Vector{TikzPictureOrStr}, elements), preamble)
end



##########
# Output #
##########

function save(filename::String, td::TikzDocument; include_preamble::Bool = true)
    file_ending = split(basename(filename), '.')[end]
    filename_stripped = filename[1:end-4] # This is ugly, whatccha gonna do about it?
    if !(file_ending in ("tex", "svg", "pdf"))
        throw(ArgumentError("allowed file endings are .tex, .svg, .pdf"))
    end
    if file_ending == "tex"
        savetex(filename_stripped, td; include_preamble = include_preamble)
    elseif file_ending == "svg"
        savesvg(filename_stripped, td)
    elseif file_ending == "pdf"
        savepdf(filename_stripped, td)
    end
    return
end

# TeX
function savetex(filename::String, td::TikzDocument; include_preamble::Bool = true)
    open("$(filename).tex", "w") do tex
        savetex(tex, td; include_preamble = include_preamble)
    end
end

function savetex(io::IO, td::TikzDocument; include_preamble::Bool = true)
    if include_preamble
        println(io, "\\RequirePackage{luatex85}")
        println(io, "\\documentclass{standalone}")
        println(io, "\\usepackage{tikz}")
        for preamble in td.preamble
            println(io, preamble)
        end
        println(io, "\\begin{document}")
    end
    for element in td.elements
        print_tex(io, element)
    end
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

function savepdf(filename::String, td::TikzDocument)
    folder, file = dirname(filename), basename(filename)
    if isempty(folder)
        folder = "."
    end
    # TODO: Check no tikz elements?
    try
        tmp = joinpath(folder, basename(tempname()))
        savetex(tmp, td)
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


function savesvg(filename::String, td::TikzDocument)
    try
        tmp = tempname()
        keep_pdf = isfile(filename * ".pdf")

        savepdf(tmp, td)

        success(`pdf2svg $tmp.pdf $filename.svg`) || error("pdf2svg failure")
        rm("$tmp.pdf")
    catch
        println("Error saving as SVG")
        rethrow()
    end
end

Base.mimewritable(::MIME"image/svg+xml", ::TikzDocument) = true


global _tikzid = round(UInt64, time() * 1e6)

function Base.show(f::IO, ::MIME"image/svg+xml", td::TikzDocument)
    global _tikzid
    filename = tempname()
    savesvg(filename, td)
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
