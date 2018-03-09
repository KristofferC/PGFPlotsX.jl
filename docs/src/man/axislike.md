# [`Axis` & friends](@id axislike)

```@meta
DocTestSetup = quote
    using PGFPlotsX
end
```

This section documents constructs which are similar to `Axis`. In addition to [options](@ref Options), they accept all [axis elements](@ref Axis elements).

### `Axis`

```@doc
Axis
```

`Axis` make up the labels and titles etc in the figure and is the standard way of wrapping plots, represented in `TeX` as

```tex
\begin{axis} [...]
    ...
\end{axis}
```

Examples:

```jldoctest
julia> @pgf a = Axis({
              xlabel = "x"
              ylabel = "y"
              title = "Figure"
          },
          PlotInc( Expression("x^2")));

julia> print_tex(a)
\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]
    \addplot+[]
        {x^2};
\end{axis}

julia> push!(a, PlotInc(Coordinates([1, 2], [3, 4])));


julia> print_tex(a)
\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]
    \addplot+[]
        {x^2};
    \addplot+[]
        coordinates {
            (1, 3)
            (2, 4)
        }
        ;
\end{axis}
```

Any struct can be pushed in to an `Axis`. What will be printed is the result of `PGFPlotsX.print_tex(io::IO, t::T, ::Axis)` where `T` is the type of the struct.
Pushed strings are written out verbatim.

### `GroupPlot`

```@docs
GroupPlot
```

A `GroupPlot` is a way of grouping multiple plots in one figure.

Example:

```jldoctest
julia> @pgf gp = GroupPlot({group_style = { group_size = "2 by 1",}, height = "6cm", width = "6cm"});

julia> for (expr, data) in zip(["x^2", "exp(x)"], ["data1.dat", "data2.dat"])
           push!(gp, Plot(Expression(expr)),  Plot(Table(data)))
       end;

julia> print_tex(gp)
\begin{groupplot}[group style={group size={2 by 1}}, height={6cm}, width={6cm}]
    \addplot[]
        {x^2};
    \addplot[]
        table[]
        {
            data1.dat
        }
        ;
    \addplot[]
        {exp(x)};
    \addplot[]
        table[]
        {
            data2.dat
        }
        ;
\end{groupplot}
```

In order to add options to the `\nextgroupplot` call simply add arguments in
an "option like way" (using strings / pairs / `@pgf`) when you `push!`

```jldoctest
julia> @pgf gp = GroupPlot({group_style = { group_size = "1 by 1",}, height = "6cm", width = "6cm"});

julia> @pgf for (expr, data) in zip(["x^2"], ["data2.dat"])
           push!(gp, {title = "Data $data"}, Plot(Expression(expr)),  Plot(Table(data)))
       end;

julia> print_tex(gp)
\begin{groupplot}[group style={group size={1 by 1}}, height={6cm}, width={6cm}]
    \nextgroupplot[title={Data data2.dat}]
    \addplot[]
        {x^2};
    \addplot[]
        table[]
        {
            data2.dat
        }
        ;
\end{groupplot}
```

### `PolarAxis`

A `PolarAxis` plot data on a polar grid.

Example:

```jldoctest
julia> p = PolarAxis( PlotInc( Coordinates([0, 90, 180, 270], [1, 1, 1, 1])));

julia> print_tex(p)
\begin{polaraxis}[]
    \addplot+[]
        coordinates {
            (0, 1)
            (90, 1)
            (180, 1)
            (270, 1)
        }
        ;
\end{polaraxis}
```

### Semilog and log axes

```@docs
SemiLogXAxis
SemiLogYAxis
LogLogAxis
```
