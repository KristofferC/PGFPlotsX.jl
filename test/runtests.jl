using PGFPlotsX
using Base.Test

const pgf = PGFPlotsX

if get(ENV, "CI", false) == true
    pgf.latexengine!(pgf.PDFLATEX)
end

@show pgf.latexengine
pgf.latexengine!(pgf.PDFLATEX)

cd(tempdir()) do
    include("test_build.jl")
end

# Run doc stuff
include("../docs/make.jl")
