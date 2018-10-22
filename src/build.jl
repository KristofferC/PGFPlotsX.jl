################
# LaTeX-engine #
################
@enum(LaTeXEngine, LUALATEX, PDFLATEX)

const ACTIVE_LATEX_ENGINE = Ref(LUALATEX)
latexengine() = ACTIVE_LATEX_ENGINE[]
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
function run_latex_once(filename::String, eng::LaTeXEngine, flags)
    dir, file = splitdir(filename)
    cmd = `$(_engine_cmd(eng)) $flags $file`
    succ = cd(() -> success(cmd), dir)
    logfile = _replace_fileext(filename, ".log")
    log = read(logfile, String)
    succ, log, cmd
end

function rm_tmpfiles(filename::String)
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
        "\\usepgfplotslibrary{statistics}",
        "\\usepgfplotslibrary{dateplot}",
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
