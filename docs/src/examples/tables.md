# Tables

`Table`s are coordinates in a tabular format (essentially a matrix), optionally with named columns. They have various constructors, for direct construction and also for conversion from other types.


```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdftocairo -svg -l  1 $(figname * ".pdf") $(figname * ".svg")`)
    pgfsave(figname * ".tex", obj);
    return nothing
end
```

## Unnamed columns

Let
```jl
x = range(0; stop = 2*pi, length = 100)
y = sin.(x)
```

```@setup pgf
x = range(0; stop = 2*pi, length = 100)
y = sin.(x)
```

You can pass these coordinates in unnamed columns:

```@example pgf
Plot(Table([x, y]))
savefigs("table-unnamed-columns", ans) # hide
```

[\[.pdf\]](table-unnamed-columns.pdf), [\[generated .tex\]](table-unnamed-columns.tex)

![](table-unnamed-columns.svg)

## Named columns

Or named columns:

```@example pgf
Plot(Table([:x => x, :y => y]))
savefigs("table-named-columns", ans) # hide
```

[\[.pdf\]](table-named-columns.pdf), [\[generated .tex\]](table-named-columns.tex)

![](table-named-columns.svg)

## Rename options

The columns can be renamed using options:

```@example pgf
@pgf Plot(
    {
        x = "a",
        y = "b",
    },
    Table([:a => x, :b => y]))
savefigs("table-dict-rename", ans) # hide
```

[\[.pdf\]](table-dict-rename.pdf), [\[generated .tex\]](table-dict-rename.tex)

![](table-dict-rename.svg)

## Excluding points

In the example below, we use a matrix of values with edge vectors, and omit the points outside the unit circle:
```@example pgf
x = range(-1; stop = 1, length = 20)
z = @. 1 - √(abs2(x) + abs2(x'))
z[z .≤ 0] .= -Inf
@pgf Axis(
    {
        colorbar,
        "colormap/jet",
        "unbounded coords" = "jump"
    },
    Plot3(
        {
            surf,
            shader = "flat",
        },
        Table(x, x, z)
    )
)
savefigs("table-jump-3d", ans) # hide
```

[\[.pdf\]](table-jump-3d.pdf), [\[generated .tex\]](table-jump-3d.tex)

![](table-jump-3d.svg)

## Quiver plot

A quiver plot can be created as:

```@example pgf
x = -2pi:0.2:2*pi
y = sin.(x)

u = ones(length(x))
v = cos.(x)

@pgf Axis(
    {
        title = "Quiver plot",
        grid = "both"
    },
    Plot(
        {
            quiver = {u = "\\thisrow{u}", v = "\\thisrow{v}"},
            "-stealth"
        },
        Table(x = x, y = y, u = u, v = v)
    ),
    LegendEntry("\$\\cos(x)\$"),
    Plot(
        {
            color = "red",
            very_thick
        },
        Coordinates(x, y)
    ),
    LegendEntry("\$\\sin(x)\$")
)
savefigs("quiver", ans) # hide
```

[\[.pdf\]](quiver.pdf), [\[generated .tex\]](quiver.tex)

![](quiver.svg)
