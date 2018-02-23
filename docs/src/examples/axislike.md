# Axis-like objects

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
x = linspace(0, 2*pi, 100)
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
