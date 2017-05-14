# Building up figures

This section presents the structs used in PGFPlotsX to build up figures. An `X` after the struct name means that it supports option as described in

## Data

There are multiple ways of representing data in PGFPlots:

### `Coordinates`

Coordinates a are a list of points `(x,y)` or `(x,y,z)`. They can be created as:

* `Coordinates(x, y, [z])` where `x` and `y` (and optionally `z`) are lists.

* `Coordinates(x, f2)` or `Coordinates(x, y, f3)` where `x` and `y` are lists and `f2`, `f3` are functions taking one and two arguments respectively.
* `Coordinates(points)` where `points` is a list of tuples, e.g. `x = [(1.0, 2.0), (2.0, 4.0)]`.

For two dimensional coordinates, errors can be added to `Coordinates` with the keywords:

    * `xerror`, `yerror` for symmetric errors
    * `xerrorplus` `yerrorplus` for positive errors
    * `xerrorminus` `yerrorminus` for positive errors

Examples:

```jldoctest    
julia> x = [1, 2, 3]; y = [2, 4, 8]; z = [-1, -2, -3];

julia> pgf.print_tex(pgf.Coordinates(x, y))
    coordinates {
    (1, 2)
    (2, 4)
    (3, 8)
    }

julia> pgf.print_tex(pgf.Coordinates(x, y, z))
    coordinates {
    (1, 2, -1)
    (2, 4, -2)
    (3, 8, -3)
    }

julia> pgf.print_tex(pgf.Coordinates(x, x -> x^3))

    coordinates {
    (1, 1)
    (2, 8)
    (3, 27)
    }

julia> pgf.print_tex(pgf.Coordinates([(1.0, 2.0), (2.0, 4.0)]))
    coordinates {
    (1.0, 2.0)
    (2.0, 4.0)
    }

julia> c = pgf.Coordinates(x, y, xerror = [0.2, 0.3, 0.5], yerror = [0.2, 0.1, 0.5]);

julia> pgf.print_tex(c)
    coordinates {
    (1, 2)+-(0.2, 0.2)
    (2, 4)+-(0.3, 0.1)
    (3, 8)+-(0.5, 0.5)
    }
```


### `Expression`

An `Expression` is a string, representing a function and is written in a way LaTeX understands.

Example:

```jldoctest
julia> ex = pgf.Expression("exp(-x^2)");

julia> pgf.print_tex(ex)
    {exp(-x^2)}
```

### `Table` - `X`

A table represents a matrix of data where each column is labeled. It can simply point to an external data file or store the data inline in the .tex file.

Examples:

```jldoctest
julia> t = pgf.Table("data.dat", "x" => "Dof");

julia> pgf.print_tex(t)
    table [x={Dof}]
    {data.dat}
```

Inline data is constructed using a keyword constructor:

```jldoctest
julia> t = pgf.Table("x" => "Dof", "y" => "Err"; Dof = rand(3), Err = rand(3));

julia> pgf.print_tex(t)
    table [x={Dof}, y={Err}]
    {Dof    Err    
    0.6073590230719768    0.36281513247882136    
    0.7285438246638971    0.11629575623266741    
    0.29590973933842424    0.9782972101143201    
    }
```

If you load the DataFrames package, you can also create tables from data frames, see the TODO


### Graphics - `X`

`Graphics` data simply wraps an image like a .png. It is constructed as `Graphics(filepath)` where `filepath` is the path to the image.

Example:

```juliadoctest
julia> pgf.print_tex(pgf.Graphics("img.png"))
    graphics []
    {img.png}
```

## Plots

A plot is an element inside an axis. It could be a simple line or a 3d surface etc. A plot is created by wrapping one of the structs shown above.

### `Plot` - `X`

A keyword argument `incremental::Bool` is used to determine if `\addplot+` (default) should be used or `\addplot`.

Example:

```jldoctest
julia> p = pgf.@pgf pgf.Plot(pgf.Table("plotdata/invcum.dat"), { blue }; incremental = false);

julia> pgf.print_tex(p)
    \addplot[blue]
        table []
        {plotdata/invcum.dat}
    ;
```

### `Plot3` - `X`

`Plot3` will use the `\addplot3` command instead of `\addplot` to draw 3d graphics.
Otherwise it works the same as `Plot`.

Example:

```jldoctest
julia> x, y, z = rand(3), rand(3), rand(3);

julia> p = pgf.@pgf pgf.Plot3(pgf.Coordinates(x,y,z), { very_thick });

julia> pgf.print_tex(p)
    \addplot3+[very thick]
        coordinates {
        (0.7399041050338018, 0.4333342656950161, 0.31102760595379864)
        (0.8533903392895954, 0.4437618168514108, 0.05325494618659876)
        (0.4871968750637172, 0.09021596022672318, 0.817385325577578)
        }
    ;
```

## Axis-like

### `Axis`

`Axis` make up the labels and titles etc in the figure and is the standard way of wrapping plots, represented in tex as

```tex
\begin{axis}[...]
    ...
\end{axis}
```

Examples:

```jldoctest
julia> pgf.@pgf a = pgf.Axis( pgf.Plot( pgf.Expression("x^2")), {
              xlabel = "x"
              ylabel = "y"
              title = "Figure"
          });

julia> pgf.print_tex(a)
    \begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]
        \addplot+[]
            {x^2}
        ;
    \end{axis}

julia> push!(a, pgf.Plot( pgf.Table("data.dat")));

julia> pgf.print_tex(a)
    \begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]
        \addplot+[]
            {x^2}
        ;
        \addplot+[]
            table []
            {data.dat}
        ;
    \end{axis}
```

Any struct can be pushed in to an `Axis`. What will be printed is the result of `PGFPlotsX.print_tex(io::IO, t::T, ::Axis)` where `T` is the type of the struct.
Pushed strings are written out verbatim.

### `GroupPlot`

A `GroupPlot` is a way of grouping multiple plots in one figure.

Example:

```jldoctest
julia> pgf.@pgf gp = pgf.GroupPlot({group_style = { group_size = "2 by 1",}, height = "6cm", width = "6cm"});

julia> for (expr, data) in zip(["x^2", "exp(x)"], ["data1.dat", "data2.dat"])
           push!(gp, [pgf.Plot(pgf.Expression(expr)),  pgf.Plot(pgf.Table(data))])
       end

julia> pgf.print_tex(gp)
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

```jldoctest
julia> pgf.@pgf gp = pgf.GroupPlot({group_style = { group_size = "1 by 1",}, height = "6cm", width = "6cm"});

julia> pgf.@pgf for (expr, data) in zip(["x^2"], ["data2.dat"])
           push!(gp, [pgf.Plot(pgf.Expression(expr)),  pgf.Plot(pgf.Table(data))], {title = "Data $data"})
       end;

julia> pgf.print_tex(gp)
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

## `TikzPicture`

A `TikzPicture` can contain multiple `Axis`'s or `GroupPlot`'s.

Example:

```jldoctest
julia> tp = pgf.TikzPicture( pgf.Axis( pgf.Plot( pgf.Coordinates(rand(5), rand(5)))), "scale" => 1.5);

julia> pgf.print_tex(tp)
\begin{tikzpicture}[scale={1.5}]
    \begin{axis}[]
        \addplot+[]
            coordinates {
            (0.019179024805588307, 0.2501519456458139)
            (0.05113231216989789, 0.9221777779905538)
            (0.5648080180343429, 0.9586784922834994)
            (0.5248828812399753, 0.8642592693396507)
            (0.02943482346303017, 0.7327568460567329)
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
julia> td = pgf.TikzDocument();

julia> push!(td, "Hello World");

julia> save("hello.pdf", td);
```

!!! note

    There is usually no need to explicitly create a `TikzDocument` or `TikzPicture`.
    Only do this if you want to give special options to them. It is possible to show or save
    an `Axis` or e.g. a `Plot` directly, and they will then be wrapped in the default "higher level" objects.
