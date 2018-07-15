# Julia types

There is some support to directly use Julia objects from different popular packages in PGFPlotsX.jl. Examples of these are given here.

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`)
    pgfsave(figname * ".tex", obj);
    return nothing
end
```

## Colors.jl

### LineColor
Using a colorant as the line color

```@example pgf
using Colors
μ = 0
σ = 1e-3

axis = Axis()
@pgf for (i, col) in enumerate(distinguishable_colors(10))
    offset = i * 50
    p = Plot(
        {
            color = col,
            domain = "-3*$σ:3*$σ",
            style = { ultra_thick },
            samples = 50
        },
        Expression("exp(-(x-$μ)^2 / (2 * $σ^2)) / ($σ * sqrt(2*pi)) + $offset"))
    push!(axis, p)
end
axis
savefigs("colors", ans) # hide
```

[\[.pdf\]](colors.pdf), [\[generated .tex\]](colors.tex)

![](colors.svg)

### Colormap

Using a colormap

```@example pgf
using Colors
p = @pgf Plot3(
    {
        surf,
        point_meta = "y",
        samples = 13
    },
    Expression("cos(deg(x)) * sin(deg(y))")
)
colormaps = ["Blues", "Greens", "Oranges", "Purples"]
td = TikzDocument()
for cmap in colormaps
    push_preamble!(td, (cmap, Colors.colormap(cmap)))
end

tp = @pgf TikzPicture({ "scale" => 0.5 })
push!(td, tp)
gp = @pgf GroupPlot({ group_style = {group_size = "2 by 2"}})
push!(tp, gp)

for cmap in colormaps
    @pgf push!(gp, { colormap_name = cmap }, p)
end
savefigs("colormap", td) # hide
```

[\[.pdf\]](colormap.pdf), [\[generated .tex\]](colormap.tex)

![](colormap.svg)

### ggplot2

Something that looks a bit like ggplot2.

```@example pgf
using Colors
using LaTeXStrings

ggplot2_axis_theme = @pgf {
    tick_align = "outside",
    tick_pos = "left",
    xmajorgrids,
    x_grid_style = "white",
    ymajorgrids,
    y_grid_style = "white",
    axis_line_style = "white",
    "axis_background/.style" = {
        fill = "white!89.803921568627459!black"
    }
}

ggplot2_plot_theme = @pgf {
    mark="*",
    mark_size = 3,
    mark_options = "solid",
    line_width = "1.64pt",
}

x = 0:0.3:2
y1 = sin.(2x)
y2 = cos.(2x)
y3 = cos.(5x)
ys = [y1, y2, y3]
n = length(ys)

# Evenly spread out colors
colors = [LCHuv(65, 100, h) for h in range(15; stop = 360+15, length = n+1)][1:n]

@pgf Axis(
    {
         ggplot2_axis_theme...,
         xmin = -0.095, xmax = 1.995,
         ymin = -1.1,   ymax =1.1,
         title = L"Simple plot $\frac{\alpha}{2}$",
         xlabel = "time (s)",
         ylabel = "Voltage (mV)",
    },
    [
        PlotInc(
            {
                ggplot2_plot_theme...,
                color = colors[i]
            },
            Coordinates(x, _y))
        for (i, _y) in enumerate(ys)]...,
)
savefigs("ggplot", ans) # hide
```

[\[.pdf\]](ggplot.pdf), [\[generated .tex\]](ggplot.tex)

![](ggplot.svg)

## DataFrames.jl

Creating a `Table` from a `DataFrame` will write it as expected.

```@example pgf
using DataFrames

function mockdata(n, μ, σ, speed, racer)
    distance = exp.(μ .+ randn(n).*σ)
    noise = exp.(randn(n) * 0.1)
    DataFrame(distance = distance,
              tracktime = distance ./ (speed .* noise),
              racer = fill(racer, n))
end

zenon_measurements = vcat(mockdata(20, 1, 0.2, 0.5, "Tortoise"),
                          mockdata(20, 1, 0.2, 1, "Achilles"))

@pgf Axis(
    {
        legend_pos = "north west",
        xlabel = "distance",
        ylabel = "track time",
    },
    Plot(
        {
            scatter,
            "only marks",
            "scatter src"="explicit symbolic",
            "scatter/classes"=
            {
                Tortoise = {mark = "square*",   "blue"},
                Achilles = {mark = "triangle*", "red"},
            }
        },
        Table(
            {
                x = "distance",
                y = "tracktime",
                meta = "racer"
            },
            zenon_measurements, # <--- Creating a Table from a DataFrame
        )
    ),
    Legend(["Tortoise", "Achilles"])
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
@pgf Plot({
        contour_prepared,
        very_thick
    },
    Table(contours(x, y, f.(x, y'), 6)))
savefigs("contour", ans) # hide
```

[\[.pdf\]](contour.pdf), [\[generated .tex\]](contour.tex)

![](contour.svg)

## StatsBase.jl

`StatsBase.Histogram` can be plotted using `Table`, both for 1D and 2D histograms.

### 1D

```@example pgf
using StatsBase: Histogram, fit
@pgf Axis(
    {
        "ybar interval",
        "xticklabel interval boundaries",
        xmajorgrids = false,
        xticklabel = raw"$[\pgfmathprintnumber\tick,\pgfmathprintnumber\nexttick)$",
        "xticklabel style" =
        {
            font = raw"\tiny"
        },
    },
    Plot(Table(fit(Histogram, range(0; stop = 1, length = 100).^3, closed = :left))))
savefigs("histogram-1d", ans) # hide
```

[\[.pdf\]](histogram-1d.pdf), [\[generated .tex\]](histogram-1d.tex)

![](histogram-1d.svg)

### 2D

```@example pgf
using StatsBase: Histogram, fit
w = range(-1; stop = 1, length = 100) .^ 3
xy = vec(tuple.(w, w'))
h = fit(Histogram, (first.(xy), last.(xy)), closed = :left)
@pgf Axis(
    {
        view = (0, 90),
        colorbar,
        "colormap/jet"
    },
    Plot3(
        {
            surf,
            shader = "flat",

        },
        Table(h))
)
savefigs("histogram-2d", ans) # hide
```

[\[.pdf\]](histogram-2d.pdf), [\[generated .tex\]](histogram-2d.tex)

![](histogram-2d.svg)
