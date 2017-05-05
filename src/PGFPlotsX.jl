module PGFPlotsX

"""
A `TikzElement` is a component of a `TikzPicture`. It can be a node or an axis etc.
"""
abstract TikzElement

include("utilities.jl")
include("tikzpicture.jl")


# TikzElements
include("tikzelements/plot.jl")

include("axis.jl")

end # module
