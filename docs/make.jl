using Documenter, PGFPlotsX

using Contour, Colors, DataFrames, RDatasets

makedocs(
    modules = [PGFPlotsX],
    format = :html,
    sitename = "PGFPlotsX.jl",
    doctest = true,
    strict = false,
    pages = Any[
        "Home" => "index.md",
        "Manual" => [
            "man/options.md",
            "man/structs.md",
            "man/save.md",
            ],
        "Examples" => [
            "examples/coordinates.md",
            "examples/tables.md",
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
