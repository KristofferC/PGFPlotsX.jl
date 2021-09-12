# Convenience constructs

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdftocairo -svg -l  1 $(figname * ".pdf") $(figname * ".svg")`)
    pgfsave(figname * ".tex", obj);
    return nothing
end
```

## Horizontal and vertical lines

```@example pgf
x = range(3.01; stop = 6, length = 100)
y = @. 1/(x-3) + 3
@pgf Axis(
    {
        ymin = 2.5,
        ymax = 6,
        xmin = 2.5
    },
    Plot(
        {
            no_marks
        },
        Table(x, y)
    ),
    HLine({ dashed, blue }, 3),
    VLine({ dotted, red }, 3)
)
savefigs("hvline", ans) # hide
```

[\[.pdf\]](hvline.pdf), [\[generated .tex\]](hvline.tex)

![](hvline.svg)

## Horizontal and vertical bands

```@example pgf
x = range(3.01; stop = 6, length = 100)
y = @. 1/(x-3) + 3
@pgf Axis(
    {
        ymin = 2.5,
        ymax = 6,
        xmin = 2.5,
        xmax = 6
    },
    HBand({ draw="none", fill="blue", opacity = 0.5 }, 3, 4),
    VBand({ draw="none", fill="red", opacity = 0.5}, 3, 4),
    Plot(
        {
            no_marks
        },
        Table(x, y)
    )
)
savefigs("hvband", ans) # hide
```

[\[.pdf\]](hvband.pdf), [\[generated .tex\]](hvband.tex)

![](hvband.svg)
