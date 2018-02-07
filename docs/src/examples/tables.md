# Tables

`Table`s are coordinates in a tabular format (essentially a matrix), optionally with named columns. They have various constructors, for direct construction and also for conversion from other types.

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
pgf.Plot(pgf.Table([x, y]); incremental = false)
savefigs("table-unnamed-columns", ans) # hide
```

[\[.pdf\]](table-unnamed-columns.pdf), [\[generated .tex\]](table-unnamed-columns.tex)

![](table-unnamed-columns.svg)

or named columns:

```@example pgf
pgf.Plot(pgf.Table([:x => x, :y => y]); incremental = false)
savefigs("table-named-columns", ans) # hide
```

[\[.pdf\]](table-named-columns.pdf), [\[generated .tex\]](table-named-columns.tex)

![](table-named-columns.svg)

or a dictionary, here renamed using options:

```@example pgf
pgf.@pgf pgf.Plot(
    {
        x = "a",
        y = "b",
    },
    pgf.Table(Dict(:a => x, :b => y));
    incremental = false)
savefigs("table-dict-rename", ans) # hide
```

[\[.pdf\]](table-dict-rename.pdf), [\[generated .tex\]](table-dict-rename.tex)

![](table-dict-rename.svg)

In the example below, we use a matrix of values with edge vectors, and omit the points outside the unit circle:
```@example pgf
x = linspace(-1, 1, 20)
z = @. 1 - √(abs2(x) + abs2(x'))
z[z .≤ 0] .= -Inf
@pgf.pgf pgf.Axis(
    {
        colorbar,
        "colormap/jet",
        "unbounded coords" = "jump"
    },
    pgf.Plot3(
        {
            surf,
            shader = "flat",
        },
        pgf.Table(x, x, z);
        incremental = false
    )
)
savefigs("table-jump-3d", ans) # hide
```

[\[.pdf\]](table-jump-3d.pdf), [\[generated .tex\]](table-jump-3d.tex)

![](table-jump-3d.svg)
