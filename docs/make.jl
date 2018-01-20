using Documenter, PGFPlotsX

using Contour, Colors, DataFrames, RDatasets

makedocs(
    modules = [PGFPlotsX],
    format = :html,
    sitename = "PGFPlotsX.jl",
    doctest = false,
    strict = false,
    pages = Any[
        "Home" => "index.md",
        "Manual" => [
            "man/options.md",
            "man/structs.md",
            "man/save.md",
            "man/custom_types.md",
            ],
        "Examples" => [
            "examples/gallery.md",
            "examples/juliatypes.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/KristofferC/PGFPlotsX.jl.git",
    target = "build",
    julia = "0.6",
    deps = nothing,
    make = nothing
)
