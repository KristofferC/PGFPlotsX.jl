using Documenter, PGFPlotsX

makedocs(
    modules = [PGFPlotsX],
    format = :html,
    sitename = "PGFPlotsX.jl",
    doctest = false,
    strict = false,
    pages = Any[
        "Home" => "index.md",
        "Manual" => [
            "man/build.md"
            ],
    ]
)

deploydocs(
    repo = "github.com/KristofferC/PGFPlotsX.jl.git",
    target = "build",
    julia = "0.6",
    deps = nothing,
    make = nothing
)
