# Defining options

```@meta
DocTestSetup = quote
    using PGFPlotsX
end
```

In PGFPlots, options are given as a list of keys, that might have corresponding values,
inside of two square brackets e.g.

```tex
\begin{axis} [ybar, width = 4.5cm]
...
\end{axis}
```

This section shows the method for which to set and retrieve such options in Julia.

## Setting options when constructing an object

### As arguments to the constructor

When constructing an object (like a `Plot`), options to that object can be entered in the argument list
where a string represents a key without a value (e.g. `"very thick"`) and a pair represents a key/value option, (e.g. `"samples" => 50`).
This works well when the options are few and there is only one level of options in the object.

```jldoctest p1
julia> c = Coordinates([1, 2, 3], [2, 4, 8]);

julia> p = @pgf PlotInc({ "very thick", "mark" => "halfcircle" }, c);

julia> print_tex(p); # print_tex can be used to preview the generated .tex
\addplot+ [very thick, mark={halfcircle}]
        coordinates {
        (1, 2)
        (2, 4)
        (3, 8)
        }
    ;
```

### The `@pgf` macro

When there are nested options the previous method does not work so well.
Instead, we provide a macro `@pgf` so that options can be entered similarly to how they are in tex.

The previous example is then written as

```jldoctest p1
julia> @pgf Plot(
           {
               very_thick,
               mark = "halfcircle"
           },
           c);
```

A more complicated example is:

```jldoctest p1
julia> @pgf a = Axis(
           {
               "axis background/.style" =
               {
                   shade,
                   top_color = "gray",
                   bottom_color = "white",
               },
               ymode = "log"
           },
           PlotInc(c)
       );
```

which is printed as

```jldoctest p1
julia> print_tex(a)
    \begin{axis} [axis background/.style={shade, top color={gray}, bottom color={white}}, ymode={log}]
        \addplot+ []
            coordinates {
            (1, 2)
            (2, 4)
            (3, 8)
            }
        ;
    \end{axis}
```

The macro can be applied to any type of expression and will be applied to everything inside that expression
that is of the form `{ expr }`.

!!!note
    * Keys that contain symbols that in Julia are operators (e.g the key `"axis background/.style"`) have to be entered
      as strings, as in the example above.

### Transformations

The following transformations of keys/values are done when the options are written in .tex style:

* Underlines in keys are replaced with spaces e.g. `very_thick -> "very thick"`.
* A list as a value is written as "comma joined" e.g. `[1, 2, 3] -> "1, 2, 3"`.
* A tuple as a value is written with braces delimiting the elements e.g. `(60, 30) -> {60}{30}`

## Modifying options after an object is created

It is sometimes convenient to set and get options after an object has been created.

```jldoctest
julia> c = Coordinates([1, 2, 3], [2, 4, 8]);

julia> p = PlotInc(c);

julia> p["fill"] = "blue";

julia> p["fill"]
"blue"

julia> @pgf p["axis background/.style"] = { shade, top_color = "gray", bottom_color = "white" };

julia> p["axis background/.style"]["top_color"];

julia> p["very thick"] = nothing # Set a value-less options;

julia> delete!(p, "fill");

julia> print_tex(p)
    \addplot+ [axis background/.style={shade, top color={gray}, bottom color={white}}, very thick]
        coordinates {
        (1, 2)
        (2, 4)
        (3, 8)
        }
    ;
```

You can also merge in options that have been separately created using `merge!`

```jldoctest
julia> a = Axis();

julia> @pgf opts = {xmin = 0, ymax = 1, ybar};

julia> merge!(a, opts);

julia> print_tex(a)
    \begin{axis} [xmin={0}, ymax={1}, ybar]
    \end{axis}
```

It is then easy to apply for example a "theme" to an axis where the themed is a set of options already saved.
Just `merge!` the theme into an `Axis`.
