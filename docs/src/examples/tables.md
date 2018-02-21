# Tables

`Table`s are coordinates in a tabular format (essentially a matrix), optionally with named columns. They have various constructors, for direct construction and also for conversion from other types.


```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    PGFPlotsX.save(figname * ".pdf", obj)
    run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`)
    PGFPlotsX.save(figname * ".tex", obj);
    return nothing
end
```

Let
```jl
x = linspace(0, 2*pi, 100)
y = sin.(x)
```

```@setup pgf
x = linspace(0, 2*pi, 100)
y = sin.(x)
```

You can pass these coordinates in unnamed columns:

```@example pgf
Plot(Table([x, y]))
savefigs("table-unnamed-columns", ans) # hide
```

[\[.pdf\]](table-unnamed-columns.pdf), [\[generated .tex\]](table-unnamed-columns.tex)

![](table-unnamed-columns.svg)

or named columns:

```@example pgf
Plot(Table([:x => x, :y => y]))
savefigs("table-named-columns", ans) # hide
```

[\[.pdf\]](table-named-columns.pdf), [\[generated .tex\]](table-named-columns.tex)

![](table-named-columns.svg)

or rename using options:

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

In the example below, we use a matrix of values with edge vectors, and omit the points outside the unit circle:
```@example pgf
x = linspace(-1, 1, 20)
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
