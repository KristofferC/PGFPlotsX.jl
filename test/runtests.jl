using Test
using PGFPlotsX
using PGFPlotsX: Options
using DataFrames
using Dates
using Measurements
using Colors

if get(ENV, "CI", false) == true
    PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)
end

@show PGFPlotsX.latexengine
PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)

GNUPLOT_VERSION = try chomp(read(`gnuplot -V`, String)); catch; nothing; end
HAVE_GNUPLOT = GNUPLOT_VERSION ≠ nothing

@info "External binaries" PGFPlotsX.png_engine() PGFPlotsX.svg_engine() GNUPLOT_VERSION

if !(PGFPlotsX.png_engine() !== PGFPlotsX.NO_PNG_ENGINE && 
     PGFPlotsX.svg_engine() !== PGFPlotsX.NO_SVG_ENGINE &&
     HAVE_GNUPLOT)
    @warn "External binaries `pdf2svg`, `pdftoppm`, and `gnuplot` need to be installed
for complete test coverage."
end

include("utilities.jl")

include("test_options.jl")

include("test_elements.jl")

mktempdir() do tmp; cd(tmp) do
    include("test_build.jl")
end end

# Build the docs on Julia v1.0
if get(ENV, "TRAVIS_JULIA_VERSION", nothing) == "1.0"
    cd(joinpath(@__DIR__, "..")) do
        withenv("JULIA_LOAD_PATH" => nothing) do
            cmd = `$(Base.julia_cmd()) --depwarn=no --color=yes --project=docs/`
            coverage = Base.JLOptions().code_coverage == 0 ? "none" : "user"
            run(`$(cmd) -e 'using Pkg; Pkg.instantiate()'`)
            run(`$(cmd) --code-coverage=$(coverage) docs/make.jl`)
        end
    end
end
