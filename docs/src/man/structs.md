# Overview

```@meta
DocTestSetup = quote
    using PGFPlotsX
end
```

This package is a collection of functions and types which make it convenient to generate LaTeX output, which can in turn be compiled by `pgfplots` to produce vector or bitmap images like `.pdf`, `.svg` or `.png`, or used directly in LaTeX documents. `pgfplots` has a very detailed [manual](http://pgfplots.sourceforge.net/pgfplots.pdf) (a local copy should be available in TeXLive and MikTeX installations) *which should be your primary source of documentation*, and is not repeated here — it is assumed that you read the relevant parts of this manual, and look for solutions there first.

Instead, this manual describes a way to generate what LaTeX output conveniently from Julia, using the types introduced in this package, other packages, and Julia's built-in constructs. When working with this package, it is frequently convenient to examine the LaTeX representation of objects. [`print_tex`](@ref) is a method that prints what is written out when saving plots; we use it extensively in this manual for demonstrations, in practice one would use it for debugging.

As an example, consider the following trivial plot:
```tex
\begin{tikzpicture}[]
\begin{axis}
    \addplot+[only marks] table {
            x  y
            1  3
            2  4
        };
    \addplot+ table {
            x  y
            5  1
            6  2
        };
\end{axis}
\end{tikzpicture}
```
which can be produced by this package with the code
```julia
@pgf TikzPicture(
        Axis(
            PlotInc({ only_marks }
                Table(; x = 1:2, y = 3:4)),
            PlotInc(
                Table(; x = 5:6, y = 1:2))))
```
(The unconventional use linebreaks in Julia is for emphasizing the structural similarities between the two pieces of code).

The plot is built up from two `Table`s, which are tabular representations of data with (usually) named columns. These provide data for `Plot`s, here using the `PlotInc` constructor which corresponds to the `\addplot+` command: the `+` tells `pgfplots` to use a default style that varies with each plot. *Each plot can have a single source of data.*

[`Plot`](@ref)s are grouped together into an [`Axis`](@ref axislike), which corresponds to what most other libraries would call a “plot” (we use the term flexibly, too). Besides grouping plots, `Axis` allows the customization of ticks, labels, axis styles, legends, and related objects.

[`TikzPicture`](@ref) wraps the [`Axis`](@ref axislike). If you omit this, this package will do it for you automatically. Similarly, if you have a single `Plot`-like object and don't want to customize the `Axis`, it will also be added automatically.

Finally, [`@pgf`](@ref) is a convenient syntax for specifying [options](@ref options_header). It is is a macro that traverses its argument recursively, and converts it to a `PGFPlotsX.Options`. It is recommended that you use this macro. The convention of this library is to apply `@pgf` to whole expressions to avoid repetition, but this is not required.

PGFPlotsX allows building up plots from types that correspond very closely to `pgfplots` counterparts. The table below gives an overview of the types defined by this package. For most `pgfplots` constructs, `[]` can be used to specify options, this corresponds to the `[options]` argument in the table above.

| `pgfplots` (`[]` indicates options) | `PGFPlotsX`                                               | remark                                                      |
|-------------------------------------|-----------------------------------------------------------|-------------------------------------------------------------|
| `table[] { ... }`                   | [`Table([options], ...`)](@ref table_header)              | preferred to [`Coordinates`](@ref)                          |
| `coordinates { ... }`               | [`Coordinates(...)`](@ref coordinates_header)             | useful error bars                                           |
| `\addplot[] { ... }` & friends      | [`Plot([options], ...)` & friends](@ref plotlike)         | also [`PlotInc`](@ref), [`Plot3`](@ref), [`Plot3Inc`](@ref) |
| `\legend`, `\legendentry[]`         | [`Legend`](@ref), [`Legendentry([options])`](@ref Legend) |                                                             |
| `{expression}`                      | [`Expression(...)`](@ref Expression)                      | math formulas                                               |
| `graphics[] { ... }`                | [`Graphics([options], ...)`](@ref Graphics)               | bitmaps                                                     |
| `\axis[] { ... }` & friends         | [`Axis([options], ...)` & friends](@ref axislike)         | can have multiple `Plot`s & similar                         |
| `\begin{tikzpicture} ... `          | [`TikzPicture([options], ...)`](@ref TikzPicture)         | rarely used directly                                        |
| `\begin{document} ... `             | [`TikzDocument(...; ...)`](@ref TikzDocument)             | rarely used directly                                        |

The following sections document these.
