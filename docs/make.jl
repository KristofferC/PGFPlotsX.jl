using Documenter, PGFPlotsX
PGFPlotsX.latexengine!(PGFPlotsX.PDFLATEX)

using Contour, Colors, DataFrames

makedocs(
    modules = [PGFPlotsX],
    sitename = "PGFPlotsX.jl",
    doctest = true,
    strict = true,
    checkdocs = :none,
    assets = ["assets/custom.css"],
    pages = Any[
        "Home" => "index.md",
        "Manual" => [
            "man/structs.md",
            "man/options.md",
            "man/data.md",
            "man/axiselements.md",
            "man/axislike.md",
            "man/picdoc.md",
            "man/save.md",
            "man/internals.md",
            ],
        "Examples" => [
            "examples/coordinates.md",
            "examples/tables.md",
            "examples/axislike.md",
            "examples/gallery.md",
            "examples/juliatypes.md",
            "examples/convenience.md",
        ]
    ]
)

@info "calling deploydocs"

deploydocs(
    repo = "github.com/KristofferC/PGFPlotsX.jl.git",
)
