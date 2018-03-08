"""
    TikzDocument(elements...; use_default_preamble = true, preamble = [])

Corresponds to a LaTeX document, usually wrapping `TikzPicture`s.

`use_default_preamble` determines whether a preamble is added from the global
variables (see [`CUSTOM_PREAMBLE`](@ref) and [`CUSTOM_PREAMBLE_PATH`](@ref).

`preamble` is appended after the default one (if any).

`push!` can be used to append elements after construction, and similarly
`push_preamble!` for the preamble.
"""
struct TikzDocument
    elements::Vector{Any}
    "Flag for adding the default preamble before `preamble`."
    use_default_preamble::Bool
    "Add to the preamble."
    preamble::Vector{Any}
    function TikzDocument(elements...; use_default_preamble = true, preamble = [])
        new(collect(Any, elements), use_default_preamble, preamble)
    end
end

Base.push!(td::TikzDocument, items...) = (push!(td.elements, items...); td)
Base.append!(td::TikzDocument, items) = (append!(td.elements, items); td)

"""
    $SIGNATURES

Works like `push!`, but places `items` in the preamble.
"""
push_preamble!(td::TikzDocument, items...) = (push!(td.preamble, items...); td)

##########
# Output #
##########

"""
Extensions that make [`save`](@ref) choose a standalone `tikz` format.

The saved file has no preamble, just a `tikzpicture` environment. These
extensions should be recognized by `\\includegraphics` when the
[tikzscale](https://www.ctan.org/pkg/tikzscale) LaTeX package is used.
"""
const STANDALONE_TIKZ_FILEEXTS = [".tikz", ".TIKZ", ".TikZ", ".pgf", ".PGF"]

"""
    $SIGNATURES

Save the argument (either [`TikzDocument`](@ref), or some other type which is
wrapped in one automatically, eg [`TikzPicture`](@ref), [`Axis`](@ref), or
[`Plot`](@ref)) to `filename`, guessing the format from the file extension.
Keywords specify options, some specific to some output formats.

`pgfsave` is an alias which is exported.
"""
function save(filename::String, td::TikzDocument;
              include_preamble::Bool = true,
              latex_engine = latexengine(),
              buildflags = vcat(DEFAULT_FLAGS, CUSTOM_FLAGS),
              dpi = 150)
    filebase, fileext = splitext(filename)
    if fileext == ".tex"
        savetex(filename, td; include_preamble = include_preamble)
    elseif fileext ∈ STANDALONE_TIKZ_FILEEXTS
        savetex(filename, td; include_preamble = false)
    elseif HAVE_PDFTOSVG && fileext == ".svg"
        savesvg(filename, td;
                latex_engine = latex_engine, buildflags = buildflags)
    elseif fileext == ".pdf"
        savepdf(filename, td;
                latex_engine = latex_engine, buildflags = buildflags)
    elseif HAVE_PDFTOPPM && fileext == ".png"
        savepng(filename, td;
                latex_engine = latex_engine, buildflags = buildflags, dpi = dpi)
    else
        allowed_file_endings = vcat(["tex", "pdf"],
                                    lstrip.(STANDALONE_TIKZ_FILEEXTS, '.'))
        if HAVE_PDFTOPPM
            push!(allowed_file_endings, "png")
        end
        if HAVE_PDFTOSVG
            push!(allowed_file_endings, "svg")
        end
        throw(ArgumentError("allowed file endings are $(join(allowed_file_endings, ", "))."))
    end
    return
end

const pgfsave = save

# TeX
function savetex(filename::String, td::TikzDocument;
                 include_preamble::Bool = true)
    open(filename, "w") do io
        savetex(io, td; include_preamble = include_preamble)
    end
end

_OLD_LUALATEX = false

savetex(io::IO, td::TikzDocument; include_preamble::Bool = true) =
    print_tex(io, td; include_preamble = include_preamble)

function print_tex(io::IO, td::TikzDocument; include_preamble::Bool = true)
    global _OLD_LUALATEX
    @unpack elements, use_default_preamble, preamble = td
    if isempty(td.elements)
        warn("Tikz document is empty")
    end
    if include_preamble
        if !_OLD_LUALATEX
            println(io, "\\RequirePackage{luatex85}")
        end
        # Temp workaround for CI
        println(io, "\\documentclass[tikz]{standalone}")
        if use_default_preamble
            preamble = vcat(_default_preamble(), preamble)
        end
        for preamble_line in preamble
            print_tex(io, preamble_line, td)
        end
        println(io, "\\begin{document}")
    end
    for element in td.elements
        print_tex(io, element, td)
    end
    if include_preamble
        println(io, "\\end{document}")
    end
end

_HAS_WARNED_SHELL_ESCAPE = false

function savepdf(filename::String, td::TikzDocument;
                 latex_engine = latexengine(),
                 buildflags = vcat(DEFAULT_FLAGS, CUSTOM_FLAGS))
    global _HAS_WARNED_SHELL_ESCAPE, _OLD_LUALATEX
    run_again = false

    tmp = tempname()
    tmp_tex = tmp * ".tex"
    tmp_pdf = tmp * ".pdf"
    savetex(tmp_tex, td)
    latex_success, log, latexcmd = run_latex_once(tmp_tex,
                                                  latex_engine, buildflags)
    rm(tmp_tex; force = true)

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
    if run_again
        savepdf(filename, td)
        return
    end
    mv(tmp_pdf, filename; remove_destination = true)
end

const _SHOWABLE = Union{Plot, AbstractVector{Plot}, AxisLike, TikzDocument, TikzPicture}

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

global _tikzid = round(UInt64, time() * 1e6)

if HAVE_PDFTOSVG
    """
    $SIGNATURES

Save `td` in `filename` using the SVG format.

Generates an interim PDF which is deleted; use `keep_pdf = true` to copy it to
`filename` with the extension (if any) replaced by `".pdf"`. This overwrites
an existing PDF file with the same name.
"""
    function savesvg(filename::String, td::TikzDocument;
                     latex_engine = latexengine(),
                     buildflags = vcat(DEFAULT_FLAGS, CUSTOM_FLAGS),
                     keep_pdf = false)
        tmp_pdf = tempname() * ".pdf"
        savepdf(tmp_pdf, td, latex_engine = latex_engine, buildflags = buildflags)
        # TODO Better error
        svg_cmd = `pdf2svg $tmp_pdf $filename`
        svg_success = success(svg_cmd)
        if !svg_success
            error("Failed to run $svg_cmd")
        end
        if keep_pdf
            mv(tmp_pdf, _replace_fileext(filename, ".pdf");
               remove_destination = true)
        else
            rm(tmp_pdf)
        end
    end

    # Copyright TikzPictures.jl (see LICENSE.md)
    function Base.show(f::IO, ::MIME"image/svg+xml", td::_SHOWABLE)
        global _tikzid
        filename = tempname() * ".svg"
        save(filename, td)
        s = readstring(filename)
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
        rm(filename; force = true)
    end
end

_JUNO_PNG = false
_JUNO_DPI = 150
show_juno_png(v::Bool) = global _JUNO_PNG = v
dpi_juno_png(dpi::Int) = global _JUNO_DPI = dpi

@require Juno begin
    import Media
    import Hiccup
    Media.media(_SHOWABLE, Media.Plot)
    function Media.render(pane::Juno.PlotPane, p::_SHOWABLE)
        f = tempname() * ((!_JUNO_PNG && HAVE_PDFTOSVG) ? ".svg" : ".png")
        save(f, p; dpi = _JUNO_DPI)
        Media.render(pane, Hiccup.div(style="background-color:#ffffff",
                           Hiccup.img(src = f)))
    end
end

if HAVE_PDFTOPPM
    function savepng(filename::String, td::TikzDocument;
                     latex_engine = latexengine(),
                     buildflags = vcat(DEFAULT_FLAGS, CUSTOM_FLAGS),
                     dpi::Int = 150)
        tmp = tempname() * ".pdf"
        filebase = splitext(filename)[1]
        savepdf(tmp, td, latex_engine = latex_engine, buildflags = buildflags)
        png_cmd = `pdftoppm -png -r $dpi -singlefile $tmp $filebase`
        png_success = success(png_cmd)
        if !png_success
            error("Error when saving to png")
        end
    end

    function Base.show(io::IO, ::MIME"image/png", p::_SHOWABLE)
        filename = tempname() * ".png"
        save(filename, p)
        write(io, read(filename))
        rm(filename; force = true)
    end
end
_DISPLAY_PDF = true
enable_interactive(v::Bool) = global _DISPLAY_PDF = v
_is_ijulia() = isdefined(Main, :IJulia) && Main.IJulia.inited
_is_juno()   = isdefined(Main, :Juno) && Main.Juno.isactive()
_is_vscode() = isdefined(Main, :_vscodeserver)


function Base.show(io::IO, ::MIME"text/plain", p::_SHOWABLE)
    if isinteractive() && _DISPLAY_PDF && !_is_ijulia() && !_is_juno() && isdefined(Base, :active_repl)
        filename = tempname() .* ".pdf"
        save(filename, p)
        try
            if is_apple()
                run(`open $filename`)
            elseif is_linux() || is_bsd()
                run(`xdg-open $filename`)
            elseif is_windows()
                run(`start $filename`)
            end
        catch e
            error("Failed to show the generated pdf, run `PGFPlotsX.enable_interactive(false)` to stop trying to show pdfs.\n", "Error: ", sprint(Base.showerror, e))
        end
    else
        print(io, p)
    end
end
