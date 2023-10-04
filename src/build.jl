################
# LaTeX-engine #
################
@enum(LaTeXEngine, LUALATEX, PDFLATEX, XELATEX)

"""
The active LaTeX engine. Initialized the first time [`latexengine`](@ref) is called.
"""
const ACTIVE_LATEX_ENGINE = Ref{Union{Nothing, LaTeXEngine}}(nothing)
function latexengine()
    if ACTIVE_LATEX_ENGINE[] === nothing
        for (engine, enum) in zip(("lualatex", "pdflatex", "xelatex"), (LUALATEX, PDFLATEX, XELATEX))
            @debug "latexengine: looking for latex engine $engine"
            if Sys.which(engine) !== nothing
                @debug "latexengine: found latex engine $engine, using it"
                return ACTIVE_LATEX_ENGINE[] = enum
            end
        end
        throw(MissingExternalProgramError("No LaTeX installation found, figures will not be generated. ",
                                          "Make sure either pdflatex, xelatex or lualatex are installed and that ",
                                          "the PATH variable is correctly set."))
    end
    return ACTIVE_LATEX_ENGINE[]
end
latexengine!(eng::LaTeXEngine) = ACTIVE_LATEX_ENGINE[] = eng

_engine_cmd(eng::LaTeXEngine) = `$(lowercase(string(eng)))`

"""
    succ, log, cmd = $SIGNATURES

Compile `filename` with LaTeX engine `eng` using the given `flags`.

Return the result of `success`, the contents of the logfile as a string, and the
`Cmd` object that was run (the latter two useful for diagnostics and informative
error messages).

Temporary files (`.aux`, `.log`) are cleaned up.

!!! NOTE

    Changing the working directory is required because of external tools like
    `gnuplot`, which don't respect `--output-directory`.
"""
function run_latex_once(filename::AbstractString, eng::LaTeXEngine, flags)
    dir, file = splitdir(filename)
    cmd = `$(_engine_cmd(eng)) $flags $file`
    @debug "running latex command $cmd in dir $dir"
    succ = cd(dir) do
        success(cmd)
    end
    logfile = _replace_fileext(filename, ".log")
    log = if !isfile(logfile)
        @warn "failed to find logfile at $(repr(logfile))"
        ""
    else
        read(logfile, String)
    end
    succ, log, cmd
end

function rm_tmpfiles(filename::AbstractString)
    logfile = _replace_fileext(filename, ".log")
    auxfile = _replace_fileext(filename, ".aux")
    rm(logfile; force = true)
    rm(auxfile; force = true)
    rm(filename; force = true)
end

DEFAULT_FLAGS = Union{String}[] # no default flags currently

"""
Custom flags to the engine can be used in the latex command by `push!`-ing them
into the global variable `CUSTOM_FLAGS`.
"""
CUSTOM_FLAGS = Union{String}[]

############
# Preamble #
############

"""
A vector of stings, added after [`DEFAULT_PREAMBLE`](@ref).

Use this for additional definitions `\\usepackage` statements required by the LaTeX
code you include into plots.
"""
CUSTOM_PREAMBLE = String[]

"""
The default preamble for LaTeX documents. Don't change this, customize
[`CUSTOM_PREAMBLE`](@ref) instead.
"""
DEFAULT_PREAMBLE =
    String[
        "\\usepackage{pgfplots}",
        "\\pgfplotsset{compat=newest}",
        "\\usepgfplotslibrary{groupplots}",
        "\\usepgfplotslibrary{polar}",
        "\\usepgfplotslibrary{smithchart}",
        "\\usepgfplotslibrary{statistics}",
        "\\usepgfplotslibrary{dateplot}",
        "\\usepgfplotslibrary{ternary}",
    ]

# Collects the full preamble from the different sources, default and custom
function _default_preamble()
    preamble = []
    push!(preamble, "% Default preamble")
    append!(preamble, DEFAULT_PREAMBLE)

    # Collect custom preambles
    if !isempty(CUSTOM_PREAMBLE)
        push!(preamble, "% Custom preamble from global variable:")
        append!(preamble, CUSTOM_PREAMBLE)
    end

    if isfile(CUSTOM_PREAMBLE_PATH)
        str = read(CUSTOM_PREAMBLE_PATH, String)
        if !isempty(str)
            push!(preamble, "% Custom preamble from custom_preamble.tex:")
            push!(preamble, str, "\n")
        end
    end

    if haskey(ENV, "PGFPLOTSX_PREAMBLE_PATH") && isfile(ENV["PGFPLOTSX_PREAMBLE_PATH"])
        push!(preamble, "% Custom preamble from ENV path:")
        push!(preamble, read(ENV["PGFPLOTSX_PREAMBLE_PATH"], String), "\n")
    end
    return preamble
end

#######
# PNG #
#######
@enum(PNGEngine, NO_PNG_ENGINE, PNG_PDF_TO_CAIRO, PDF_TO_PPM)
const ACTIVE_PNG_ENGINE = Ref{Union{Nothing, PNGEngine}}(nothing)
function png_engine()
    if ACTIVE_PNG_ENGINE[] === nothing
        for (engine, enum) in zip(("pdftocairo", "pdftoppm"), (PNG_PDF_TO_CAIRO, PDF_TO_PPM))
            @debug "png_engine: looking for png engine $engine"
            if Sys.which(engine) !== nothing
                @debug "png_engine: found png engine $engine, using it"
                return ACTIVE_PNG_ENGINE[] = enum
            end
        end
        return ACTIVE_PNG_ENGINE[] = NO_PNG_ENGINE
    end
    return ACTIVE_PNG_ENGINE[]
end

"""
$(SIGNATURES)

Convert a PDF file to PNG. The filename for the result can be omitted, in which case it will
be generated by replacing the extension (if any).

Relies on external programs, see the manual.

Part of the API, but not exported.
"""
function convert_pdf_to_png(pdf::AbstractString,
                            png::AbstractString = _replace_fileext(pdf, ".png");
                            engine::PNGEngine=png_engine(), dpi::Number=150)
    if engine == NO_PNG_ENGINE
        throw(MissingExternalProgramError("No PDF to PNG converter found, we looked for `pdftocairo` and `pdftoppm`. ",
                                          "Make sure one of these are installed and available at PATH and restart Julia."))
    end
    if engine == PNG_PDF_TO_CAIRO
        cmd = `pdftocairo -png -r $dpi -singlefile $pdf $png`
    elseif engine == PDF_TO_PPM
        cmd = `pdftoppm -png -r $dpi -singlefile $pdf $png`
    else
        error("unreachable reached")
    end
    @debug "convert_pdf_to_png: running $cmd"
    return run(cmd)
end


#######
# SVG #
#######
@enum(SVGEngine, NO_SVG_ENGINE, SVG_PDF_TO_CAIRO, PDF_TO_SVG)
const ACTIVE_SVG_ENGINE = Ref{Union{Nothing, SVGEngine}}(nothing)
function svg_engine()
    if ACTIVE_SVG_ENGINE[] === nothing
        for (engine, enum) in zip(("pdftocairo", "pdf2svg"), (SVG_PDF_TO_CAIRO, PDF_TO_SVG))
            @debug "svg_engine: looking for svg engine $engine"
            if Sys.which(engine) !== nothing
                @debug "svg_engine: found svg engine $engine, using it"
                return ACTIVE_SVG_ENGINE[] = enum
            end
        end
        return ACTIVE_SVG_ENGINE[] = NO_SVG_ENGINE
    end
    return ACTIVE_SVG_ENGINE[]
end

"""
$(SIGNATURES)

Convert a PDF file to SVG. The filename for the result can be omitted, in which case it will
be generated by replacing the extension (if any).

Relies on external programs, see the manual.

Part of the API, but not exported.
"""
function convert_pdf_to_svg(pdf::AbstractString,
                            svg::AbstractString = _replace_fileext(pdf, ".svg");
                            engine=svg_engine())
    if engine == NO_SVG_ENGINE
        throw(MissingExternalProgramError("No PDF to SVG converter found, we looked for `pdftocairo` and `pdf2svg`. ",
                                          "Make sure one of these are installed and available at PATH and restart Julia."))
    end
    if engine == SVG_PDF_TO_CAIRO
        cmd = `pdftocairo -svg -l 1 $pdf $svg`
    elseif engine == PDF_TO_SVG
        cmd = `pdf2svg $pdf $svg`
    else
        error("unreachable reached")
    end
    @debug "convert_pdf_to_svg: running $cmd"
    return run(cmd)
end
