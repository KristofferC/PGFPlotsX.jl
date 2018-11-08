using Test
using PGFPlotsX
using PGFPlotsX: Options
using Colors
using Contour
using DataFrames
using Dates
using LaTeXStrings
using Measurements

if get(ENV, "CI", false) == true
    PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)
end

@show PGFPlotsX.latexengine
PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)

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
            run(`$(cmd) -e 'using Pkg; Pkg.instantiate()'`)
            run(`$(cmd) docs/make.jl`)
        end
    end
end
