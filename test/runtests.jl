using PGFPlotsX
using Base.Test
using Compat
using DataStructures: OrderedDict
using DataFrames

const pgf = PGFPlotsX

if get(ENV, "CI", false) == true
    pgf.latexengine!(pgf.PDFLATEX)
end

@show pgf.latexengine
pgf.latexengine!(pgf.PDFLATEX)

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
