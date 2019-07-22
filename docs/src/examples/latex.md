# [Using LaTeX code](@id latex-code)

PGFPlotsX has does not specify types for all LaTeX constructs. This is not a limitation, as you can just provide LaTeX code as strings, which are emitted directly. They can be freely mixed with other types, which are converted to LaTeX with [`print_tex`](@ref). Since elements of `AbstractVector`s are printed in turn, this allows for a compact style.

```@setup pgf
using PGFPlotsX
savefigs = (figname, obj) -> begin
    pgfsave(figname * ".pdf", obj)
    run(`pdf2svg $(figname * ".pdf") $(figname * ".svg")`)
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
