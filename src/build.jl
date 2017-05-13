################
# LaTeX-engine #
################
@enum(LaTeXEngine, LUALATEX, XELATEX, PDFLATEX)

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
"\\usepackage{tikz}",
"\\usepackage{pgfplots}",
haskey(ENV, "CI") ? "" : "\\pgfplotsset{compat=1.14}",
#"\\usepgfplotslibrary{groupplots}",
#"\\usepgfplotslibrary{polar}",
#"\\usepgfplotslibrary{statistics}",
]

# Collects the full preamble from the different sources, default and custom
function _print_preamble(io::IO)
    println(io, "% Default preamble")
    println(io, join(DEFAULT_PREAMBLE, "\n"), "\n")

    # Collect custom preambles
    if !isempty(CUSTOM_PREAMBLE)
        println(io, "% Custom preamble from global variable:")
        println(io, join(CUSTOM_PREAMBLE, "\n"), "\n")
    end

    if isfile(CUSTOM_PREAMBLE_PATH)
        str = readstring(CUSTOM_PREAMBLE_PATH)
        if !isempty(str)
            println(io, "% Custom preamble from custom_preamble.tex:")
            println(io, str, "\n")
        end
    end

    if haskey(ENV, "PGFPLOTSX_PREAMBLE_PATH") && isfile(ENV["PGFPLOTSX_PREAMBLE_PATH"])
        println(io, "% Custom preamble from ENV path:")
        println(io, readstring(ENV["PGFPLOTSX_PREAMBLE_PATH"]), "\n")
    end
end
