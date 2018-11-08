var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#PGFPlotsX-1",
    "page": "Home",
    "title": "PGFPlotsX",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Introduction-1",
    "page": "Home",
    "title": "Introduction",
    "category": "section",
    "text": "PGFPlotsX is a Julia package for creating publication quality figures using the LaTeX library PGFPlots as the backend. PGFPlots has extensive documentation (pdf) and a rich database of answered questions on places like stack overflow and tex.stackexchange. In order to take advantage of this, the syntax in PGFPlotsX is similar to the one written in tex. It is therefore, usually, easy to translate a PGFPlots example written in tex to PGFPlotsX Julia code. The advantage of using PGFPlotsX.jl over writing raw LaTeX code is that it is possible to use Julia objects directly in the figures. Furthermore, the figures can be previewed in notebooks and IDE\'s, like julia-vscode and Atom-Juno. It is, for example, possible to directly use a DataFrame from DataFrames.jl as a PGFPlots table.note: Note\nIn this manual, “PGFPlots” refers to the LaTeX package, its constructs and syntax."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Pkg.add(\"PGFPlotsX\")PGFPlots.jl requires a LaTeX installation with the PGFPlots package installed. We recommend using a LaTeX installation with access to lualatex since it can have significantly better performance over pdflatex.To generate or preview figures in svg (like is done by default in Jupyter notebooks) pdf2svg is required. This can obtained by, on Ubuntu, running sudo apt-get install pdf2svg, on RHEL/Fedora sudo dnf install pdf2svg and on macOS e.g. brew install pdf2svg. On Windows, the binary can be downloaded from here; be sure to add pdf2svg to the PATH.For png figures pdftoppm is required. This should by default on Linux and on macOS should be available after running brew install poppler. It is also available in the Xpdf tools archive.note: Note\nIf you installed a new LaTeX engine, pdf2svg or pdftoppm after you installed PGFPlotsX you need to run Pkg.build(\"PGFPlotsX\") for this to be reflected. The output from Pkg.build should tell you what LaTeX engines and figure-converters it finds."
},

{
    "location": "index.html#Learning-about-PGFPlots-1",
    "page": "Home",
    "title": "Learning about PGFPlots",
    "category": "section",
    "text": "PGFPlotsX does not replicate the PGFPlots documentation. In order to make the best use of this library, you should become familiar with at least the outline of the PGFPlots manual, so that you know about features (plot types, controlling axes and appearance, …) and can look them up when they are needed. If you have PGFPlots installed, a local copy of this manual should be accessible; for example in TeXLive you can open it withtexdoc pgfplotsStudying this documentation, especially the manual gallery and other related examples, you will gain a good understanding of how Julia code can be used to generate LaTeX output for PGFPlots easily.Other useful sources of examples include:the PGFplots examples gallery,\nthe collection of plots from the reference manuals."
},

{
    "location": "man/structs.html#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "man/structs.html#Overview-1",
    "page": "Overview",
    "title": "Overview",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendThis package is a collection of functions and types which make it convenient to generate LaTeX output, which can in turn be compiled by PGFPlots to produce vector or bitmap images like pdf, svg or png, or used directly in LaTeX documents.PGFPlots has a very detailed manual (a local copy should be available in TeXLive and MikTeX installations) which should be your primary source of documentation, and its contents are not repeated here. It is assumed that you read the relevant parts of this manual, and look for solutions there first.Instead, this manual describes a way to conveniently generate what LaTeX output from Julia, using the types introduced in this package, other packages, and Julia\'s built-in constructs. When working with this package, it is frequently convenient to examine the LaTeX representation of objects. print_tex is a method that prints LaTeX code that is written out when saving plots; we use it extensively in this manual for demonstrations, while in practice one would use it for debugging.As an example, consider the following trivial plot:\\begin{tikzpicture}\n\\begin{axis}\n    \\addplot+[only marks] table {\n            x  y\n            1  3\n            2  4\n        };\n    \\addplot+ table {\n            x  y\n            5  1\n            6  2\n        };\n\\end{axis}\n\\end{tikzpicture}which can be produced by this package with the code@pgf TikzPicture(\n        Axis(\n            PlotInc({ only_marks },\n                Table(; x = 1:2, y = 3:4)),\n            PlotInc(\n                Table(; x = 5:6, y = 1:2))))(The unconventional use of linebreaks in the Julia code is to emphasize the structural similarities between the two pieces of code).The plot is built up from two Tables, which are tabular representations of data with (usually) named columns. These provide data for Plots, here using the PlotInc constructor which corresponds to the \\addplot+ command: the + tells PGFPlots to use a default style that varies with each plot. Each plot can have a single source of data.Plots are grouped together into an Axis, which corresponds to what most other libraries would call a “plot” (we use the term flexibly, too). Besides grouping plots, Axis allows the customization of ticks, labels, axis styles, legends, and related objects.TikzPicture wraps the Axis. If you omit this, this package will do it for you automatically. Similarly, if you have a single Plot-like object and don\'t want to customize the Axis, it will also be added automatically.Finally, @pgf is a convenient syntax for specifying options. It is is a macro that traverses its argument recursively, and converts it to a PGFPlotsX.Options object. It is recommended that you use this macro. The convention of this library is to apply @pgf to whole expressions to avoid repetition, but this is not required.PGFPlotsX allows building up plots from types that correspond very closely to PGFPlots counterparts. The table below gives an overview of the types defined by this package. For most PGFPlots constructs, [] can be used to specify options, this corresponds to the [options] argument in the table above.PGFPlots ([] indicates options) PGFPlotsX remark\ntable[] { ... } Table([options], ...) preferred to Coordinates\ncoordinates { ... } Coordinates(...) useful error bars\n\\addplot[] { ... } & friends Plot([options], ...) & friends also PlotInc, Plot3, Plot3Inc\n\\legend, \\legendentry[] Legend, Legendentry([options]) \n{expression} Expression(...) math formulas\ngraphics[] { ... } Graphics([options], ...) bitmaps\n\\axis[] { ... } & friends Axis([options], ...) & friends can have multiple Plots & similar\n\\begin{tikzpicture} ... TikzPicture([options], ...) rarely used directly\n\\begin{document} ... TikzDocument(...; ...) rarely used directlyThe following sections document these."
},

{
    "location": "man/options.html#",
    "page": "Options",
    "title": "Options",
    "category": "page",
    "text": ""
},

{
    "location": "man/options.html#options_header-1",
    "page": "Options",
    "title": "Options",
    "category": "section",
    "text": "Options, which usually occur between brackets ([]) after commands like \\addplot, table, or beginnings of environments like \\begin{axis} in LaTeX code, are key to most of the functionality of PGFPlots.DocTestSetup = quote\n    using PGFPlotsX\nend"
},

{
    "location": "man/options.html#PGFPlotsX.@pgf",
    "page": "Options",
    "title": "PGFPlotsX.@pgf",
    "category": "macro",
    "text": "@pgf { ... }\n\n@pgf some(nested(form({ ... })),\n          with_multiple_options({ ... }))\n\nConstruct Options from comma-delimited key (without value), key = value, key : value, or key => value pairs enclosed in { ... }, anywhere in the expression.\n\nThe argument is traversed recursively, allowing { ... } expressions in multiple places.\n\nMulti-word keys need to be either quoted, or written with underscores replacing spaces.\n\n@pgf {\n    \"only marks\",\n    mark_size = \"0.6pt\",\n    mark = \"o\",\n    color => \"black\",\n}\n\nAnother Options can be spliced into one being created using ..., e.g.\n\ntheme = @pgf {xmajorgrids, x_grid_style = \"white\"}\n\naxis_opt = @pgf {theme..., title = \"My figure\"}\n\nUse {} for empty options that print as [] in LaTeX.\n\n\n\n\n\n"
},

{
    "location": "man/options.html#The-@pgf-macro-1",
    "page": "Options",
    "title": "The @pgf macro",
    "category": "section",
    "text": "Use the @pgf {} macro to define options.@pgfFor constructors that accept options, they always come first. When omitted, there are assumed to be no options.julia> c = Coordinates([1, 2, 3], [2, 4, 8]);\n\njulia> p = @pgf PlotInc({ \"very thick\", \"mark\" => \"halfcircle\" }, c);\n\njulia> print_tex(p); # print_tex can be used to preview the generated .tex\n\\addplot+[very thick, mark={halfcircle}]\n    coordinates {\n        (1,2)\n        (2,4)\n        (3,8)\n    }\n    ;Inside the expression following @pgf, {} expressions can be nested, and can also occur in multiple places.julia> @pgf a = Axis(\n           {\n               \"axis background/.style\" =\n               {\n                   shade,\n                   top_color = \"gray\",\n                   bottom_color = \"white\",\n               },\n               ymode = \"log\"\n           },\n           PlotInc(\n           {\n               smooth\n           },\n           c)\n       );which is converted to LaTeX asjulia> print_tex(a)\n\\begin{axis}[axis background/.style={shade, top color={gray}, bottom color={white}}, ymode={log}]\n    \\addplot+[smooth]\n        coordinates {\n            (1,2)\n            (2,4)\n            (3,8)\n        }\n        ;\n\\end{axis}note: Note\nIf you use @pgf inside argument lists, make sure you wrap its argument in parentheses, egPlot(@pgf({ scatter }), some_table)Otherwise Julia will also pass the subsequent arguments through @pgf, which results in an error since they are combined into a tuple.Each option is either a standalone keyword (without value, modifying the plot by itself), or a keyword-value pair. Keywords can be enteredas Julia identifiers, which is useful for keywords with no spaces (eg smooth),\nseparated by underscores, which are replaced by spaces (eg only_marks will appear in LaTeX code as only marks),\nor quoted as strings, eg \"very thick\".Values are provided after a =, :, or =>, so the following are equivalent:@pgf { draw = \"black\" },\n@pgf { draw : \"black\" },\n@pgf { draw => \"black\" }.Values should be valid Julia expressions, as they are evaluated, so you cannot use @pgf { draw = black } unless black is assigned to some Julia value in that context.note: Note\nKeys that contain symbols that in Julia are operators (e.g the key \"axis background/.style\") have to be entered as strings."
},

{
    "location": "man/options.html#Transformations-1",
    "page": "Options",
    "title": "Transformations",
    "category": "section",
    "text": "In addition to replacing underscores in keys, the following transformations of values are done when the options are written in .tex style:A list as a value is written as \"comma joined\" e.g. [1, 2, 3] -> \"1, 2, 3\".\nA tuple as a value is written with braces delimiting the elements e.g. (60, 30) -> {60}{30}"
},

{
    "location": "man/options.html#Modifying-options-after-an-object-is-created-1",
    "page": "Options",
    "title": "Modifying options after an object is created",
    "category": "section",
    "text": "It is sometimes convenient to set and get options after an object has been created.You can use getindex, setindex! (ie obj[\"option\"] or obj[\"option\"] = value, respectively), and delete! just like you would for modifiable associative collections (eg a Dict).julia> c = Coordinates([1, 2, 3], [2, 4, 8]);\n\njulia> p = PlotInc(c);\n\njulia> p[\"fill\"] = \"blue\";\n\njulia> p[\"fill\"]\n\"blue\"\n\njulia> @pgf p[\"axis background/.style\"] = { shade, top_color = \"gray\", bottom_color = \"white\" };\n\njulia> p[\"axis background/.style\"][\"top_color\"];\n\njulia> p[\"very thick\"] = nothing # Set a value-less options;\n\njulia> delete!(p, \"fill\");\n\njulia> print_tex(p)\n\\addplot+[axis background/.style={shade, top color={gray}, bottom color={white}}, very thick]\n    coordinates {\n        (1,2)\n        (2,4)\n        (3,8)\n    }\n    ;You can also merge in options that have been created separately, using merge!:julia> a = Axis();\n\njulia> @pgf opts = {xmin = 0, ymax = 1, ybar};\n\njulia> merge!(a, opts);\n\njulia> print_tex(a)\n\\begin{axis}[xmin={0}, ymax={1}, ybar]\n\\end{axis}An alternative to using merge! is using  ... to splice an option into another one, e.g.julia> theme = @pgf {xmajorgrids, ymajorgrids};\n\njulia> a = Axis(\n           @pgf {theme..., title = \"Foo\"}\n       );\n\njulia> print_tex(a)\n\\begin{axis}[xmajorgrids, ymajorgrids, title={Foo}]\n\\end{axis}It is then easy to apply, for example, a “theme” to an axis where the theme is a set of options already saved."
},

{
    "location": "man/options.html#Empty-options-1",
    "page": "Options",
    "title": "Empty options",
    "category": "section",
    "text": "Empty options are not printed by default, but printing [] can be useful in some cases, eg when combined with global settings \\pgfplotsset{every axis plot/.append style={...}} in LaTeX code. In order to force printing empty options, it is recommended to use {} in expressions like@pgf Plot({}, ...)"
},

{
    "location": "man/data.html#",
    "page": "Data",
    "title": "Data",
    "category": "page",
    "text": ""
},

{
    "location": "man/data.html#Data-1",
    "page": "Data",
    "title": "Data",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendThere are multiple ways of representing data in PGFPlots."
},

{
    "location": "man/data.html#PGFPlotsX.Table",
    "page": "Data",
    "title": "PGFPlotsX.Table",
    "category": "type",
    "text": "Table([options], ...; ...)\n\nTabular data with options, corresponding to table[options] { ... } in PGFPlots.\n\noptions stores the options. If that is followed by an AbstractString, that will be used as a filename to read data from, otherwise all the arguments are passed on to TableData.\n\nExamples:\n\nTable([\"x\" => 1:10, \"y\" => 11:20])        # from a vector\n\nTable([1:10, 11:20])                      # same contents, unnamed\n\nTable(Dict(:x => 1:10, :y = 11:20))       # a Dict with symbols\n\n@pgf Table({ \"x index\" = 2, \"y index\" = 1\" }, randn(10, 3))\n\nlet x = range(0; stop = 1, length = 10), y = range(-2; stop =  3, length = 15)\n    Table(x, y, sin.(x + y\'))             # edges & matrix\nend\n\n\n\n\n\n"
},

{
    "location": "man/data.html#PGFPlotsX.TableData",
    "page": "Data",
    "title": "PGFPlotsX.TableData",
    "category": "type",
    "text": "Tabular data with optional column names.\n\nThis corresponds to the part of tables between {}\'s in PGFPlots, without the options or table, so that it can also be used for “inline” tables. Table will call the constructor for this type to convert arguments after options.\n\ndata is a matrix, which contains the contents of the table, which will be printed using print_tex. colnames is a vector of column names (converted to string), or nothing for a table with no column names.\n\nWhen rowsep is true, an additional \\\\ is used as a row separator. The default is true, this is recommended to avoid “fragility” issues with inline tables.\n\nnote: Note\nTable queries TableData for its rowsep, and adds the relevant option accordingly. When using “inline” tables, eg in options, you have to specify this manually for the container. See the gallery for examples.\n\nAfter each index in scanlines, extra row separators are inserted. This can be used for skipping coordinates or implicitly defining the dimensions of a matrix for surf and mesh plots. They are expanded using expand_scanlines.\n\n\n\n\n\n"
},

{
    "location": "man/data.html#table_header-1",
    "page": "Data",
    "title": "Table and TableData",
    "category": "section",
    "text": "A Table represents a matrix of data where each column is labeled. It can simply point to an external data file or store the data inline in the tex file. Tables can have options.TableData is the representation of just the data, without the table[options] part. It is useful for inline tables in specials cases. Also, calls to Table use TableData to convert the arguments, so if you want to learn about all the ways to construct a Table, see the methods of TableData.Table\nTableDataExamples:julia> t = @pgf Table({x = \"Dof\"}, \"data.dat\");\n\njulia> print_tex(t)\ntable [x={Dof}] {\n    <ABSPATH>/data.dat\n}Inline data is constructed using a keyword constructor:julia> t = @pgf Table({x => \"Dof\", y => \"Err\"},\n                      [:Dof => [1, 2, 4], :Err => [2.0, 1.0, 0.1]]);\n\njulia> print_tex(t)\ntable[row sep={\\\\}, x={Dof}, y={Err}]\n{\n    Dof  Err  \\\\\n    1.0  2.0  \\\\\n    2.0  1.0  \\\\\n    4.0  0.1  \\\\\n}If you load the DataFrames package, you can also create tables from data frames, see the examples in Julia types.note: Note\nBy default, PGFPlots expects rows to be separated in a table with a newline. This can be “fragile” in LaTeX, in the sense that linebreaks may be merged with other whitespace within certain constructs, eg macros. In order to prevent this, this package uses the option rowsep=\\\\ by default. This is taken care of automatically, except for inline tables where you have to specify it manually. See the patch plot in the gallery."
},

{
    "location": "man/data.html#coordinates_header-1",
    "page": "Data",
    "title": "Using coordinates",
    "category": "section",
    "text": "Coordinates are a list of points (x,y) or (x,y,z). PGFPlotsX wraps these in the Coordinate type, but for multiple coordinates, it is recommended that you use the Coordinates constructor, which has convenience features like converting non-finite numbers to skipped points (represented by nothing).Strings are also accepted in place of numbers, and can be used for symbolic coordinates (eg for categorical data). See this example."
},

{
    "location": "man/data.html#PGFPlotsX.Coordinates",
    "page": "Data",
    "title": "PGFPlotsX.Coordinates",
    "category": "type",
    "text": "Coordinates(itr)\n\n\nConvert the argument, which can be any iterable object, to coordinates.\n\nSpecifically,\n\nCoordinate and Nothing are passed through as is,\n2- or 3-element tuples of finite real numbers or strings are interpreted as coordinates,\n(), and tuples with non-finite numbers become nothing (representing empty lines).\n\nThe resulting coordinates are checked for dimension consistency.\n\nExamples\n\nThe following are equivalent:\n\nCoordinates((x, 1/x) for x in -5:5)\nCoordinates(x == 0 ? () : (x, 1/x) for x in -5:5)\nCoordinates(x == 0 ? nothing : Coordinate((x, 1/x)) for x in -5:5)\n\nUse enumerate to add 1, 2, … for the x-axis to an existing set of y coordinates:\n\nCoordinates(enumerate([1, 4, 9]))\n\n\n\n\n\nCoordinates(x, y; xerror, yerror, xerrorplus, yerrorplus, xerrorminus, yerrorminus, meta)\n\n\nTwo dimensional coordinates from two vectors, with error bars.\n\n\n\n\n\nCoordinates(x, y, z; xerror, yerror, zerror, xerrorplus, yerrorplus, zerrorplus, xerrorminus, yerrorminus, zerrorminus, meta)\n\n\nThree dimensional coordinates from two vectors, with error bars.\n\n\n\n\n\nCoordinates(x, y, z; meta)\n\n\nConstruct coordinates from a matrix of values and edge vectors, such that z[i,j] corresponds to x[i] and y[j]. Empty scanlines are inserted, consistently with the mesh/ordering=x varies option of PGFPlots (the default).\n\nx = range(0; stop = 1, length = 10)\ny = range(-1; stop = 2, length = 13)\nz = sin.(x) + cos.(y\')\nCoordinates(x, y, z)\n\n\n\n\n\n"
},

{
    "location": "man/data.html#Coordinates-1",
    "page": "Data",
    "title": "Coordinates",
    "category": "section",
    "text": "Coordinates(x, y, [z]) where x and y (and optionally z) are lists.\nCoordinates(points) where points is a list of tuples, Coordinates, or nothing, e.g. x = [(1.0, 2.0), (2.0, 4.0)].Errors can be added to Coordinates with keywords.CoordinatesExamples:julia> x = [1, 2, 3]; y = [2, 4, 8]; z = [-1, -2, -3];\n\njulia> print_tex(Coordinates(x, y))\ncoordinates {\n    (1,2)\n    (2,4)\n    (3,8)\n}\n\njulia> print_tex(Coordinates(x, y, z))\ncoordinates {\n    (1,2,-1)\n    (2,4,-2)\n    (3,8,-3)\n}\n\njulia> print_tex(Coordinates(x, x.^3))\ncoordinates {\n    (1,1)\n    (2,8)\n    (3,27)\n}\n\njulia> print_tex(Coordinates([(1.0, 2.0), (2.0, 4.0)]))\ncoordinates {\n    (1.0,2.0)\n    (2.0,4.0)\n}\n\njulia> c = Coordinates(x, y, xerror = [0.2, 0.3, 0.5], yerror = [0.2, 0.1, 0.5]);\n\njulia> print_tex(c)\ncoordinates {\n    (1,2) +- (0.2,0.2)\n    (2,4) +- (0.3,0.1)\n    (3,8) +- (0.5,0.5)\n}"
},

{
    "location": "man/data.html#PGFPlotsX.Coordinate",
    "page": "Data",
    "title": "PGFPlotsX.Coordinate",
    "category": "type",
    "text": "Coordinate(data; error, errorplus, errorminus, meta)\n\n\nConstruct a coordinate, with optional error bars and metadata. data should be a 2- or 3-element tuples of finite real numbers.\n\nYou can specify either\n\nerror, which will then be used for error bars in both directions, or\nerrorplus and/or errorminus, for asymmetrical error bars.\n\nError values can be tuples of the same kind as data, or nothing.\n\nMetadata can be provided in meta.\n\nUsers rarely need to use this constructor, see methods of Coordinates for constructing coordinates from arrays.\n\n\n\n\n\nCoordinate(x, y; args...)\n\n\nConvenience constructor for 2-dimensional coordinates.\n\n\n\n\n\nCoordinate(x, y, z; args...)\n\n\nConvenience constructor for 3-dimensional coordinates.\n\n\n\n\n\n"
},

{
    "location": "man/data.html#Individual-coordinates-1",
    "page": "Data",
    "title": "Individual coordinates",
    "category": "section",
    "text": "Use this constructor when you need just a single Coordinate, eg as in@pgf Axis(\n    {\n        legend_style =\n        {\n            at = PGFPlotsX.Coordinate(0.5, -0.15),\n            anchor = \"north\",\n            legend_columns = -1\n        },\n    }, ...)Coordinate"
},

{
    "location": "man/data.html#PGFPlotsX.Expression",
    "page": "Data",
    "title": "PGFPlotsX.Expression",
    "category": "type",
    "text": "Expression(expressions::Vector{String})\n\nExpression(strings::String...)\n\nAn Expression is a string or multiple strings, representing a function, and is written in a way LaTeX understands.\n\n\n\n\n\n"
},

{
    "location": "man/data.html#Expression-1",
    "page": "Data",
    "title": "Expression",
    "category": "section",
    "text": "ExpressionExample:julia> ex = Expression(\"exp(-x^2)\");\n\njulia> print_tex(ex)\n{exp(-x^2)}"
},

{
    "location": "man/data.html#PGFPlotsX.Graphics",
    "page": "Data",
    "title": "PGFPlotsX.Graphics",
    "category": "type",
    "text": "Graphics([options], filename)\n\nGraphics data simply wraps an image (eg a .png file).\n\n\n\n\n\n"
},

{
    "location": "man/data.html#Graphics-1",
    "page": "Data",
    "title": "Graphics",
    "category": "section",
    "text": "GraphicsExample:julia> print_tex(Graphics(\"img.png\"))\ngraphics {img.png}"
},

{
    "location": "man/axiselements.html#",
    "page": "Axis elements",
    "title": "Axis elements",
    "category": "page",
    "text": ""
},

{
    "location": "man/axiselements.html#axis_elements-1",
    "page": "Axis elements",
    "title": "Axis elements",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendThe following types are accepted as elements of Axis & friends:plot variants: Plot, PlotInc, Plot3, Plot3Inc,\nlegend specifications: Legend, LegendEntry,\nstrings, which are inserted verbatim.This section documents these."
},

{
    "location": "man/axiselements.html#plotlike-1",
    "page": "Axis elements",
    "title": "Plots",
    "category": "section",
    "text": "A plot is an element inside an axis. It can be a wide range of constructs, from a simple line to a 3D surface. A plot is created by wrapping one of the data structures.note: Note\nPGFPlots uses \\addplot & friends for visualization that uses a single data source, in most cases drawn using the same style. If you want to plot multiple sources of data that share axes, eg two time series, your axis will have multiple “plots” in the terminology of PGFPlots."
},

{
    "location": "man/axiselements.html#PGFPlotsX.Plot",
    "page": "Axis elements",
    "title": "PGFPlotsX.Plot",
    "category": "type",
    "text": "struct Plot <: PGFPlotsX.OptionType\n\nCorresponds to the \\addplot[3][+] family of pgfplot commands.\n\nInstead of the default constructor, use Plot([options], data, trailing...) and similar (PlotInc, Plot3, Plot3Inc) in user code.\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#PGFPlotsX.PlotInc",
    "page": "Axis elements",
    "title": "PGFPlotsX.PlotInc",
    "category": "function",
    "text": "PlotInc([options::Options], data, trailing...)\n\nCorresponds to the \\addplot+ form in PGFPlots.\n\nFor the interpretation of the other arguments, see Plot(::Options, ::PlotData, ...).\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#Plot-and-PlotInc-1",
    "page": "Axis elements",
    "title": "Plot and PlotInc",
    "category": "section",
    "text": "For \\addplot and \\addplot+, respectively.Plot\nPlotIncExample:julia> p = @pgf PlotInc({ blue }, Table(\"plotdata/invcum.dat\"));\n\njulia> print_tex(p)\n\\addplot+[blue]\n    table {plotdata/invcum.dat};"
},

{
    "location": "man/axiselements.html#PGFPlotsX.Plot3",
    "page": "Axis elements",
    "title": "PGFPlotsX.Plot3",
    "category": "function",
    "text": "Plot3([options::Options], data, trailing...)\n\nCorresponds to the \\addplot3 form in PGFPlots.\n\nFor the interpretation of the other arguments, see Plot(::Options, ::PlotData, ...).\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#PGFPlotsX.Plot3Inc",
    "page": "Axis elements",
    "title": "PGFPlotsX.Plot3Inc",
    "category": "function",
    "text": "Plot3Inc([options::Options], data, trailing...)\n\nCorresponds to the \\addplot3+ form in PGFPlots.\n\nFor the interpretation of the other arguments, see Plot(::Options, ::PlotData, ...).\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#Plot3-1",
    "page": "Axis elements",
    "title": "Plot3",
    "category": "section",
    "text": "Plot3 will use the \\addplot3 command instead of \\addplot to draw 3D graphics. Otherwise it works the same as Plot. The incremental variant is Plot3Inc.Plot3\nPlot3IncExample:julia> x, y, z = [1, 2, 3], [2, 4, 8], [3, 9, 27];\n\njulia> p = @pgf Plot3({ very_thick }, Coordinates(x, y, z));\n\njulia> print_tex(p)\n\\addplot3[very thick]\n    coordinates {\n        (1,2,3)\n        (2,4,9)\n        (3,8,27)\n    }\n    ;"
},

{
    "location": "man/axiselements.html#PGFPlotsX.Legend",
    "page": "Axis elements",
    "title": "PGFPlotsX.Legend",
    "category": "type",
    "text": "Legend(labels)\n\n\nCorresponds to \\legend{ ... } in PGFPlots. Specifies multiple legends for an axis, its position is irrelevant.\n\nlabels are wrapped in {}s, so they can contain ,.\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#PGFPlotsX.LegendEntry",
    "page": "Axis elements",
    "title": "PGFPlotsX.LegendEntry",
    "category": "type",
    "text": "LegendEntry([options::Options], name, [isexpanded])\n\nCorresponds to the \\addlegendentry and \\addlegendentryexpanded forms of PGFPlots.\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#Legends-1",
    "page": "Axis elements",
    "title": "Legends",
    "category": "section",
    "text": "Legend\nLegendEntryA Legend can be used to add legends to an axis, for multiple plots at the same time. In contrast, LegendEntry applies to the preceding plot.Example:julia> print_tex(Legend([\"Plot A\", \"Plot B\"]))\n\\legend{{Plot A},{Plot B}}"
},

{
    "location": "man/axiselements.html#PGFPlotsX.HLine",
    "page": "Axis elements",
    "title": "PGFPlotsX.HLine",
    "category": "type",
    "text": "HLine([options], y)\n\nA horizontal vertical line at y.\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#PGFPlotsX.VLine",
    "page": "Axis elements",
    "title": "PGFPlotsX.VLine",
    "category": "type",
    "text": "VLine([options], x)\n\nA vertical line at x.\n\n\n\n\n\n"
},

{
    "location": "man/axiselements.html#Horizontal-and-vertical-lines-1",
    "page": "Axis elements",
    "title": "Horizontal and vertical lines",
    "category": "section",
    "text": "HLine and VLine have no equivalent constructs in pgfplots, they are provided for convenient drawing of horizontal and vertical lines. When options are used, they are passed to the TikZ function \\draw[...].HLine\nVLine"
},

{
    "location": "man/axiselements.html#latex_code_strings-1",
    "page": "Axis elements",
    "title": "Using LaTeX code directly",
    "category": "section",
    "text": "In case there is no type defined in this package for some construct, you can use a String in an axis, and it is inserted verbatim into the generated LaTeX code. Raw string literals and the package LaTeXStrings are useful to avoid a lot of escaping."
},

{
    "location": "man/axislike.html#",
    "page": "Axis & friends",
    "title": "Axis & friends",
    "category": "page",
    "text": ""
},

{
    "location": "man/axislike.html#axislike-1",
    "page": "Axis & friends",
    "title": "Axis & friends",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendThis section documents constructs which are similar to Axis. In addition to options, they accept all axis elements."
},

{
    "location": "man/axislike.html#PGFPlotsX.Axis",
    "page": "Axis & friends",
    "title": "PGFPlotsX.Axis",
    "category": "type",
    "text": "Axis([options], elements...)\n\nLinear axes, corresponds to axis in PGFPlots.\n\n\n\n\n\n"
},

{
    "location": "man/axislike.html#Axis-1",
    "page": "Axis & friends",
    "title": "Axis",
    "category": "section",
    "text": "AxisAxis make up the labels and titles etc in the figure and is the standard way of wrapping plots, represented in TeX as\\begin{axis} [...]\n    ...\n\\end{axis}Examples:julia> @pgf a = Axis({\n              xlabel = \"x\",\n              ylabel = \"y\",\n              title = \"Figure\"\n          },\n          PlotInc( Expression(\"x^2\")));\n\njulia> print_tex(a)\n\\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]\n    \\addplot+\n        {x^2};\n\\end{axis}\n\njulia> push!(a, PlotInc(Coordinates([1, 2], [3, 4])));\n\n\njulia> print_tex(a)\n\\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]\n    \\addplot+\n        {x^2};\n    \\addplot+\n        coordinates {\n            (1,3)\n            (2,4)\n        }\n        ;\n\\end{axis}Any struct can be pushed into an Axis. The LaTeX code that is generated is the result of PGFPlotsX.print_tex(io::IO, t::T, ::Axis), where T is the type of the struct. Pushed strings are written out verbatim."
},

{
    "location": "man/axislike.html#PGFPlotsX.GroupPlot",
    "page": "Axis & friends",
    "title": "PGFPlotsX.GroupPlot",
    "category": "type",
    "text": "GroupPlot([options], contents...)\n\nA group plot, using the groupplots library of PGFPlots.\n\nThe contents after the global options are processed as follows:\n\nOptions (ie from @pgf {}) will emit a \\nextgroupplot with the given options,\nnothing is emitted as a \\nextgroupplot[group/empty plot],\nother values, eg Plot are emitted using print_tex.\n\n\n\n\n\n"
},

{
    "location": "man/axislike.html#GroupPlot-1",
    "page": "Axis & friends",
    "title": "GroupPlot",
    "category": "section",
    "text": "A GroupPlot is a way of grouping multiple plots in one figure.GroupPlotExample:julia> @pgf gp = GroupPlot({group_style = { group_size = \"2 by 1\",},\n                                            height = \"6cm\", width = \"6cm\"});\n\njulia> for (expr, data) in zip([\"x^2\", \"exp(x)\"], [\"data1.dat\", \"data2.dat\"])\n           push!(gp, Plot(Expression(expr)),  Plot(Table(data)))\n       end;\n\njulia> print_tex(gp)\n\\begin{groupplot}[group style={group size={2 by 1}}, height={6cm}, width={6cm}]\n    \\addplot\n        {x^2};\n    \\addplot\n        table {data1.dat};\n    \\addplot\n        {exp(x)};\n    \\addplot\n        table {data2.dat};\n\\end{groupplot}In order to add options to the \\nextgroupplot call, simply add arguments in an “option like way” (using @pgf) when you push!julia> @pgf gp = GroupPlot({group_style = { group_size = \"1 by 1\",}, height = \"6cm\", width = \"6cm\"});\n\njulia> @pgf for (expr, data) in zip([\"x^2\"], [\"data2.dat\"])\n           push!(gp, {title = \"Data $data\"}, Plot(Expression(expr)),  Plot(Table(data)))\n       end;\n\njulia> print_tex(gp)\n\\begin{groupplot}[group style={group size={1 by 1}}, height={6cm}, width={6cm}]\n    \\nextgroupplot[title={Data data2.dat}]\n    \\addplot\n        {x^2};\n    \\addplot\n        table {data2.dat};\n\\end{groupplot}"
},

{
    "location": "man/axislike.html#PolarAxis-1",
    "page": "Axis & friends",
    "title": "PolarAxis",
    "category": "section",
    "text": "A PolarAxis plots data on a polar grid.Example:julia> p = PolarAxis( PlotInc( Coordinates([0, 90, 180, 270], [1, 1, 1, 1])));\n\njulia> print_tex(p)\n\\begin{polaraxis}\n    \\addplot+\n        coordinates {\n            (0,1)\n            (90,1)\n            (180,1)\n            (270,1)\n        }\n        ;\n\\end{polaraxis}"
},

{
    "location": "man/axislike.html#PGFPlotsX.SemiLogXAxis",
    "page": "Axis & friends",
    "title": "PGFPlotsX.SemiLogXAxis",
    "category": "type",
    "text": "SemiLogXAxis([options], elements...)\n\nLog x and linear y axes, corresponds to semilogxaxis in PGFPlots.\n\n\n\n\n\n"
},

{
    "location": "man/axislike.html#PGFPlotsX.SemiLogYAxis",
    "page": "Axis & friends",
    "title": "PGFPlotsX.SemiLogYAxis",
    "category": "type",
    "text": "SemiLogYAxis([options], elements...)\n\nLinear x and log y axes, corresponds to semilogyaxis in PGFPlots.\n\n\n\n\n\n"
},

{
    "location": "man/axislike.html#PGFPlotsX.LogLogAxis",
    "page": "Axis & friends",
    "title": "PGFPlotsX.LogLogAxis",
    "category": "type",
    "text": "LogLogAxis([options], elements...)\n\nLog-log axes, corresponds to loglogaxis in PGFPlots.\n\n\n\n\n\n"
},

{
    "location": "man/axislike.html#Semilog-and-log-log-axes-1",
    "page": "Axis & friends",
    "title": "Semilog and log-log axes",
    "category": "section",
    "text": "SemiLogXAxis\nSemiLogYAxis\nLogLogAxis"
},

{
    "location": "man/picdoc.html#",
    "page": "TikzPicture",
    "title": "TikzPicture",
    "category": "page",
    "text": ""
},

{
    "location": "man/picdoc.html#PGFPlotsX.TikzPicture",
    "page": "TikzPicture",
    "title": "PGFPlotsX.TikzPicture",
    "category": "type",
    "text": "TikzPicture([options], contents...)\n\nCorredponds to a tikzpicture block in PGFPlots.\n\nElements can also be added with push! after contruction.\n\n\n\n\n\n"
},

{
    "location": "man/picdoc.html#TikzPicture-1",
    "page": "TikzPicture",
    "title": "TikzPicture",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendA TikzPicture can contain multiple Axis-like objects.TikzPictureExample:julia> tp = @pgf TikzPicture({ \"scale\" => 1.5 }, Axis(Plot(Coordinates([1, 2], [2, 4]))));\n\njulia> print_tex(tp)\n\\begin{tikzpicture}[scale={1.5}]\n\\begin{axis}\n    \\addplot\n        coordinates {\n            (1,2)\n            (2,4)\n        }\n        ;\n\\end{axis}\n\\end{tikzpicture}"
},

{
    "location": "man/picdoc.html#PGFPlotsX.TikzDocument",
    "page": "TikzPicture",
    "title": "PGFPlotsX.TikzDocument",
    "category": "type",
    "text": "TikzDocument(elements...; use_default_preamble = true, preamble = [])\n\nCorresponds to a LaTeX document, usually wrapping TikzPictures.\n\nuse_default_preamble determines whether a preamble is added from the global variables (see CUSTOM_PREAMBLE and CUSTOM_PREAMBLE_PATH).\n\npreamble is appended after the default one (if any).\n\npush! can be used to append elements after construction, and similarly push_preamble! for the preamble.\n\n\n\n\n\n"
},

{
    "location": "man/picdoc.html#TikzDocument-1",
    "page": "TikzPicture",
    "title": "TikzDocument",
    "category": "section",
    "text": "A TikzDocument is the highest level object and represents a whole tex file. It includes a list of objects between \\begin{document} and \\end{document}.TikzDocumentA very simple example where we simply create a TikzDocument with a string is shown below. Normally you would also push Axis-like objects that contain plots.julia> td = TikzDocument();\n\njulia> push!(td, \"Hello World\");\n\njulia> print_tex(td)\n\\RequirePackage{luatex85}\n\\documentclass[tikz]{standalone}\n% Default preamble\n\\usepackage{pgfplots}\n\\pgfplotsset{compat=newest}\n\\usepgfplotslibrary{groupplots}\n\\usepgfplotslibrary{polar}\n\\usepgfplotslibrary{statistics}\n\\begin{document}\nHello World\n\\end{document}A TikzDocument uses global variables to construct a preamble, and allows the user to add extra lines to this (eg in case you want to add \\usepackage lines), or disable it altogether.note: Note\nThere is usually no need to explicitly create a TikzDocument or TikzPicture. Only do this if you want to give special options to them. It is possible to show or save an Axis or e.g. a Plot directly, and they will then be wrapped in the default \"higher level\" objects."
},

{
    "location": "man/save.html#",
    "page": "Showing / Exporting figures",
    "title": "Showing / Exporting figures",
    "category": "page",
    "text": ""
},

{
    "location": "man/save.html#Showing-/-Exporting-figures-1",
    "page": "Showing / Exporting figures",
    "title": "Showing / Exporting figures",
    "category": "section",
    "text": ""
},

{
    "location": "man/save.html#Jupyter,-Juno-1",
    "page": "Showing / Exporting figures",
    "title": "Jupyter, Juno",
    "category": "section",
    "text": "Figures are shown in svg format when evaluated in Jupyter or Juno. For this you need the pdf2svg software installed. If you want to show figures in png format (because perhaps the svg format is too large), you can use display(\"image/png\", p) where p is the figure to show. In Juno, if you are on macOS and there are problems finding the latex executable, see this issue. Starting Atom from the terminal seems to work around it."
},

{
    "location": "man/save.html#REPL-1",
    "page": "Showing / Exporting figures",
    "title": "REPL",
    "category": "section",
    "text": "In the REPL, the figure will be exported to a pdf and attempted to be opened in the default pdf viewing program. If you wish to disable this, run PGFPlotsX.enable_interactive(false)."
},

{
    "location": "man/save.html#PGFPlotsX.pgfsave",
    "page": "Showing / Exporting figures",
    "title": "PGFPlotsX.pgfsave",
    "category": "function",
    "text": "save(filename, td; include_preamble, latex_engine, buildflags, dpi, showing_ide)\n\n\nSave the argument (either TikzDocument, or some other type which is wrapped in one automatically, eg TikzPicture, Axis, or Plot) to filename, guessing the format from the file extension. Keywords specify options, some specific to some output formats.\n\npgfsave is an alias which is exported.\n\n\n\n\n\n"
},

{
    "location": "man/save.html#Exporting-to-files-1",
    "page": "Showing / Exporting figures",
    "title": "Exporting to files",
    "category": "section",
    "text": "Figures can be exported to files usingpgfsave(filename::String, figure; include_preamble::Bool = true, dpi = 150)where the file extension of filename determines the file type (can be pdf, svg or tex, or the standalone tikz file extensions below), include_preamble sets if the preamble should be included in the output (only relevant for tex export) and dpi determines the dpi of the figure (only relevant for png export).pgfsaveThe standalone file extensions tikz, TIKZ, TikZ, pgf, PGF save LaTeX code for a tikzpicture environment without a preamble. You can \\input them directly into a LaTeX document, or use the the tikzscale LaTeX package for using \\includegraphics with possible size adjustments.hint: Hint\nYou can use the externalization feature of tikz/pgfplots, which caches generated pdf files for faster compilation of LaTeX documents. Use\\usepgfplotslibrary{external}\n\\tikzexternalizein the preamble of the LaTeX document which uses these plots, see the manuals for more details."
},

{
    "location": "man/save.html#PGFPlotsX.CUSTOM_PREAMBLE",
    "page": "Showing / Exporting figures",
    "title": "PGFPlotsX.CUSTOM_PREAMBLE",
    "category": "constant",
    "text": "A vector of stings, added after DEFAULT_PREAMBLE.\n\nUse this for additional definitions \\usepackage statements required by the LaTeX code you include into plots.\n\n\n\n\n\n"
},

{
    "location": "man/save.html#customizing_the_preamble-1",
    "page": "Showing / Exporting figures",
    "title": "Customizing the preamble",
    "category": "section",
    "text": "It is common to use a custom preamble to add user-defined macros or use different packages. There are a few ways to do this:push! strings into the global variable PGFPlotsX.CUSTOM_PREAMBLE. Each string in that vector will be inserted in the preamble.\nModify the custom_preamble.tex file in the deps folder of the directory of the package. This file is directly spliced into the preamble of the output.\nDefine the environment variable PGFPLOTSX_PREAMBLE_PATH to a path pointing to a preamble file. The content of that will be inserted into the preamble.PGFPlotsX.CUSTOM_PREAMBLE"
},

{
    "location": "man/save.html#Choosing-the-LaTeX-engine-used-1",
    "page": "Showing / Exporting figures",
    "title": "Choosing the LaTeX engine used",
    "category": "section",
    "text": "Thee are two different choices for latex engines, PDFLATEX, LUALATEX. By default, LUALATEX is used if it was available during Pkg.build(). The active engine can be retrieved with the latexengine() function and be set with latexengine!(engine) where engine is one of the two previously mentioned engines (e.g. PGFPlotsX.PDFLATEX)."
},

{
    "location": "man/save.html#PGFPlotsX.CUSTOM_FLAGS",
    "page": "Showing / Exporting figures",
    "title": "PGFPlotsX.CUSTOM_FLAGS",
    "category": "constant",
    "text": "Custom flags to the engine can be used in the latex command by push!-ing them into the global variable CUSTOM_FLAGS.\n\n\n\n\n\n"
},

{
    "location": "man/save.html#Custom-flags-1",
    "page": "Showing / Exporting figures",
    "title": "Custom flags",
    "category": "section",
    "text": "PGFPlotsX.CUSTOM_FLAGS"
},

{
    "location": "man/internals.html#",
    "page": "Internals",
    "title": "Internals",
    "category": "page",
    "text": ""
},

{
    "location": "man/internals.html#PGFPlotsX.print_tex",
    "page": "Internals",
    "title": "PGFPlotsX.print_tex",
    "category": "function",
    "text": "print_tex(io, elt, [container])\n\nPrint elt to io as LaTeX code. The optional third argument allows methods to work differently depending on the container.\n\nThis method should indent as if at the top level, containers indent their contents as necessary. See print_indent.\n\n\n\n\n\nprint_tex(io, str)\n\n\nPrint a string as is, terminated with a newline.\n\nnote: Note\nThis is used as a workaround for LaTeX code that does not have a corresponding type, eg as elements in Axis. raw or LaTeXStrings are useful to avoid piling up backslashes. The newline is added to separate tokens.\n\n\n\n\n\nprint_tex(io, x)\n\n\nReal numbers are printed as is, except for non-finite representation.\n\n\n\n\n\n"
},

{
    "location": "man/internals.html#PGFPlotsX.print_indent",
    "page": "Internals",
    "title": "PGFPlotsX.print_indent",
    "category": "function",
    "text": "print_indent(f, io_main)\n\n\nCall the f with an IO buffer, capture the output, print it to io_main indended with four spaces.\n\n\n\n\n\nprint_indent(io_main, elt)\n\n\nPrint elt to io with indentation. Shortcut for the function wrapper of print_indent for a single element.\n\n\n\n\n\n"
},

{
    "location": "man/internals.html#PGFPlotsX.expand_scanlines",
    "page": "Internals",
    "title": "PGFPlotsX.expand_scanlines",
    "category": "function",
    "text": "expand_scanlines(n, nrow)\n\n\nExpand scanlines, which is a vector of scanline positions or an integer for repeated scanlines, into a Vector{Int}.\n\n\n\n\n\n"
},

{
    "location": "man/internals.html#PGFPlotsX.Options",
    "page": "Internals",
    "title": "PGFPlotsX.Options",
    "category": "type",
    "text": "Options(pairs; print_empty)\n\n\nOptions passed to PGFPlots for various structures (table, plot, etc).\n\nContents emitted in key = value form, or key when value ≡ nothing. Also see the @pgf convenience macro.\n\nWhen print_empty = false (the default), empty options are not printed. Use print_empty = true to force printing a [] in this case.\n\n\n\n\n\n"
},

{
    "location": "man/internals.html#PGFPlotsX.CUSTOM_PREAMBLE_PATH",
    "page": "Internals",
    "title": "PGFPlotsX.CUSTOM_PREAMBLE_PATH",
    "category": "constant",
    "text": "A file which is spliced directly to the preamble. Customize the file at this path for site-specific setting that apply for every plot.\n\n\n\n\n\n"
},

{
    "location": "man/internals.html#PGFPlotsX.DEFAULT_PREAMBLE",
    "page": "Internals",
    "title": "PGFPlotsX.DEFAULT_PREAMBLE",
    "category": "constant",
    "text": "The default preamble for LaTeX documents. Don\'t change this, customize CUSTOM_PREAMBLE instead.\n\n\n\n\n\n"
},

{
    "location": "man/internals.html#Internals-1",
    "page": "Internals",
    "title": "Internals",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendprint_tex\nPGFPlotsX.print_indent\nPGFPlotsX.expand_scanlines\nPGFPlotsX.Options\nPGFPlotsX.CUSTOM_PREAMBLE_PATH\nPGFPlotsX.DEFAULT_PREAMBLE"
},

{
    "location": "examples/coordinates.html#",
    "page": "Coordinates",
    "title": "Coordinates",
    "category": "page",
    "text": ""
},

{
    "location": "examples/coordinates.html#Coordinates-1",
    "page": "Coordinates",
    "title": "Coordinates",
    "category": "section",
    "text": "using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    pgfsave(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    pgfsave(figname * \".tex\", obj);\n    return nothing\nendUse Coordinates to construct the pgfplots construct coordinates. Various constructors are available."
},

{
    "location": "examples/coordinates.html#Basic-usage-1",
    "page": "Coordinates",
    "title": "Basic usage",
    "category": "section",
    "text": "For basic usage, consider AbstractVectors and iterables. Notice how non-finite values are skipped. You can also use () or nothing for jumps in functions.x = range(-1; stop = 1, length = 51) # so that it contains 1/0\n@pgf Axis(\n    {\n        xmajorgrids,\n        ymajorgrids,\n    },\n    Plot(\n        {\n            no_marks,\n        },\n        Coordinates(x, 1 ./ x)\n    )\n)\nsavefigs(\"coordinates-simple\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/coordinates.html#Error-bars-1",
    "page": "Coordinates",
    "title": "Error bars",
    "category": "section",
    "text": "Use xerror, xerrorplus, xerrorminus, yerror etc. for error bars.x = range(0; stop = 2π, length = 20)\n@pgf Plot(\n    {\n        \"no marks\",\n        \"error bars/y dir=both\",\n        \"error bars/y explicit\",\n    },\n    Coordinates(x, sin.(x); yerror = 0.2*cos.(x))\n)\nsavefigs(\"coordinates-errorbars\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/coordinates.html#symbolic_coordinates_example-1",
    "page": "Coordinates",
    "title": "Symbolic coordinates",
    "category": "section",
    "text": "@pgf Axis(\n    {\n        ybar,\n        enlargelimits = 0.15,\n        legend_style =\n        {\n            at = Coordinate(0.5, -0.15),\n            anchor = \"north\",\n            legend_columns = -1\n        },\n        ylabel = raw\"\\#participants\",\n        symbolic_x_coords=[\"tool8\", \"tool9\", \"tool10\"],\n        xtick = \"data\",\n        nodes_near_coords,\n        nodes_near_coords_align={vertical},\n    },\n    Plot(Coordinates([(\"tool8\", 7), (\"tool9\", 9), (\"tool10\", 4)])),\n    Plot(Coordinates([(\"tool8\", 4), (\"tool9\", 4), (\"tool10\", 4)])),\n    Plot(Coordinates([(\"tool8\", 1), (\"tool9\", 1), (\"tool10\", 1)])),\n    Legend([\"used\", \"understood\", \"not understood\"])\n)\nsavefigs(\"coordinates-symbolic\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/coordinates.html#D-1",
    "page": "Coordinates",
    "title": "3D",
    "category": "section",
    "text": "Use three vectors to construct 3D coordinates.t = range(0; stop = 6*π, length = 100)\n@pgf Plot3(\n    {\n        no_marks,\n    },\n    Coordinates(t .* sin.(t), t .* cos.(t), .-t)\n)\nsavefigs(\"coordinates-3d\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/coordinates.html#Edge-vectors-1",
    "page": "Coordinates",
    "title": "Edge vectors",
    "category": "section",
    "text": "A convenience constructor is available for plotting a matrix of values calculated from edge vectors.x = range(-2; stop = 2, length = 20)\ny = range(-0.5; stop = 3, length = 25)\nf(x, y) = (1 - x)^2 + 100*(y - x^2)^2\n@pgf Plot3(\n    {\n        surf,\n    },\n    Coordinates(x, y, f.(x, y\'))\n)\nsavefigs(\"coordinates-3d-matrix\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/coordinates.html#Heatmap-1",
    "page": "Coordinates",
    "title": "Heatmap",
    "category": "section",
    "text": "x = range(-2; stop = 2, length = 40)\ny = range(-0.5; stop = 3, length = 50)\n@pgf Axis(\n    {\n        view = (0, 90),\n        colorbar,\n        \"colormap/jet\",\n    },\n    Plot3(\n        {\n            surf,\n            shader = \"flat\",\n        },\n        Coordinates(x, y, @. √(f(x, y\')))\n    )\n)\nsavefigs(\"coordinates-3d-matrix-heatmap\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/coordinates.html#Matrix-plot-1",
    "page": "Coordinates",
    "title": "Matrix plot",
    "category": "section",
    "text": "x = repeat(0:2, outer = 3)\ny = repeat(0:2, inner = 3)\nmeta = [\"color=$c\" for c in [\"red\", \"blue\", \"yellow\", \"black\", \"brown\", \"magenta\", \"green\", \"red\", \"white\"]]\nc = Coordinates(x, y; meta = meta)\n@pgf Axis(\n    {\n        enlargelimits = false,\n        xtick = [0, 1, 2]\n    },\n    PlotInc(\n        {\n            matrix_plot,\n            mark = \"*\",\n            nodes_near_coords = raw\"\\coordindex\",\n            \"mesh/color input\" = \"explicit\",\n            \"mesh/cols\" = 3\n        },\n        c,\n    )\n)\nsavefigs(\"matrix-plot\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/tables.html#",
    "page": "Tables",
    "title": "Tables",
    "category": "page",
    "text": ""
},

{
    "location": "examples/tables.html#Tables-1",
    "page": "Tables",
    "title": "Tables",
    "category": "section",
    "text": "Tables are coordinates in a tabular format (essentially a matrix), optionally with named columns. They have various constructors, for direct construction and also for conversion from other types.using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    pgfsave(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    pgfsave(figname * \".tex\", obj);\n    return nothing\nend"
},

{
    "location": "examples/tables.html#Unnamed-columns-1",
    "page": "Tables",
    "title": "Unnamed columns",
    "category": "section",
    "text": "Letx = range(0; stop = 2*pi, length = 100)\ny = sin.(x)x = range(0; stop = 2*pi, length = 100)\ny = sin.(x)You can pass these coordinates in unnamed columns:Plot(Table([x, y]))\nsavefigs(\"table-unnamed-columns\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/tables.html#Named-columns-1",
    "page": "Tables",
    "title": "Named columns",
    "category": "section",
    "text": "Or named columns:Plot(Table([:x => x, :y => y]))\nsavefigs(\"table-named-columns\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/tables.html#Rename-options-1",
    "page": "Tables",
    "title": "Rename options",
    "category": "section",
    "text": "The columns can be renamed using options:@pgf Plot(\n    {\n        x = \"a\",\n        y = \"b\",\n    },\n    Table([:a => x, :b => y]))\nsavefigs(\"table-dict-rename\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/tables.html#Excluding-points-1",
    "page": "Tables",
    "title": "Excluding points",
    "category": "section",
    "text": "In the example below, we use a matrix of values with edge vectors, and omit the points outside the unit circle:x = range(-1; stop = 1, length = 20)\nz = @. 1 - √(abs2(x) + abs2(x\'))\nz[z .≤ 0] .= -Inf\n@pgf Axis(\n    {\n        colorbar,\n        \"colormap/jet\",\n        \"unbounded coords\" = \"jump\"\n    },\n    Plot3(\n        {\n            surf,\n            shader = \"flat\",\n        },\n        Table(x, x, z)\n    )\n)\nsavefigs(\"table-jump-3d\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/tables.html#Quiver-plot-1",
    "page": "Tables",
    "title": "Quiver plot",
    "category": "section",
    "text": "A quiver plot can be created as:x = -2pi:0.2:2*pi\ny = sin.(x)\n\nu = ones(length(x))\nv = cos.(x)\n\n@pgf Axis(\n    {\n        title = \"Quiver plot\",\n        grid = \"both\"\n    },\n    Plot(\n        {\n            quiver = {u = \"\\\\thisrow{u}\", v = \"\\\\thisrow{v}\"},\n            \"-stealth\"\n        },\n        Table(x = x, y = y, u = u, v = v)\n    ),\n    LegendEntry(\"\\$\\\\cos(x)\\$\"),\n    Plot(\n        {\n            color = \"red\",\n            very_thick\n        },\n        Coordinates(x, y)\n    ),\n    LegendEntry(\"\\$\\\\sin(x)\\$\")\n)\nsavefigs(\"quiver\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/axislike.html#",
    "page": "Axis-like objects",
    "title": "Axis-like objects",
    "category": "page",
    "text": ""
},

{
    "location": "examples/axislike.html#Axis-like-objects-1",
    "page": "Axis-like objects",
    "title": "Axis-like objects",
    "category": "section",
    "text": ""
},

{
    "location": "examples/axislike.html#Simple-group-plot-1",
    "page": "Axis-like objects",
    "title": "Simple group plot",
    "category": "section",
    "text": "using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    pgfsave(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    pgfsave(figname * \".tex\", obj);\n    return nothing\nendcs = [[(0,0), (1,1), (2,2)],\n      [(0,2), (1,1), (2,0)],\n      [(0,2), (1,1), (2,1)],\n      [(0,2), (1,1), (1,0)]]\n\n@pgf gp = GroupPlot(\n    {\n        group_style = { group_size = \"2 by 2\",},\n        height = \"4cm\",\n        width = \"4cm\"\n    }\n)\n\n@pgf for (i, coords) in enumerate(cs)\n    push!(gp, {title = i})\n    push!(gp, PlotInc(Coordinates(coords)))\nend\ngp\nsavefigs(\"groupplot-simple\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/axislike.html#Multiple-group-plots-1",
    "page": "Axis-like objects",
    "title": "Multiple group plots",
    "category": "section",
    "text": "x = range(0; stop =2*pi, length = 100)\n@pgf GroupPlot(\n    {\n        group_style =\n        {\n            group_size=\"2 by 1\",\n            xticklabels_at=\"edge bottom\",\n            yticklabels_at=\"edge left\"\n        },\n        no_markers\n    },\n    {},\n    PlotInc(Table(x, sin.(x))),\n    PlotInc(Table(x, sin.(x .+ 0.5))),\n    {},\n    PlotInc(Table(x, cos.(x))),\n    PlotInc(Table(x, cos.(x .+ 0.5))))\nsavefigs(\"groupplot-multiple\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/axislike.html#Polar-axis-1",
    "page": "Axis-like objects",
    "title": "Polar axis",
    "category": "section",
    "text": "angles = [ℯ/50*360*i for i in 1:500]\nradius = [1/(sqrt(i)) for i in range(1; stop = 10, length = 500)]\nPolarAxis(PlotInc(Coordinates(angles, radius)))\nsavefigs(\"polar\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#",
    "page": "PGFPlots manual gallery",
    "title": "PGFPlots manual gallery",
    "category": "page",
    "text": ""
},

{
    "location": "examples/gallery.html#manual_gallery-1",
    "page": "PGFPlots manual gallery",
    "title": "PGFPlots manual gallery",
    "category": "section",
    "text": "Examples converted from the PGFPlots manual gallery. This is a work in progress.using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    pgfsave(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    pgfsave(figname * \".tex\", obj);\n    return nothing\nend"
},

{
    "location": "examples/gallery.html#Cost-Error-1",
    "page": "PGFPlots manual gallery",
    "title": "Cost Error",
    "category": "section",
    "text": "@pgf Axis(\n    {\n        xlabel = \"Cost\",\n        ylabel = \"Error\",\n    },\n    Plot(\n        {\n            color = \"red\",\n            mark  = \"x\"\n        },\n        Coordinates(\n            [\n                (2, -2.8559703),\n                (3, -3.5301677),\n                (4, -4.3050655),\n                (5, -5.1413136),\n                (6, -6.0322865),\n                (7, -6.9675052),\n                (8, -7.9377747),\n            ]\n        ),\n    ),\n)\nsavefigs(\"cost-error\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Simple-Expression-1",
    "page": "PGFPlots manual gallery",
    "title": "Simple Expression",
    "category": "section",
    "text": "using LaTeXStrings\n@pgf Axis(\n    {\n        xlabel = L\"x\",\n        ylabel = L\"f(x) = x^2 - x + 4\"\n    },\n    Plot(\n        Expression(\"x^2 - x + 4\")\n    )\n)\nsavefigs(\"simple-expression\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Mixing-expression-and-coordinates-1",
    "page": "PGFPlots manual gallery",
    "title": "Mixing expression and coordinates",
    "category": "section",
    "text": "@pgf Axis(\n    {\n        height = \"9cm\",\n        width = \"9cm\",\n        grid = \"major\",\n    },\n    PlotInc(Expression(\"-x^5 - 242\")),\n    LegendEntry(\"model\"),\n    PlotInc(Coordinates(\n        [\n            (-4.77778,2027.60977),\n            (-3.55556,347.84069),\n            (-2.33333,22.58953),\n            (-1.11111,-493.50066),\n            (0.11111,46.66082),\n            (1.33333,-205.56286),\n            (2.55556,-341.40638),\n            (3.77778,-1169.24780),\n            (5.00000,-3269.56775),\n        ]\n    )),\n    LegendEntry(\"estimate\")\n)\nsavefigs(\"cost-gain\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Log-logLog-1",
    "page": "PGFPlots manual gallery",
    "title": "Log logLog",
    "category": "section",
    "text": "@pgf LogLogAxis(\n    {\n        xlabel = \"Cost\",\n        ylabel = \"Gain\"\n    },\n    Plot(\n        {\n            color = \"red\",\n            mark  = \"x\"\n        },\n        Coordinates(\n            [\n                (10, 100),\n                (20, 150),\n                (40, 225),\n                (80, 340),\n                (160, 510),\n                (320, 765),\n                (640, 1150),\n            ]\n        )\n    )\n)\nsavefigs(\"cost-gain-log-log\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Yaxis-log-1",
    "page": "PGFPlots manual gallery",
    "title": "Yaxis log",
    "category": "section",
    "text": "@pgf Axis(\n    {\n        xlabel = \"Cost\",\n        ylabel = \"Gain\",\n        ymode = \"log\",\n    },\n    Plot(\n        {\n            color = \"blue\",\n            mark  = \"*\"\n        },\n        Coordinates(\n            [\n                (1, 8)\n                (2, 16)\n                (3, 32)\n                (4, 64)\n                (5, 128)\n                (6, 256)\n                (7, 512)\n            ]\n        )\n    )\n)\nsavefigs(\"cost-gain-ylog\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Dof-vs-error-1",
    "page": "PGFPlots manual gallery",
    "title": "Dof vs error",
    "category": "section",
    "text": "using LaTeXStrings\n@pgf Axis(\n    {\n        xlabel = \"Degrees of freedom\",\n        ylabel = L\"$L_2$ Error\",\n        xmode  = \"log\",\n        ymode  = \"log\",\n    },\n    Plot(Coordinates(\n        [(   5, 8.312e-02), (  17, 2.547e-02), (  49, 7.407e-03),\n         ( 129, 2.102e-03), ( 321, 5.874e-04), ( 769, 1.623e-04),\n         (1793, 4.442e-05), (4097, 1.207e-05), (9217, 3.261e-06),]\n    )),\n    Plot(Coordinates(\n        [(   7, 8.472e-02), (   31, 3.044e-02), (111,   1.022e-02),\n         ( 351, 3.303e-03), ( 1023, 1.039e-03), (2815,  3.196e-04),\n         (7423, 9.658e-05), (18943, 2.873e-05), (47103, 8.437e-06),]\n    )),\n    Plot(Coordinates(\n        [(    9, 7.881e-02), (   49, 3.243e-02), (   209, 1.232e-02),\n         (  769, 4.454e-03), ( 2561, 1.551e-03), (  7937, 5.236e-04),\n         (23297, 1.723e-04), (65537, 5.545e-05), (178177, 1.751e-05),]\n    )),\n    Plot(Coordinates(\n        [(   11, 6.887e-02), (    71, 3.177e-02), (   351, 1.341e-02),\n         ( 1471, 5.334e-03), (  5503, 2.027e-03), ( 18943, 7.415e-04),\n         (61183, 2.628e-04), (187903, 9.063e-05), (553983, 3.053e-05),]\n    )),\n    Plot(Coordinates(\n        [(    13, 5.755e-02), (    97, 2.925e-02), (    545, 1.351e-02),\n         (  2561, 5.842e-03), ( 10625, 2.397e-03), (  40193, 9.414e-04),\n         (141569, 3.564e-04), (471041, 1.308e-04), (1496065, 4.670e-05),]\n    ))\n)\nsavefigs(\"dof-error\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Scatter-classes-1",
    "page": "PGFPlots manual gallery",
    "title": "Scatter classes",
    "category": "section",
    "text": "@pgf Axis(\n    {\n        \"scatter/classes\" = {\n            a = {mark = \"square*\", \"blue\"},\n            b = {mark = \"triangle*\", \"red\"},\n            c = {mark = \"o\", draw = \"black\"},\n        }\n    },\n    Plot(\n        {\n            scatter,\n            \"only marks\",\n            \"scatter src\" = \"explicit symbolic\",\n        },\n        Table(\n            {\n                meta = \"label\"\n            },\n            x = [0.1, 0.45, 0.02, 0.06, 0.9 , 0.5 , 0.85, 0.12, 0.73, 0.53, 0.76, 0.55],\n            y = [0.15, 0.27, 0.17, 0.1, 0.5, 0.3, 0.52, 0.05, 0.45, 0.25, 0.5, 0.32],\n            label = [\"a\", \"c\", \"a\", \"a\", \"b\", \"c\", \"b\", \"a\", \"b\", \"c\", \"b\", \"c\"],\n        )\n    )\n)\nsavefigs(\"table-label\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Splines-1",
    "page": "PGFPlots manual gallery",
    "title": "Splines",
    "category": "section",
    "text": "@pgf Axis(\n    {\n        \"nodes near coords\" = raw\"(\\coordindex)\",\n        title = raw\"\\texttt{patch type=quadratic spline}\",\n    },\n    Plot(\n        {\n            mark = \"*\",\n            patch,\n            mesh, # without mesh, pgfplots tries to fill,\n            # \"patch type\" = \"quadratic spline\", <- Should work??\n        },\n        Coordinates(\n            [\n                # left, right, middle-> first segment\n                (0, 0),   (1, 1),   (0.5, 0.5^2),\n                # left, right, middle-> second segment\n                (1.2, 1), (2.2, 1), (1.7, 2),\n            ]\n        )\n    )\n)\nsavefigs(\"spline-quadratic\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Mesh-scatter-1",
    "page": "PGFPlots manual gallery",
    "title": "Mesh scatter",
    "category": "section",
    "text": "@pgf Plot3(\n    {\n        mesh,\n        scatter,\n        samples = 10,\n        domain = \"0:1\"\n    },\n    Expression(\"x * (1-x) * y * (1-y)\")\n)\nsavefigs(\"mesh-scatter\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Group-plot-1",
    "page": "PGFPlots manual gallery",
    "title": "Group plot",
    "category": "section",
    "text": "# this is an imitation of the figure in the manual, as we generate the data\nx = range(0; stop = 10, length = 100)\n@pgf plot = Plot({very_thick}, Table(x = x, y = @. (sin(x * 8) + 1) * 4 * x))\n@pgf GroupPlot(\n    {\n        group_style =\n        {\n            group_size=\"2 by 2\",\n            horizontal_sep=\"0pt\",\n            vertical_sep=\"0pt\",\n            xticklabels_at=\"edge bottom\"\n        },\n        xmin = 0,\n        ymin = 0,\n        height = \"3.7cm\",\n        width = \"4cm\",\n        no_markers\n    },\n    nothing,\n    {xmin=5, xmax=10, ymin=50, ymax=100},\n    plot,\n    {xmax=5, ymax=50},\n    plot,\n    {xmin=5, xmax=10, ymax=50, yticklabels={}},\n    plot)\nsavefigs(\"groupplot-nested\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#Patch-1",
    "page": "PGFPlots manual gallery",
    "title": "Patch",
    "category": "section",
    "text": "@pgf Axis(Plot(\n    {\n        patch,\n        \"table/row sep\" = \"\\\\\\\\\",\n        patch_table = TableData([0 1 2;\n                                 1 2 3;\n                                 4 3 5])\n    },\n    Table(\n        {\n            point_meta = raw\"\\thisrow{c}\"\n        },\n        :x => [0, 1, 2, 3, 2, 4],\n        :y => [0, 1, 0, 1, 0, 0],\n        :c => [0.2, 0, 1, 0, 0.5, 0.5])))\nsavefigs(\"patch-inline\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#",
    "page": "Julia types",
    "title": "Julia types",
    "category": "page",
    "text": ""
},

{
    "location": "examples/juliatypes.html#Julia-types-1",
    "page": "Julia types",
    "title": "Julia types",
    "category": "section",
    "text": "There is some support to directly use Julia objects from different popular packages in PGFPlotsX.jl. Examples of these are given here.using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    pgfsave(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    pgfsave(figname * \".tex\", obj);\n    return nothing\nend"
},

{
    "location": "examples/juliatypes.html#Dates-1",
    "page": "Julia types",
    "title": "Dates",
    "category": "section",
    "text": "Dates is a standard library in Julia. Date and DateTime types are supported natively, but you should specify the date_coordinates_in = ... option in your plot for the relevant axes.using Dates\ndategrid = Date(2000,1,1):Day(1):Date(2000,12,31)\nrelative_irradiance(d) = (1 + 0.034*cospi(2*Dates.dayofyear(d)/365.25))\n\n@pgf Axis(\n    {\n        date_coordinates_in = \"x\",\n        x_tick_label_style = \"{rotate=90}\",\n        xlabel = \"date\",\n        ylabel = \"relative solar irradiance\",\n    },\n    Plot(\n    {\n        no_marks\n    },\n    Table(dategrid, relative_irradiance.(dategrid))))\nsavefigs(\"dates\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#Colors.jl-1",
    "page": "Julia types",
    "title": "Colors.jl",
    "category": "section",
    "text": ""
},

{
    "location": "examples/juliatypes.html#LineColor-1",
    "page": "Julia types",
    "title": "LineColor",
    "category": "section",
    "text": "Using a colorant as the line colorusing Colors\nμ = 0\nσ = 1e-3\n\naxis = Axis()\n@pgf for (i, col) in enumerate(distinguishable_colors(10))\n    offset = i * 50\n    p = Plot(\n        {\n            color = col,\n            domain = \"-3*$σ:3*$σ\",\n            style = { ultra_thick },\n            samples = 50\n        },\n        Expression(\"exp(-(x-$μ)^2 / (2 * $σ^2)) / ($σ * sqrt(2*pi)) + $offset\"))\n    push!(axis, p)\nend\naxis\nsavefigs(\"colors\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#Colormap-1",
    "page": "Julia types",
    "title": "Colormap",
    "category": "section",
    "text": "Using a colormapusing Colors\np = @pgf Plot3(\n    {\n        surf,\n        point_meta = \"y\",\n        samples = 13\n    },\n    Expression(\"cos(deg(x)) * sin(deg(y))\")\n)\ncolormaps = [\"Blues\", \"Greens\", \"Oranges\", \"Purples\"]\ntd = TikzDocument()\nfor cmap in colormaps\n    push_preamble!(td, (cmap, Colors.colormap(cmap)))\nend\n\ntp = @pgf TikzPicture({ \"scale\" => 0.5 })\npush!(td, tp)\ngp = @pgf GroupPlot({ group_style = {group_size = \"2 by 2\"}})\npush!(tp, gp)\n\nfor cmap in colormaps\n    @pgf push!(gp, { colormap_name = cmap }, p)\nend\nsavefigs(\"colormap\", td) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#ggplot2-1",
    "page": "Julia types",
    "title": "ggplot2",
    "category": "section",
    "text": "Something that looks a bit like ggplot2.using Colors\nusing LaTeXStrings\n\nggplot2_axis_theme = @pgf {\n    tick_align = \"outside\",\n    tick_pos = \"left\",\n    xmajorgrids,\n    x_grid_style = \"white\",\n    ymajorgrids,\n    y_grid_style = \"white\",\n    axis_line_style = \"white\",\n    \"axis_background/.style\" = {\n        fill = \"white!89.803921568627459!black\"\n    }\n}\n\nggplot2_plot_theme = @pgf {\n    mark=\"*\",\n    mark_size = 3,\n    mark_options = \"solid\",\n    line_width = \"1.64pt\",\n}\n\nx = 0:0.3:2\ny1 = sin.(2x)\ny2 = cos.(2x)\ny3 = cos.(5x)\nys = [y1, y2, y3]\nn = length(ys)\n\n# Evenly spread out colors\ncolors = [LCHuv(65, 100, h) for h in range(15; stop = 360+15, length = n+1)][1:n]\n\n@pgf Axis(\n    {\n         ggplot2_axis_theme...,\n         xmin = -0.095, xmax = 1.995,\n         ymin = -1.1,   ymax =1.1,\n         title = L\"Simple plot $\\frac{\\alpha}{2}$\",\n         xlabel = \"time (s)\",\n         ylabel = \"Voltage (mV)\",\n    },\n    [\n        PlotInc(\n            {\n                ggplot2_plot_theme...,\n                color = colors[i]\n            },\n            Coordinates(x, _y))\n        for (i, _y) in enumerate(ys)]...,\n)\nsavefigs(\"ggplot\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#DataFrames.jl-1",
    "page": "Julia types",
    "title": "DataFrames.jl",
    "category": "section",
    "text": "Creating a Table from a DataFrame will write it as expected.using DataFrames\n\nfunction mockdata(n, μ, σ, speed, racer)\n    distance = exp.(μ .+ randn(n).*σ)\n    noise = exp.(randn(n) * 0.1)\n    DataFrame(distance = distance,\n              tracktime = distance ./ (speed .* noise),\n              racer = fill(racer, n))\nend\n\nzenon_measurements = vcat(mockdata(20, 1, 0.2, 0.5, \"Tortoise\"),\n                          mockdata(20, 1, 0.2, 1, \"Achilles\"))\n\n@pgf Axis(\n    {\n        legend_pos = \"north west\",\n        xlabel = \"distance\",\n        ylabel = \"track time\",\n    },\n    Plot(\n        {\n            scatter,\n            \"only marks\",\n            \"scatter src\"=\"explicit symbolic\",\n            \"scatter/classes\"=\n            {\n                Tortoise = {mark = \"square*\",   \"blue\"},\n                Achilles = {mark = \"triangle*\", \"red\"},\n            }\n        },\n        Table(\n            {\n                x = \"distance\",\n                y = \"tracktime\",\n                meta = \"racer\"\n            },\n            zenon_measurements, # <--- Creating a Table from a DataFrame\n        )\n    ),\n    Legend([\"Tortoise\", \"Achilles\"])\n)\nsavefigs(\"dataframes\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#Countour.jl-1",
    "page": "Julia types",
    "title": "Countour.jl",
    "category": "section",
    "text": "A Table of a contour from the Contours.jl package will print as .tex in a format that is good to use with contour_prepared.using Contour\nx = 0.0:0.1:2π\ny = 0.0:0.1:2π\nf = (x,y) -> sin(x)*sin(y)\n@pgf Plot({\n        contour_prepared,\n        very_thick\n    },\n    Table(contours(x, y, f.(x, y\'), 6)))\nsavefigs(\"contour\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#StatsBase.jl-1",
    "page": "Julia types",
    "title": "StatsBase.jl",
    "category": "section",
    "text": "StatsBase.Histogram can be plotted using Table, both for 1D and 2D histograms."
},

{
    "location": "examples/juliatypes.html#D-1",
    "page": "Julia types",
    "title": "1D",
    "category": "section",
    "text": "using StatsBase: Histogram, fit\n@pgf Axis(\n    {\n        \"ybar interval\",\n        \"xticklabel interval boundaries\",\n        xmajorgrids = false,\n        xticklabel = raw\"$[\\pgfmathprintnumber\\tick,\\pgfmathprintnumber\\nexttick)$\",\n        \"xticklabel style\" =\n        {\n            font = raw\"\\tiny\"\n        },\n    },\n    Plot(Table(fit(Histogram, range(0; stop = 1, length = 100).^3, closed = :left))))\nsavefigs(\"histogram-1d\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#D-2",
    "page": "Julia types",
    "title": "2D",
    "category": "section",
    "text": "using StatsBase: Histogram, fit\nw = range(-1; stop = 1, length = 100) .^ 3\nxy = vec(tuple.(w, w\'))\nh = fit(Histogram, (first.(xy), last.(xy)), closed = :left)\n@pgf Axis(\n    {\n        view = (0, 90),\n        colorbar,\n        \"colormap/jet\"\n    },\n    Plot3(\n        {\n            surf,\n            shader = \"flat\",\n\n        },\n        Table(h))\n)\nsavefigs(\"histogram-2d\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#Measurements.jl-1",
    "page": "Julia types",
    "title": "Measurements.jl",
    "category": "section",
    "text": "Vectors of Measurement can be plotted using Coordinates in 2D.using Measurements\nx = [measurement(x, 0.1 + 0.1*rand()) for x in -5:1.0:5]\ny = x.^2\n\n@pgf Axis(\n    {\n        \"error bars/error bar style\" =\n        {\n            very_thin,\n        },\n    },\n    Plot(\n        {\n            only_marks,\n            mark = \"star\",\n            \"error bars/y dir=both\",\n            \"error bars/y explicit\",\n        },\n        Coordinates(x, y)\n    )\n)\nsavefigs(\"measurements\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/convenience.html#",
    "page": "Convenience constructs",
    "title": "Convenience constructs",
    "category": "page",
    "text": ""
},

{
    "location": "examples/convenience.html#Convenience-constructs-1",
    "page": "Convenience constructs",
    "title": "Convenience constructs",
    "category": "section",
    "text": "using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    pgfsave(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    pgfsave(figname * \".tex\", obj);\n    return nothing\nend"
},

{
    "location": "examples/convenience.html#Horizontal-and-vertical-lines-1",
    "page": "Convenience constructs",
    "title": "Horizontal and vertical lines",
    "category": "section",
    "text": "x = range(3.01; stop = 6, length = 100)\ny = @. 1/(x-3) + 3\n@pgf Axis(\n    {\n        ymin = 2.5,\n        ymax = 6,\n        xmin = 2.5\n    },\n    Plot(\n        {\n            no_marks\n        },\n        Table(x, y)\n    ),\n    HLine({ dashed, blue }, 3),\n    VLine({ dotted, red }, 3)\n)\nsavefigs(\"hvline\", ans) # hide[.pdf], [generated .tex](Image: )"
},

]}
