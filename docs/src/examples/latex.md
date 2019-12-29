# [Using LaTeX code](@id latex-code)

PGFPlotsX has does not specify types for all LaTeX constructs. This is not a limitation, as you can just provide LaTeX code as strings, which are emitted directly. They can be freely mixed with other types, which are converted to LaTeX with [`print_tex`](@ref). Since elements of `AbstractVector`s are printed in turn, this allows for a compact style.

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdftocairo -svg -l 1 $(figname * ".pdf") $(figname * ".svg")`)
    pgfsave(figname * ".tex", obj);
    return nothing
end
```

## Annotating plots

The example below demonstrates the use of `\node`. Note the following:

- we use the `raw` string literal, which ensures that we don't need to escape the `\`; `"\\node"` would work identically

- the options (with `{}`, also containing a color) and coordinates we mix in just work as they should,

- we provide separating whitespace, and the terminating `;`.

```@example pgf
using Colors
x = vcat(randn(10) ./ 4, 2.0)
y = vcat(randn(10) ./ 4, 1.0)
@pgf Axis(
    {
        only_marks,
        xlabel = "x",
        ylabel = "y"
    },
    Plot(Table(x, y)),
    [raw"\node ",
     {
         draw = parse(Colorant, "tomato3"),
         pin = "180:outlier"
     },
     " at ",
     Coordinate(x[end], y[end]),
     "{};"])
savefigs("annotated-node", ans) # hide
```

[\[.pdf\]](annotated-node.pdf), [\[generated .tex\]](annotated-node.tex)

![](annotated-node.svg)

## [LaTeX code for plot elements](@id latex-plot-elements)

The example below demonstrates how strings can be included as “data” for `Plot`. Specifically, here we name two paths, then use `fill between [of=f and g]` to fill the space between them. This requires the use of the `fillbetween` library for PGFPlots, which we insert in the premable.

```@example pgf
push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\usepgfplotslibrary{fillbetween}")
x = range(-1, 1, length = 51)
@pgf Axis({ xmajorgrids, ymajorgrids },
          Plot({ "name path=f", no_marks, }, Coordinates(x, x)),
          Plot({ "name path=g", no_marks, }, Coordinates(x, 1.2 .* x .+ 1)),
          Plot({ thick, color = "blue", fill = "blue", opacity = 0.5 },
               raw"fill between [of=f and g]"))
savefigs("fillbetween", ans) # hide
```

[\[.pdf\]](fillbetween.pdf), [\[generated .tex\]](fillbetween.tex)

![](fillbetween.svg)
