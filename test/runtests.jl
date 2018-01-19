using PGFPlotsX
using Base.Test
using DataStructures: OrderedDict

const pgf = PGFPlotsX

if get(ENV, "CI", false) == true
    pgf.latexengine!(pgf.PDFLATEX)
end

@show pgf.latexengine
pgf.latexengine!(pgf.PDFLATEX)

include("test_macros.jl")

cd(tempdir()) do
    include("test_build.jl")
end

# Run doc stuff, turn off dprecations
cd(joinpath(@__DIR, "..", "docs")) do
    run(`$(Base.julia_cmd()) --depwarn=no --color=yes -L make.jl`)
end
