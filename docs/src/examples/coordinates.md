# Coordinates

```jl
import PGFPlotsX
const pgf = PGFPlotsX
using LaTeXStrings
```

```@setup pgf
import PGFPlotsX
const pgf = PGFPlotsX
using LaTeXStrings
savefigs = (figname, obj) -> begin
    pgf.save(figname * ".pdf", obj)
    run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`)
    pgf.save(figname * ".tex", obj);
    return nothing
end
```

Use `Coordinates` to construct the `pgfplots` construct `coordinates`. Various constructors are available.

For basic usage, consider `AbstractVectors` and iterables. Notice how non-finite values are skipped. You can also use `()` or `nothing` for jumps in functions.

```@example pgf
x = linspace(-1, 1, 51) # so that it contains 1/0
pgf.@pgf pgf.Axis(
    {
        xmajorgrids,
        ymajorgrids,
    },
    pgf.Plot(
        {
            no_marks,
        },
        pgf.Coordinates(x, 1 ./ x)
    )
)
savefigs("coordinates-simple", ans) # hide
```

[\[.pdf\]](coordinates-simple.pdf), [\[generated .tex\]](coordinates-simple.tex)

![](coordinates-simple.svg)

Use `xerror`, `xerrorplus`, `xerrorminus`, `yerror` etc for error bars.
```@example pgf
x = linspace(0, 2π, 20)
pgf.@pgf pgf.Plot(
    {
        "no marks",
        "error bars/y dir=both",
        "error bars/y explicit",
    },
    pgf.Coordinates(x, sin.(x); yerror = 0.2*cos.(x))
)
savefigs("coordinates-errorbars", ans) # hide
```

[\[.pdf\]](coordinates-errorbars.pdf), [\[generated .tex\]](coordinates-errorbars.tex)

![](coordinates-errorbars.svg)

Use three vectors to construct 3D coordinates.

```@example pgf
t = linspace(0, 6*π, 100)
pgf.@pgf pgf.Plot3(
    {
        no_marks,
    },
    pgf.Coordinates(t .* sin.(t), t .* cos.(t), .-t)
)
savefigs("coordinates-3d", ans) # hide
```

[\[.pdf\]](coordinates-3d.pdf), [\[generated .tex\]](coordinates-3d.tex)

![](coordinates-3d.svg)

A convenience constructor is available for plotting a matrix of values calculated from edge vectors.

```@example pgf
x = linspace(-2, 2, 20)
y = linspace(-0.5, 3, 25)
f(x, y) = (1 - x)^2 + 100*(y - x^2)^2
pgf.@pgf pgf.Plot3(
    {
        surf,
    },
    pgf.Coordinates(x, y, f.(x, y'));
    incremental = false
)
savefigs("coordinates-3d-matrix", ans) # hide
```

[\[.pdf\]](coordinates-3d-matrix.pdf), [\[generated .tex\]](coordinates-3d-matrix.tex)

![](coordinates-3d-matrix.svg)

```@example pgf
x = linspace(-2, 2, 40)
y = linspace(-0.5, 3, 50)
pgf.@pgf pgf.Axis(
    {
        view = (0, 90),
        colorbar,
        "colormap/jet",
    },
    pgf.Plot3(
        {
            surf,
            shader = "flat",
        },
        pgf.Coordinates(x, y, @. √(f(x, y')));
        incremental = false
    )
)
savefigs("coordinates-3d-matrix-heatmap", ans) # hide
```

[\[.pdf\]](coordinates-3d-matrix-heatmap.pdf), [\[generated .tex\]](coordinates-3d-matrix-heatmap.tex)

![](coordinates-3d-matrix-heatmap.svg)
