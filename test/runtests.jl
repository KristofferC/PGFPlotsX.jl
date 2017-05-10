using PGFPlotsX
using Base.Test

const pgf = PGFPlotsX

include("test_build.jl")

# Run doc stuff
include("../docs/make.jl")
