# Axis-like objects

## Simple group plot

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`)
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

## Using `Axis` in group plots

Alternatively, you can use `Axis` to group together options and a set of plots. This makes it easier to combine existing plots into a grouped plot.

```@example pgf
x = range(0; stop =2*pi, length = 100)
axs1 = @pgf Axis({ xlabel = raw"$\alpha$", ylabel = "sin" },
                 PlotInc(Table(x, sin.(x))),
                 PlotInc(Table(x, sin.(x .+ 0.5))));
axs2 = @pgf Axis({ xlabel = raw"$\beta$", ylabel = "cos" },
                  PlotInc(Table(x, cos.(x))),
                  PlotInc(Table(x, cos.(x .+ 0.5))));
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
    axs1, axs2)
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
