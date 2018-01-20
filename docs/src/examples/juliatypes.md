# Julia types

There is some support to directly use Julia objects from different popular packages in PGFPlotsX.jl. Examples of these are given here.
All code is assumed to include the following:

```jl
import PGFPlotsX
const pgf = PGFPlotsX; # hide
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

## Colors.jl

Using a colorant as the line color

```@example pgf
using Colors
μ = 0
σ = 1e-3

axis = pgf.Axis()
pgf.@pgf for (i, col) in enumerate(distinguishable_colors(10))
    offset = i * 50
    p = pgf.Plot(pgf.Expression("exp(-(x-$μ)^2 / (2 * $σ^2)) / ($σ * sqrt(2*pi)) + $offset"),
    {
        color = col,
        domain = "-3*$σ:3*$σ",
        style = { ultra_thick },
        samples = 50
    }; incremental = false)
    push!(axis, p)
end
axis
savefigs("colors", ans) # hide
```

[\[.pdf\]](colors.pdf), [\[generated .tex\]](colors.tex)

![](colors.svg)

Using a colormap

```@example pgf
using Colors
pgf.@pgf begin
p = pgf.Plot3(
    pgf.Expression("cos(deg(x)) * sin(deg(y))"),
    {
        surf,
        point_meta = "y",
        samples = 13
    };
    incremental = false
)
colormaps = ["Blues", "Greens", "Oranges", "Purples"]
td = pgf.TikzDocument()
for cmap in colormaps
    pgf.push_preamble!(td, (cmap, Colors.colormap(cmap)))
end

tp = pgf.TikzPicture("scale" => 0.5)
push!(td, tp)
gp = pgf.GroupPlot({ group_style = {group_size = "2 by 2"}})
push!(tp, gp)

for cmap in colormaps
    push!(gp, p, { colormap_name = cmap })
end

end
savefigs("colormap", td) # hide
```

[\[.pdf\]](colormap.pdf), [\[generated .tex\]](colormap.tex)

![](colormap.svg)

## DataFrames.jl

Creating a `Table` from a `DataFrame` will write it as expected.

```@example pgf
using DataFrames
using RDatasets
pgf.@pgf pgf.Axis(
    pgf.Plot(
        {
            only_marks
        },
        pgf.Table(
            dataset("datasets", "iris"),
            {
                x = "SepalLength",
                y = "SepalWidth"
            }
        )
    )
)
savefigs("dataframes", ans) # hide
```

[\[.pdf\]](dataframes.pdf), [\[generated .tex\]](dataframes.tex)

![](dataframes.svg)

## Countour.jl

A `Table` of a contour from the [Contours.jl package](https://github.com/JuliaGeometry/Contour.jl) will print as .tex in a format that is
good to use with `contour_prepared`.

```@example pgf
using Contour
x = 0.0:0.1:2π
y = 0.0:0.1:2π
f = (x,y) -> sin(x)*sin(y)
pgf.@pgf pgf.Plot(pgf.Table(contours(x, y, f.(x, y'), 6)),
    {
        contour_prepared,
        very_thick
    };
    incremental = false
)
savefigs("contour", ans) # hide
```

[\[.pdf\]](contour.pdf), [\[generated .tex\]](contour.tex)

![](contour.svg)
