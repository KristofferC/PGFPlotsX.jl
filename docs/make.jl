using Documenter, PGFPlotsX
PGFPlotsX.latexengine!(PGFPlotsX.LUALATEX)
DocMeta.setdocmeta!(PGFPlotsX, :DocTestSetup, :(using PGFPlotsX); recursive=true)
using Contour, Colors, DataFrames, Distributions

makedocs(
    modules = [PGFPlotsX],
    format = Documenter.HTML(; assets = ["assets/custom.css"],
                             prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "PGFPlotsX.jl",
    doctest = true,
    checkdocs = :none,
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
            "examples/latex.md",
        ]
    ]
)

@info "calling deploydocs"

deploydocs(
    repo = "github.com/KristofferC/PGFPlotsX.jl.git",
    push_preview=true,
)
