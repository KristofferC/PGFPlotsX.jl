# Coordinates

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    PGFPlotsX.save(figname * ".pdf", obj)
    run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`)
    PGFPlotsX.save(figname * ".tex", obj);
    return nothing
end
```

Use `Coordinates` to construct the `pgfplots` construct `coordinates`. Various constructors are available.

For basic usage, consider `AbstractVectors` and iterables. Notice how non-finite values are skipped. You can also use `()` or `nothing` for jumps in functions.

```@example pgf
x = linspace(-1, 1, 51) # so that it contains 1/0
@pgf Axis(
    {
        xmajorgrids,
        ymajorgrids,
    },
    Plot(
        {
            no_marks,
        },
        Coordinates(x, 1 ./ x)
    )
)
savefigs("coordinates-simple", ans) # hide
```

[\[.pdf\]](coordinates-simple.pdf), [\[generated .tex\]](coordinates-simple.tex)

![](coordinates-simple.svg)

Use `xerror`, `xerrorplus`, `xerrorminus`, `yerror` etc for error bars.
```@example pgf
x = linspace(0, 2π, 20)
@pgf Plot(
    {
        "no marks",
        "error bars/y dir=both",
        "error bars/y explicit",
    },
    Coordinates(x, sin.(x); yerror = 0.2*cos.(x))
)
savefigs("coordinates-errorbars", ans) # hide
```

[\[.pdf\]](coordinates-errorbars.pdf), [\[generated .tex\]](coordinates-errorbars.tex)

![](coordinates-errorbars.svg)

Use three vectors to construct 3D coordinates.

```@example pgf
t = linspace(0, 6*π, 100)
@pgf Plot3(
    {
        no_marks,
    },
    Coordinates(t .* sin.(t), t .* cos.(t), .-t)
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
@pgf Plot3(
    {
        surf,
    },
    Coordinates(x, y, f.(x, y'));
    incremental = false
)
savefigs("coordinates-3d-matrix", ans) # hide
```

[\[.pdf\]](coordinates-3d-matrix.pdf), [\[generated .tex\]](coordinates-3d-matrix.tex)

![](coordinates-3d-matrix.svg)

```@example pgf
x = linspace(-2, 2, 40)
y = linspace(-0.5, 3, 50)
@pgf Axis(
    {
        view = (0, 90),
        colorbar,
        "colormap/jet",
    },
    Plot3(
        {
            surf,
            shader = "flat",
        },
        Coordinates(x, y, @. √(f(x, y')));
        incremental = false
    )
)
savefigs("coordinates-3d-matrix-heatmap", ans) # hide
```

[\[.pdf\]](coordinates-3d-matrix-heatmap.pdf), [\[generated .tex\]](coordinates-3d-matrix-heatmap.tex)

![](coordinates-3d-matrix-heatmap.svg)
