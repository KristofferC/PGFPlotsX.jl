# Data

```@meta
DocTestSetup = quote
    using PGFPlotsX
end
```

There are multiple ways of representing data in PGFPlots.

## [Table and TableData](@id table_header)

A `Table` represents a matrix of data where each column is labeled. It can simply point to an external data file or store the data inline in the `tex` file. `Table`s can have options.

`TableData` is the representation of *just the data*, without the `table[options]` part. It is useful for inline tables in specials cases. Also, calls to `Table` use `TableData` to convert the arguments, so if you want to learn about all the ways to construct a `Table`, see the methods of [`TableData`](@ref).

```@docs
Table
TableData
```

Examples:

```julia-repl make_into_doctest
julia> t = @pgf Table({x = "Dof"}, "data.dat");

julia> print_tex(t)
table [x={Dof}] {
    <ABSPATH>/data.dat
}
```

Inline data is constructed using a keyword constructor:

```jldoctest
julia> t = @pgf Table({x => "Dof", y => "Err"},
                      [:Dof => [1, 2, 4], :Err => [2.0, 1.0, 0.1]]);

julia> print_tex(t)
table[x={Dof}, y={Err}]
{
    Dof  Err
    1.0  2.0
    2.0  1.0
    4.0  0.1
}
```

If you load the DataFrames package, you can also create tables from data frames, see the examples in [Julia types](@ref).

## [Coordinates](@id coordinates_header)

Coordinates are a list of points `(x,y)` or `(x,y,z)`. They can be created as:

* `Coordinates(x, y, [z])` where `x` and `y` (and optionally `z`) are lists.

* `Coordinates(points)` where `points` is a list of tuples, e.g. `x = [(1.0, 2.0), (2.0, 4.0)]`.

Errors can be added to `Coordinates` with keywords.

```@docs
Coordinates
```

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

## Expression

```@docs
Expression
```

Example:

```jldoctest
julia> ex = Expression("exp(-x^2)");

julia> print_tex(ex)
{exp(-x^2)}
```

## Graphics

```@docs
Graphics
```

Example:

```jldoctest
julia> print_tex(Graphics("img.png"))
graphics[] {img.png}
```
