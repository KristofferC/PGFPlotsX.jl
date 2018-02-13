using PGFPlotsX
using Base.Test
using Colors
using Compat
using Contour
using DataFrames
using LaTeXStrings
using RDatasets

if get(ENV, "CI", false) == true
    PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)
end

@show PGFPlotsX.latexengine
PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)

include("test_macros.jl")

include("test_elements.jl")

cd(tempdir()) do
    include("test_build.jl")
end

include("../docs/make.jl")

# Run doc stuff, turn off dprecations (this doesn't seem to work on .travis)
# cd(joinpath(@__DIR__, "..", "docs")) do
#    run(`$(Base.julia_cmd()) --depwarn=no --color=yes -L make.jl`)
#end
