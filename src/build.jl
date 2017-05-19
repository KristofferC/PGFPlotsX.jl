################
# LaTeX-engine #
################
@enum(LaTeXEngine, LUALATEX, PDFLATEX)

const ACTIVE_LATEX_ENGINE = Ref(LUALATEX)
latexengine() = ACTIVE_LATEX_ENGINE[]
latexengine!(eng::LaTeXEngine) = ACTIVE_LATEX_ENGINE[] = eng

_engine_cmd(eng::LaTeXEngine) = `$(lowercase(string(eng)))`

_latex_cmd(file::String, eng::LaTeXEngine, flags) = `$(_engine_cmd(eng)) $flags $file`

DEFAULT_FLAGS = Union{String}[] # no default flags currently
CUSTOM_FLAGS = Union{String}[]

############
# Preamble #
############

CUSTOM_PREAMBLE = String[]

DEFAULT_PREAMBLE =
String[
"\\usepackage{pgfplots}",
"\\pgfplotsset{compat=newest}",
"\\usepgfplotslibrary{groupplots}",
"\\usepgfplotslibrary{polar}",
"\\usepgfplotslibrary{statistics}",
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
        str = readstring(CUSTOM_PREAMBLE_PATH)
        if !isempty(str)
            push!(preamble, "% Custom preamble from custom_preamble.tex:")
            push!(preamble, str, "\n")
        end
    end

    if haskey(ENV, "PGFPLOTSX_PREAMBLE_PATH") && isfile(ENV["PGFPLOTSX_PREAMBLE_PATH"])
        push!(preamble, "% Custom preamble from ENV path:")
        push!(preamble, readstring(ENV["PGFPLOTSX_PREAMBLE_PATH"]), "\n")
    end
    return preamble
end
