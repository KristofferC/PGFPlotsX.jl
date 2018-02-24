# Building up figures

```@meta
DocTestSetup = quote
    using PGFPlotsX
end
```

This section presents the structs used in PGFPlotsX to build up figures. An `X` after the struct name means that it supports option as described in the section on defining options.

## Data

There are multiple ways of representing data in PGFPlots:

### `Coordinates`

Coordinates a are a list of points `(x,y)` or `(x,y,z)`. They can be created as:

* `Coordinates(x, y, [z])` where `x` and `y` (and optionally `z`) are lists.

* `Coordinates(points)` where `points` is a list of tuples, e.g. `x = [(1.0, 2.0), (2.0, 4.0)]`.

For two-dimensional coordinates, errors can be added to `Coordinates` with the keywords:

    * `xerror`, `yerror` for symmetric errors
    * `xerrorplus` `yerrorplus` for positive errors
    * `xerrorminus` `yerrorminus` for positive errors

Examples:

```jldoctest
julia> x = [1, 2, 3]; y = [2, 4, 8]; z = [-1, -2, -3];

julia> print_tex(Coordinates(x, y))
    coordinates {
    (1, 2)
    (2, 4)
    (3, 8)
    }

julia> print_tex(Coordinates(x, y, z))
    coordinates {
    (1, 2, -1)
    (2, 4, -2)
    (3, 8, -3)
    }

julia> print_tex(Coordinates(x, x.^3))

    coordinates {
    (1, 1)
    (2, 8)
    (3, 27)
    }

julia> print_tex(Coordinates([(1.0, 2.0), (2.0, 4.0)]))
    coordinates {
    (1.0, 2.0)
    (2.0, 4.0)
    }

julia> c = Coordinates(x, y, xerror = [0.2, 0.3, 0.5], yerror = [0.2, 0.1, 0.5]);

julia> print_tex(c)
    coordinates {
    (1, 2) +- (0.2, 0.2)
    (2, 4) +- (0.3, 0.1)
    (3, 8) +- (0.5, 0.5)
    }
```

### `Expression`

An `Expression` is a string, representing a function and is written in a way LaTeX understands.

Example:

```jldoctest
julia> ex = Expression("exp(-x^2)");

julia> print_tex(ex)
    {exp(-x^2)}
```

### `Table` - `X`

A table represents a matrix of data where each column is labeled. It can simply point to an external data file or store the data inline in the .tex file.

Examples:

```julia-repl make_into_doctest
julia> t = @pgf Table({x = "Dof"}, "data.dat");

julia> print_tex(t)
    table [x={Dof}]
    {<ABSPATH>/data.dat}
```

Inline data is constructed using a keyword constructor:

```jldoctest
julia> t = @pgf Table({x => "Dof", y => "Err"}, [:Dof => [1, 2, 4], :Err => [2.0, 1.0, 0.1]]);

julia> print_tex(t)
    table [x={Dof}, y={Err}]
    {Dof  Err
    1.0  2.0
    2.0  1.0
    4.0  0.1
    }
```

If you load the DataFrames package, you can also create tables from data frames, see the examples in [Julia types](@ref).

### Graphics - `X`

`Graphics` data simply wraps an image like a .png. It is constructed as `Graphics(filepath)` where `filepath` is the path to the image.

Example:

```jldoctest
julia> print_tex(Graphics("img.png"))
    graphics []
    {img.png}
```

## Plots

A plot is an element inside an axis. It could be a simple line or a 3d surface etc. A plot is created by wrapping one of the structs shown above.

### `Plot` - `X`

A keyword argument `incremental::Bool` is used to determine if `\addplot+` (default) should be used or `\addplot`.

Example:

```julia-repl make_into_doctest
julia> p = @pgf Plot(Table("plotdata/invcum.dat"), { blue }; incremental = false);

julia> print_tex(p)
    \addplot [blue]
        table []
        {<ABSPATH>/plotdata/invcum.dat}
    ;
```

### `Plot3` - `X`

`Plot3` will use the `\addplot3` command instead of `\addplot` to draw 3d graphics.
Otherwise it works the same as `Plot`.

Example:

```jldoctest
julia> x, y, z = [1, 2, 3], [2, 4, 8], [3, 9, 27];

julia> p = @pgf Plot3({ very_thick }, Coordinates(x, y, z));

julia> print_tex(p)
    \addplot3 [very thick]
        coordinates {
        (1, 2, 3)
        (2, 4, 9)
        (3, 8, 27)
        }
    ;
```

## Axis-like

### `Axis` - `X`

`Axis` make up the labels and titles etc in the figure and is the standard way of wrapping plots, represented in tex as

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
    \begin{axis} [xlabel={x}, ylabel={y}, title={Figure}]
        \addplot+ []
            {x^2}
        ;
    \end{axis}

julia> push!(a, PlotInc(Coordinates([1, 2], [3, 4])));


julia> print_tex(a)
    \begin{axis} [xlabel={x}, ylabel={y}, title={Figure}]
        \addplot+ []
            {x^2}
        ;
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

### `GroupPlot` - `X`

A `GroupPlot` is a way of grouping multiple plots in one figure.

Example:

```julia-repl make_into_doctest
julia> @pgf gp = GroupPlot({group_style = { group_size = "2 by 1",}, height = "6cm", width = "6cm"});

julia> for (expr, data) in zip(["x^2", "exp(x)"], ["data1.dat", "data2.dat"])
           push!(gp, [Plot(Expression(expr)),  Plot(Table(data))])
       end;

julia> print_tex(gp)
    \begin{groupplot}[group style={group size={2 by 1}}, height={6cm}, width={6cm}]
        \nextgroupplot[]

        \addplot+[]
            {x^2}
        ;
        \addplot+[]
            table []
            {data1.dat}
        ;
        \nextgroupplot[]

        \addplot+[]
            {exp(x)}
        ;
        \addplot+[]
            table []
            {data2.dat}
        ;
    \end{groupplot}
```

In order to add options to the `\nextgroupplot` call simply add arguments in
an "option like way" (using strings / pairs / `@pgf`) when you `push!`

```julia-repl make_into_doctest2
julia> @pgf gp = GroupPlot({group_style = { group_size = "1 by 1",}, height = "6cm", width = "6cm"});

julia> @pgf for (expr, data) in zip(["x^2"], ["data2.dat"])
           push!(gp, [Plot(Expression(expr)),  Plot(Table(data))], {title = "Data $data"})
       end;

julia> print_tex(gp)
    \begin{groupplot}[group style={group size={1 by 1}}, height={6cm}, width={6cm}]
        \nextgroupplot[title={Data data2.dat}]

        \addplot+[]
            {x^2}
        ;
        \addplot+[]
            table []
            {data2.dat}
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

### `Legend`

A `Legend` can be used to add legends to plots.

Example:

```jldoctest
julia> print_tex(Legend(["Plot A", "Plot B"]))
\legend{Plot A, Plot B}
```

## `TikzPicture` - `X`

A `TikzPicture` can contain multiple `Axis`'s or `GroupPlot`'s.

Example:

```jldoctest
julia> tp = @pgf TikzPicture({ "scale" => 1.5 }, Axis(Plot(Coordinates([1, 2], [2, 4]))));

julia> print_tex(tp)
\begin{tikzpicture}[scale={1.5}]
    \begin{axis}[]
        \addplot[]
            coordinates {
            (1, 2)
            (2, 4)
            }
        ;
    \end{axis}
\end{tikzpicture}
```

## `TikzDocument`

A `TikzDocument` is the highest level object and represents a whole .tex file.
It includes a list of objects that will sit between `\begin{document}` and `\end{document}`.

A very simple example where we simply create a `TikzDocument` with a string in is shown below.
Normally you would also push `Axis`'s that contain plots.

```julia-repl
julia> td = TikzDocument();

julia> push!(td, "Hello World");

julia> print_tex(td)
\RequirePackage{luatex85}
\documentclass[tikz]{standalone}
    % Default preamble
    \usepackage{pgfplots}
    \pgfplotsset{compat=newest}
    \usepgfplotslibrary{groupplots}
    \usepgfplotslibrary{polar}
    \usepgfplotslibrary{statistics}
\begin{document}
    Hello World

\end{document}
```

!!! note

    There is usually no need to explicitly create a `TikzDocument` or `TikzPicture`.
    Only do this if you want to give special options to them. It is possible to show or save
    an `Axis` or e.g. a `Plot` directly, and they will then be wrapped in the default "higher level" objects.
