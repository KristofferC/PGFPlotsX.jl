# Julia types

There is some support to directly use Julia objects from different popular packages in PGFPlotsX.jl. Examples of these are given here.
All code is assumed to include the following.

```jl
import PGFPlotsX
const pgf = PGFPlotsX; # hide
using LaTeXStrings
```

```@setup pgf
import PGFPlotsX
const pgf = PGFPlotsX
using LaTeXStrings
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
a = ans; figname = "colors" # hide
pgf.save(figname * ".pdf", a); run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`); pgf.save(figname * ".tex", a); nothing # hide
```

[\[.pdf\]](colors.pdf), [\[generated .tex\]](colors.tex)

![](colors.svg)

Using a colormap

```@example pgf
pgf.@pgf begin
p = pgf.Plot3(pgf.Expression("cos(deg(x)) * sin(deg(y))"), { surf, point_meta = "y" }; incremental = false)
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
figname = "colormap" # hide
pgf.save(figname * ".pdf", td); pgf.save(figname * ".png", td); pgf.save(figname * ".tex", td); nothing # hide
```

[\[.pdf\]](colormap.pdf), [\[generated .tex\]](colormap.tex)

![](colormap.png)

## DataFrames.jl

Creating a `Table` from a `DataFrame` will write it as expected.

```@example pgf
using DataFrames
using RDatasets
pgf.@pgf pgf.Axis(
    pgf.Plot(
        { only_marks },
        pgf.Table(
            dataset("datasets", "iris"),
            {
                x = "SepalLength",
                y = "SepalWidth"
            }
        )
    )
)
a = ans; figname = "dataframes" # hide
pgf.save(figname * ".pdf", a); run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`); pgf.save(figname * ".tex", a); nothing # hide
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

a = ans; figname = "contour" # hide
pgf.save(figname * ".pdf", a); run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`); pgf.save(figname * ".tex", a); nothing # hide
```

[\[.pdf\]](contour.pdf), [\[generated .tex\]](contour.tex)

![](contour.svg)
