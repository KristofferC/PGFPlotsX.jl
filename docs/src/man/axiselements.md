# Axis elements

This section describes objects which can be elements of an [`Axis`-like object](@ref axislike).

```@meta
DocTestSetup = quote
    using PGFPlotsX
end
```

The following types are accepted as elements of `Axis` & friends.

## [Plots](@id plotlike)

A plot is an element inside an axis. It could be a simple line or a 3D surface etc. A plot is created by wrapping one of the structs shown above.

### `Plot` and `PlotInc`

For `\addplot` and `\addplot+`.

```@docs
Plot
PlotInc
```

Example:

```jldoctest
julia> p = @pgf PlotInc({ blue }, Table("plotdata/invcum.dat"));

julia> print_tex(p)
\addplot+[blue]
    table[]
    {
        plotdata/invcum.dat
    }
    ;
```

### `Plot3`

`Plot3` will use the `\addplot3` command instead of `\addplot` to draw 3D graphics.
Otherwise it works the same as `Plot`. The incremental variant is `Plot3Inc`.

```@docs
Plot3
Plot3Inc
```

Example:

```jldoctest
julia> x, y, z = [1, 2, 3], [2, 4, 8], [3, 9, 27];

julia> p = @pgf Plot3({ very_thick }, Coordinates(x, y, z));

julia> print_tex(p)
\addplot3[very thick]
    coordinates {
        (1, 2, 3)
        (2, 4, 9)
        (3, 8, 27)
    }
    ;
```

## Legends

```@docs
Legend
LegendEntry
```

A `Legend` can be used to add legends to plots.

Example:

```jldoctest
julia> print_tex(Legend(["Plot A", "Plot B"]))
\legend{Plot A, Plot B}
```

## Using LaTeX code directly

In case there is no type defined in this package for some construct, you can use a `String` in an axis, and it will be printed as is. [Raw string literals](https://docs.julialang.org/en/latest/manual/strings/#man-raw-string-literals-1) and the package [LaTeXStrings](https://github.com/stevengj/LaTeXStrings.jl) are useful to avoid a lot of escaping.
