# Axis-like objects

## Simple group plot

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdftocairo -svg -l  1 $(figname * ".pdf") $(figname * ".svg")`)
    pgfsave(figname * ".tex", obj);
    return nothing
end
```
------------------------

```@example pgf
cs = [[(0,0), (1,1), (2,2)],
      [(0,2), (1,1), (2,0)],
      [(0,2), (1,1), (2,1)],
      [(0,2), (1,1), (1,0)]]

@pgf gp = GroupPlot(
    {
        group_style = { group_size = "2 by 2",},
        height = "4cm",
        width = "4cm"
    }
)

@pgf for (i, coords) in enumerate(cs)
    push!(gp, {title = i})
    push!(gp, PlotInc(Coordinates(coords)))
end
gp
savefigs("groupplot-simple", ans) # hide
```

[\[.pdf\]](groupplot-simple.pdf), [\[generated .tex\]](groupplot-simple.tex)

![](groupplot-simple.svg)

## Multiple group plots

Each set of options (here, empty `{}`) starts a new set of axes.

```@example pgf
x = range(0; stop =2*pi, length = 100)
@pgf GroupPlot(
    {
        group_style =
        {
            group_size="2 by 1",
            xticklabels_at="edge bottom",
            yticklabels_at="edge left"
        },
        no_markers
    },
    {},
    PlotInc(Table(x, sin.(x))),
    PlotInc(Table(x, sin.(x .+ 0.5))),
    {},
    PlotInc(Table(x, cos.(x))),
    PlotInc(Table(x, cos.(x .+ 0.5))))
savefigs("groupplot-multiple", ans) # hide
```

[\[.pdf\]](groupplot-multiple.pdf), [\[generated .tex\]](groupplot-multiple.tex)

![](groupplot-multiple.svg)

## Using `Axis` etc in group plots

Alternatively, you can use `Axis`, `SemiLogXAxis`, `SemiLogYAxis` and `LogLogAxis` to group together options and a set of plots. This makes it easier to combine existing plots into a grouped plot.

```@example pgf
x = range(0; stop=2, length = 100)
exp_plot = PlotInc(Table(x, exp.(x)))
exp_legend = LegendEntry(raw"$\exp(x)$")
log_plot = PlotInc(Table(x, log.(x)))
log_legend = LegendEntry(raw"$\log(x)$")

axs1 = @pgf Axis(exp_plot, exp_legend, log_plot, log_legend)
axs2 = @pgf SemiLogYAxis(exp_plot, exp_legend, log_plot, log_legend)
axs3 = @pgf SemiLogXAxis(exp_plot, exp_legend, log_plot, log_legend)
axs4 = @pgf LogLogAxis(exp_plot, exp_legend, log_plot, log_legend)

@pgf GroupPlot(
    { group_style = { group_size="2 by 2" },
      no_markers,
      legend_pos="north west",
      xlabel=raw"$x$",
    },
    axs1, axs2, axs3, axs4)
savefigs("groupplot-multiple-axis", ans) # hide
```

[\[.pdf\]](groupplot-multiple-axis.pdf), [\[generated .tex\]](groupplot-multiple-axis.tex)

![](groupplot-multiple-axis.svg)

## Polar axis

```@example pgf
angles = [ℯ/50*360*i for i in 1:500]
radius = [1/(sqrt(i)) for i in range(1; stop = 10, length = 500)]
PolarAxis(PlotInc(Coordinates(angles, radius)))
savefigs("polar", ans) # hide
```

[\[.pdf\]](polar.pdf), [\[generated .tex\]](polar.tex)

![](polar.svg)

## Smith Chart

```@example pgf
 # Samples for 100 MHz to 10 GHz
frequency = range(100e6,stop=10e9,length=10)
L = 1e-9 # 1 nH
R = 25   # 25 Ω
Z0 = 50  # 50 Ω Reference
# Series network of R + jωL, normalized
network = @. (R + 1.0im*2*pi*frequency*L) / Z0
SmithChart(Plot(Coordinates([(real(z),imag(z)) for z in network])))
savefigs("smith", ans) # hide
```

[\[.pdf\]](smith.pdf), [\[generated .tex\]](smith.tex)

![](smith.svg)

## Ternary axis

```@example pgf
@pgf TernaryAxis(
    {
        axis_on_top,
        xlabel="x", ylabel="y", zlabel="z",
        colorbar
    },
    Plot3(
        {
            patch,
            shader="interp",
            point_meta="\\thisrow{C}"
        },
        Table(["x" => [0, 1, 0.5, 0.5, 0, 0],
               "y" => [0, 0, 0.5, 0.5, 1, 0],
               "z" => [1, 0, 0, 0, 0, 1],
               "C" => [100, 0, 0, 0, 20, 100]])
    )
)
savefigs("ternary", ans) # hide
```

[\[.pdf\]](ternary.pdf), [\[generated .tex\]](ternary.tex)

![](ternary.svg)

# Legend independently of axes

The following example shows how to construct multiple plots using the same styles, then display the legend separately.

First, define some common styles we reuse.
```@example pgf
using Colors, PGFPlotsX
x = range(-π, π; length = 100)
styles = map(color -> @pgf({ color = color, thick, no_marks }), [colorant"#faab36", colorant"#249ea0"])
```

Then make use of them to create a plot.
```@example pgf
function _make_axis(x, fs, styles, ylabel)
    axis = @pgf Axis({ xlabel = "x", ylabel = ylabel })
    for (f, style) in zip(fs, styles)
        @pgf push!(axis, Plot(style, Table(x, f.(x))))
    end
    axis
end
@pgf GroupPlot(
    {
        group_style =
            {
                group_size="2 by 1",
                xticklabels_at="edge bottom",
                yticklabels_at="edge left"
            },
    },
    _make_axis(x, [sin, cos], styles, "functions"),
    _make_axis(x, [cos, x -> -sin(x)], styles, "derivatives"),
)
savefigs("style-reuse-plots", ans) # hide
```

[\[.pdf\]](style-reuse-plots.pdf), [\[generated .tex\]](style-reuse-plots.tex)

![](style-reuse-plots.svg)

Then we construct the legend.
```@example pgf
axis = @pgf Axis({ hide_axis, xmin = 0, xmax = 5, ymin = 0, ymax = 1, # magnitudes don't matter
                   legend_style={ draw="white!15!black", "legend cell align=left"}});
for (style, label) in zip(styles, ["sin", "cos"])
    push!(axis, LegendImage(style), LegendEntry(label))
end
axis
savefigs("style-reuse-legend", ans) # hide
```

[\[.pdf\]](style-reuse-legend.pdf), [\[generated .tex\]](style-reuse-legend.tex)

![](style-reuse-legend.svg)
