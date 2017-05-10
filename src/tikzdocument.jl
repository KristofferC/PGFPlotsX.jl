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

_OLD_LUALATEX = false

function savetex(io::IO, td::TikzDocument; include_preamble::Bool = true)
    global _OLD_LUALATEX
    if isempty(td.elements)
        warn("Tikz document is empty")
    end
    if include_preamble
        if !_OLD_LUALATEX
            println(io, "\\RequirePackage{luatex85}")
        end
        println(io, "\\documentclass{standalone}")
        _print_preamble(io)
        println(io, "\\begin{document}")
    end
    for element in td.elements
        print_tex(io, element)
    end
    if include_preamble
        println(io, "\\end{document}")
    end
end


_HAS_WARNED_SHELL_ESCAPE = false

function savepdf(filename::String, td::TikzDocument)
    global _HAS_WARNED_SHELL_ESCAPE, _OLD_LUALATEX
    # Create a temporary path, cd to it, run latex command, run cd from it,
    # move the pdf from the temporary path to the directory
    run_again = false
    buildpath = ""
    mktemp() do tmppath, tmp
        buildpath = tmppath
        tmpfolder, tmpfile = dirname(tmppath), basename(tmppath)

        cd(tmpfolder) do
            savetex(tmp, td)
            close(tmp)
            latexcmd = _latex_cmd(tmpfile)
            latex_success = success(latexcmd)

            log = readstring("$tmppath.log")

            if !latex_success
                DEBUG && println("LaTeX command $latexcmd failed")
                if !_OLD_LUALATEX && contains(log, "File `luatex85.sty' not found")
                    DEBUG && println("The log indicates luatex85.sty is not found, trying again without require")
                    _OLD_LUALATEX = true
                    run_again = true
                elseif (contains(log, "Maybe you need to enable the shell-escape feature") ||
                    contains(log, "Package pgfplots Error: sorry, plot file{"))
                    if !_HAS_WARNED_SHELL_ESCAPE
                        warn("Detecting need of --shell-escape flag, enabling it for the rest of the session and running latex again")
                        _HAS_WARNED_SHELL_ESCAPE = true
                    end
                    DEBUG && println("The log indicates that shell-escape is needed")
                    shell_escape = "--shell-escape"
                    if !(shell_escape in [DEFAULT_FLAGS; CUSTOM_FLAGS])
                        DEBUG && println("Adding shell-escape and trying to save pdf again")
                        # Try again with enabling shell_escape
                        push!(DEFAULT_FLAGS, shell_escape)
                        run_again = true
                    else
                        latexerrormsg(log)
                        error(string("The latex command $latexcmd failed ",
                                     "shell-escape feature seemed to not be ",
                                     "detected even though it was passed as a flag"))
                    end
                else
                    latexerrormsg(log)
                    error("The latex command $latexcmd failed")
                end
            end
        end # cd
    end # mktemp

    if run_again
        savepdf(filename, td)
        return
    end

    folder, file = dirname(filename), basename(filename)
    mv(buildpath * ".pdf", joinpath(folder, file * ".pdf"); remove_destination = true)
end


function savesvg(filename::String, td::TikzDocument)
    tmp = tempname()
    keep_pdf = isfile(filename * ".pdf")
    savepdf(tmp, td)
    # TODO Better error
    svg_cmd = `pdf2svg $tmp.pdf $filename.svg`
    svg_sucess = success(`pdf2svg $tmp.pdf $filename.svg`)
    if !svg_sucess
        error("Failed to run $svg_cmd")
    end
    if !keep_pdf
        rm("$tmp.pdf")
    end
end

Base.mimewritable(::MIME"image/svg+xml", ::TikzDocument) = true

# Below here, Copyright TikzPictures.jl (see LICENSE.md)

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
