using Test
using PGFPlotsX
using PGFPlotsX: Options
using DataFrames
using Dates
using Measurements

if get(ENV, "CI", false) == true
    PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)
end

@show PGFPlotsX.latexengine
PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)

@info "External binaries" PGFPlotsX.HAVE_PDFTOPPM PGFPlotsX.HAVE_PDFTOSVG

if !(PGFPlotsX.HAVE_PDFTOPPM && PGFPlotsX.HAVE_PDFTOSVG)
    @warn "Both `pdf2svg` or `pdftoppm` needs to be installed for complete test coverage."
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
