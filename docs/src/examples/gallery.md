# PGFPlots manual gallery

Examples converted from [the PGFPlots manual gallery](http://pgfplots.sourceforge.net/gallery.html).
This is a work in progress. All the examples are run with the following code added to them.

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

------------------------


```@example pgf
pgf.@pgf pgf.Axis(
    {
        xlabel = "Cost",
        ylabel = "Error",
    },
    pgf.Plot(
        {
            color = "red",
            mark  = "x"
        },
        pgf.Coordinates(
            [
                (2, -2.8559703),
                (3, -3.5301677),
                (4, -4.3050655),
                (5, -5.1413136),
                (6, -6.0322865),
                (7, -6.9675052),
                (8, -7.9377747),
            ]
        ),
    ),
)
savefigs("cost-error", ans) # hide
```

[\[.pdf\]](cost-error.pdf), [\[generated .tex\]](cost-error.tex)

![](cost-error.svg)

------------------------

```@example pgf
pgf.@pgf pgf.Axis(
    {
        xlabel = L"x",
        ylabel = L"f(x) = x^2 - x + 4"
    },
    pgf.Plot(
        pgf.Expression("x^2 - x + 4")
    )
)
savefigs("simple-expression", ans) # hide
```

[\[.pdf\]](simple-expression.pdf), [\[generated .tex\]](simple-expression.tex)

![](simple-expression.svg)

------------------------

```@example pgf
pgf.@pgf pgf.Axis(
    {
        height = "9cm",
        width = "9cm",
        grid = "major",
    },
    [
        pgf.Plot(pgf.Expression("-x^5 - 242"); label = "model")
        pgf.Plot(pgf.Coordinates(
            [
                (-4.77778,2027.60977),
                (-3.55556,347.84069),
                (-2.33333,22.58953),
                (-1.11111,-493.50066),
                (0.11111,46.66082),
                (1.33333,-205.56286),
                (2.55556,-341.40638),
                (3.77778,-1169.24780),
                (5.00000,-3269.56775),
            ];
        ); label = "estimate")
    ]
)
savefigs("cost-gain", ans) # hide
```

[\[.pdf\]](cost-gain.pdf), [\[generated .tex\]](cost-gain.tex)

![](cost-gain.svg)

------------------------

```@example pgf
pgf.@pgf pgf.Axis(
    {
        xlabel = "Cost",
        ylabel = "Gain",
        xmode = "log",
        ymode = "log",
    },
    pgf.Plot(
        {
            color = "red",
            mark  = "x"
        },
        pgf.Coordinates(
            [
                (10, 100),
                (20, 150),
                (40, 225),
                (80, 340),
                (160, 510),
                (320, 765),
                (640, 1150),
            ]
        )
    )
)
savefigs("cost-gain-log-log", ans) # hide
```

[\[.pdf\]](cost-gain-log-log.pdf), [\[generated .tex\]](cost-gain-log-log.tex)

![](cost-gain-log-log.svg)

------------------------

```@example pgf
pgf.@pgf pgf.Axis(
    {
        xlabel = "Cost",
        ylabel = "Gain",
        ymode = "log",
    },
    pgf.Plot(
        {
            color = "blue",
            mark  = "*"
        },
        pgf.Coordinates(
            [
                (1, 8)
                (2, 16)
                (3, 32)
                (4, 64)
                (5, 128)
                (6, 256)
                (7, 512)
            ]
        )
    )
)
savefigs("cost-gain-ylog", ans) # hide
```

[\[.pdf\]](cost-gain-ylog.pdf), [\[generated .tex\]](cost-gain-ylog.tex)

![](cost-gain-ylog.svg)


------------------------

```@example pgf
pgf.@pgf pgf.Axis(
    {
        xlabel = "Degrees of freedom",
        ylabel = L"$L_2$ Error",
        xmode  = "log",
        ymode  = "log",
    },
    [
        pgf.Plot(pgf.Coordinates(
            [(   5, 8.312e-02), (  17, 2.547e-02), (  49, 7.407e-03),
             ( 129, 2.102e-03), ( 321, 5.874e-04), ( 769, 1.623e-04),
             (1793, 4.442e-05), (4097, 1.207e-05), (9217, 3.261e-06),]
        )),

        pgf.Plot(pgf.Coordinates(
            [(   7, 8.472e-02), (   31, 3.044e-02), (111,   1.022e-02),
             ( 351, 3.303e-03), ( 1023, 1.039e-03), (2815,  3.196e-04),
             (7423, 9.658e-05), (18943, 2.873e-05), (47103, 8.437e-06),]
        )),

        pgf.Plot(pgf.Coordinates(
            [(    9, 7.881e-02), (   49, 3.243e-02), (   209, 1.232e-02),
             (  769, 4.454e-03), ( 2561, 1.551e-03), (  7937, 5.236e-04),
             (23297, 1.723e-04), (65537, 5.545e-05), (178177, 1.751e-05),]
        )),

        pgf.Plot(pgf.Coordinates(
            [(   11, 6.887e-02), (    71, 3.177e-02), (   351, 1.341e-02),
             ( 1471, 5.334e-03), (  5503, 2.027e-03), ( 18943, 7.415e-04),
             (61183, 2.628e-04), (187903, 9.063e-05), (553983, 3.053e-05),]
        )),

        pgf.Plot(pgf.Coordinates(
            [(    13, 5.755e-02), (    97, 2.925e-02), (    545, 1.351e-02),
             (  2561, 5.842e-03), ( 10625, 2.397e-03), (  40193, 9.414e-04),
             (141569, 3.564e-04), (471041, 1.308e-04), (1496065, 4.670e-05),]
        )),
    ]
)
savefigs("dof-error", ans) # hide
```

[\[.pdf\]](dof-error.pdf), [\[generated .tex\]](dof-error.tex)

![](dof-error.svg)

------------------------

```@example pgf
pgf.@pgf pgf.Axis(
    {
        "scatter/classes" = {
            a = {mark = "square*", "blue"},
            b = {mark = "triangle*", "red"},
            c = {mark = "o", draw = "black"},
        }
    },
    pgf.Plot(
        {
            scatter,
            "only marks",
            "scatter src" = "explicit symbolic",
        },
        pgf.Table(
            {
                meta = "label"
            },
            x = [0.1, 0.45, 0.02, 0.06, 0.9 , 0.5 , 0.85, 0.12, 0.73, 0.53, 0.76, 0.55],
            y = [0.15, 0.27, 0.17, 0.1, 0.5, 0.3, 0.52, 0.05, 0.45, 0.25, 0.5, 0.32],
            label = ["a", "c", "a", "a", "b", "c", "b", "a", "b", "c", "b", "c"],
        )
    )
)
savefigs("table-label", ans) # hide
```

[\[.pdf\]](table-label.pdf), [\[generated .tex\]](table-label.tex)

![](table-label.svg)

------------------------

```@example pgf
pgf.@pgf pgf.Axis(
    {
        "nodes near coords" = raw"(\coordindex)",
        title = raw"\texttt{patch type=quadratic spline}",
    },
    pgf.Plot(
        {
            mark = "*",
            patch,
            mesh, # without mesh, pgfplots tries to fill,
            # "patch type" = "quadratic spline", <- Should work??
        },
        pgf.Coordinates(
            [
                # left, right, middle-> first segment
                (0, 0),   (1, 1),   (0.5, 0.5^2),
                # left, right, middle-> second segment
                (1.2, 1), (2.2, 1), (1.7, 2),
            ]
        )
    )
)
savefigs("spline-quadratic", ans) # hide
```

[\[.pdf\]](spline-quadratic.pdf), [\[generated .tex\]](spline-quadratic.tex)

![](spline-quadratic.svg)

------------------------

```@example pgf
pgf.@pgf pgf.Plot3(
    {
        mesh,
        scatter,
        samples = 10,
        domain = 0:1
    },
    pgf.Expression("x * (1-x) * y * (1-y)")
)
savefigs("mesh-scatter", ans) # hide
```

[\[.pdf\]](mesh-scatter.pdf), [\[generated .tex\]](mesh-scatter.tex)

![](mesh-scatter.svg)

