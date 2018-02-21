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
    "text": "PGFPlotsX is a Julia package for creating publication quality figures using the LaTeX library PGFPlots as the backend. PGFPlots has extensive documentation (pdf) and a rich database of answered questions on places like stack overflow and tex.stackexchange. In order to take advantage of this, the syntax in PGFPlotsX is similar to the one written in .tex. It is therefore, usually, easy to translate a PGFPlots example written in .tex to PGFPlotsX Julia code. The advantage of using PGFPlotsX.jl over writing raw latex code is that it is possible to use Julia objects directly in the figures. Furthermore, the figures can be previewed in notebooks and IDE\'s, like julia-vscode and Atom-Juno. It is for example possible to directly use a DataFrame from DataFrames.jl as a PGFPlots table."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Pkg.add(\"PGFPlotsX\")PGFPlots.jl requires a latex installation with the PGFPlots package installed. We recommend using a latex installation with access to lualatex since it can have significantly better performance than pdflatex.To generate or preview figures in svg (like is done by default in Jupyter notebooks) pdf2svg is required. This can obtained by, on Ubuntu, running sudo apt-get install pdf2svg, on RHEL/Fedora sudo dnf install pdf2svg and on macOS e.g. brew install pdf2svg. On Windows, the binary can be downloaded from here; be sure to add pdf2svg to the PATH.For png figures pdftoppm is required. This should by default on Linux and on macOS should be available after running brew install poppler. It is also available in the Xpdf tools archive which can be downloaded here.note: Note\nIf you installed a new latex engine, pdf2svg or pdftoppm after you installed PGFPlotsX you need to run Pkg.build(\"PGFPlotsX\") for this to be reflected. The output from Pkg.build should tell you what latex engines and figure converters it finds."
},

{
    "location": "man/options.html#",
    "page": "Defining options",
    "title": "Defining options",
    "category": "page",
    "text": ""
},

{
    "location": "man/options.html#Defining-options-1",
    "page": "Defining options",
    "title": "Defining options",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendIn PGFPlots, options are given as a list of keys, that might have corresponding values, inside of two square brackets e.g.\\begin{axis}[ybar, width = 4.5cm]\n...\n\\end{axis}This section shows the method for which to set and retrieve such options in Julia."
},

{
    "location": "man/options.html#Setting-options-when-constructing-an-object-1",
    "page": "Defining options",
    "title": "Setting options when constructing an object",
    "category": "section",
    "text": ""
},

{
    "location": "man/options.html#As-arguments-to-the-constructor-1",
    "page": "Defining options",
    "title": "As arguments to the constructor",
    "category": "section",
    "text": "When constructing an object (like a Plot), options to that object can be entered in the argument list where a string represents a key without a value (e.g. \"very thick\") and a pair represents a key/value option, (e.g. \"samples\" => 50). This works well when the options are few and there is only one level of options in the object.julia> c = Coordinates([1, 2, 3], [2, 4, 8]);\n\njulia> p = Plot(c, \"very thick\", \"mark\" => \"halfcircle\");\n\njulia> print_tex(p); # print_tex can be used to preview the generated .tex\n\\addplot+[very thick, mark={halfcircle}]\n        coordinates {\n        (1, 2)\n        (2, 4)\n        (3, 8)\n        }\n    ;"
},

{
    "location": "man/options.html#The-@pgf-macro-1",
    "page": "Defining options",
    "title": "The @pgf macro",
    "category": "section",
    "text": "When there are nested options the previous method does not work so well. Instead, we provide a macro @pgf so that options can be entered similarly to how they are in tex.The previous example is then written asjulia> @pgf Plot(\n           {\n               very_thick,\n               mark = \"halfcircle\"\n           },\n           c);A more complicated example is:julia> @pgf a = Axis(Plot(c),\n           {\n               \"axis background/.style\" =\n               {\n                   shade,\n                   top_color = \"gray\",\n                   bottom_color = \"white\",\n               },\n               ymode = \"log\"\n           }\n       );which is printed asjulia> print_tex(a)\n    \\begin{axis}[axis background/.style={shade, top color={gray}, bottom color={white}}, ymode={log}]\n        \\addplot+[]\n            coordinates {\n            (1, 2)\n            (2, 4)\n            (3, 8)\n            }\n        ;\n    \\end{axis}The macro can be applied to any type of expression and will be applied to everything inside that expression that is of the form { expr }.!!!note     * Keys that contain symbols that in Julia are operators (e.g the key \"axis background/.style\") have to be entered       as strings, as in the example above."
},

{
    "location": "man/options.html#Transformations-1",
    "page": "Defining options",
    "title": "Transformations",
    "category": "section",
    "text": "The following transformations of keys/values are done when the options are written in .tex style:Underlines in keys are replaced with spaces e.g. very_thick -> \"very thick\".\nA list as a value is written as \"comma joined\" e.g. [1, 2, 3] -> \"1, 2, 3\".\nA tuple as a value is written with braces delimiting the elements e.g. (60, 30) -> {60}{30}"
},

{
    "location": "man/options.html#Modifying-options-after-an-object-is-created-1",
    "page": "Defining options",
    "title": "Modifying options after an object is created",
    "category": "section",
    "text": "It is sometimes convenient to set and get options after an object has been created.julia> c = Coordinates([1, 2, 3], [2, 4, 8]);\n\njulia> p = Plot(c);\n\njulia> p[\"fill\"] = \"blue\";\n\njulia> p[\"fill\"]\n\"blue\"\n\njulia> @pgf p[\"axis background/.style\"] = { shade, top_color = \"gray\", bottom_color = \"white\" };\n\njulia> p[\"axis background/.style\"][\"top_color\"];\n\njulia> p[\"very thick\"] = nothing # Set a value-less options;\n\njulia> delete!(p, \"fill\");\n\njulia> print_tex(p)\n    \\addplot+[axis background/.style={shade, top color={gray}, bottom color={white}}, very thick]\n        coordinates {\n        (1, 2)\n        (2, 4)\n        (3, 8)\n        }\n    ;You can also merge in options that have been separately created using merge!julia> a = Axis();\n\njulia> @pgf opts =  {xmin = 0, ymax = 1, ybar};\n\njulia> merge!(a, opts);\n\njulia> print_tex(a)\n    \\begin{axis}[xmin={0}, ymax={1}, ybar]\n    \\end{axis}It is then easy to apply for example a \"theme\" to an axis where the themed is a set of options already saved. Just merge! the theme into an Axis."
},

{
    "location": "man/structs.html#",
    "page": "Building up figures",
    "title": "Building up figures",
    "category": "page",
    "text": ""
},

{
    "location": "man/structs.html#Building-up-figures-1",
    "page": "Building up figures",
    "title": "Building up figures",
    "category": "section",
    "text": "DocTestSetup = quote\n    using PGFPlotsX\nendThis section presents the structs used in PGFPlotsX to build up figures. An X after the struct name means that it supports option as described in the section on defining options."
},

{
    "location": "man/structs.html#Data-1",
    "page": "Building up figures",
    "title": "Data",
    "category": "section",
    "text": "There are multiple ways of representing data in PGFPlots:"
},

{
    "location": "man/structs.html#Coordinates-1",
    "page": "Building up figures",
    "title": "Coordinates",
    "category": "section",
    "text": "Coordinates a are a list of points (x,y) or (x,y,z). They can be created as:Coordinates(x, y, [z]) where x and y (and optionally z) are lists.\nCoordinates(points) where points is a list of tuples, e.g. x = [(1.0, 2.0), (2.0, 4.0)].For two-dimensional coordinates, errors can be added to Coordinates with the keywords:* `xerror`, `yerror` for symmetric errors\n* `xerrorplus` `yerrorplus` for positive errors\n* `xerrorminus` `yerrorminus` for positive errorsExamples:julia> x = [1, 2, 3]; y = [2, 4, 8]; z = [-1, -2, -3];\n\njulia> print_tex(Coordinates(x, y))\n    coordinates {\n    (1, 2)\n    (2, 4)\n    (3, 8)\n    }\n\njulia> print_tex(Coordinates(x, y, z))\n    coordinates {\n    (1, 2, -1)\n    (2, 4, -2)\n    (3, 8, -3)\n    }\n\njulia> print_tex(Coordinates(x, x.^3))\n\n    coordinates {\n    (1, 1)\n    (2, 8)\n    (3, 27)\n    }\n\njulia> print_tex(Coordinates([(1.0, 2.0), (2.0, 4.0)]))\n    coordinates {\n    (1.0, 2.0)\n    (2.0, 4.0)\n    }\n\njulia> c = Coordinates(x, y, xerror = [0.2, 0.3, 0.5], yerror = [0.2, 0.1, 0.5]);\n\njulia> print_tex(c)\n    coordinates {\n    (1, 2) +- (0.2, 0.2)\n    (2, 4) +- (0.3, 0.1)\n    (3, 8) +- (0.5, 0.5)\n    }"
},

{
    "location": "man/structs.html#Expression-1",
    "page": "Building up figures",
    "title": "Expression",
    "category": "section",
    "text": "An Expression is a string, representing a function and is written in a way LaTeX understands.Example:julia> ex = Expression(\"exp(-x^2)\");\n\njulia> print_tex(ex)\n    {exp(-x^2)}"
},

{
    "location": "man/structs.html#Table-X-1",
    "page": "Building up figures",
    "title": "Table - X",
    "category": "section",
    "text": "A table represents a matrix of data where each column is labeled. It can simply point to an external data file or store the data inline in the .tex file.Examples:julia> t = @pgf Table({x = \"Dof\"}, \"data.dat\");\n\njulia> print_tex(t)\n    table [x={Dof}]\n    {<ABSPATH>/data.dat}Inline data is constructed using a keyword constructor:julia> t = @pgf Table({x => \"Dof\", y => \"Err\"}, [:Dof => [1, 2, 4], :Err => [2.0, 1.0, 0.1]]);\n\njulia> print_tex(t)\n    table [x={Dof}, y={Err}]\n    {Dof  Err\n    1.0  2.0\n    2.0  1.0\n    4.0  0.1\n    }If you load the DataFrames package, you can also create tables from data frames, see the examples in Julia types."
},

{
    "location": "man/structs.html#Graphics-X-1",
    "page": "Building up figures",
    "title": "Graphics - X",
    "category": "section",
    "text": "Graphics data simply wraps an image like a .png. It is constructed as Graphics(filepath) where filepath is the path to the image.Example:julia> print_tex(Graphics(\"img.png\"))\n    graphics []\n    {img.png}"
},

{
    "location": "man/structs.html#Plots-1",
    "page": "Building up figures",
    "title": "Plots",
    "category": "section",
    "text": "A plot is an element inside an axis. It could be a simple line or a 3d surface etc. A plot is created by wrapping one of the structs shown above."
},

{
    "location": "man/structs.html#Plot-X-1",
    "page": "Building up figures",
    "title": "Plot - X",
    "category": "section",
    "text": "A keyword argument incremental::Bool is used to determine if \\addplot+ (default) should be used or \\addplot.Example:julia> p = @pgf Plot(Table(\"plotdata/invcum.dat\"), { blue }; incremental = false);\n\njulia> print_tex(p)\n    \\addplot[blue]\n        table []\n        {<ABSPATH>/plotdata/invcum.dat}\n    ;"
},

{
    "location": "man/structs.html#Plot3-X-1",
    "page": "Building up figures",
    "title": "Plot3 - X",
    "category": "section",
    "text": "Plot3 will use the \\addplot3 command instead of \\addplot to draw 3d graphics. Otherwise it works the same as Plot.Example:julia> x, y, z = [1, 2, 3], [2, 4, 8], [3, 9, 27];\n\njulia> p = @pgf Plot3(Coordinates(x, y, z), { very_thick });\n\njulia> print_tex(p)\n    \\addplot3+[very thick]\n        coordinates {\n        (1, 2, 3)\n        (2, 4, 9)\n        (3, 8, 27)\n        }\n    ;"
},

{
    "location": "man/structs.html#Axis-like-1",
    "page": "Building up figures",
    "title": "Axis-like",
    "category": "section",
    "text": ""
},

{
    "location": "man/structs.html#Axis-X-1",
    "page": "Building up figures",
    "title": "Axis - X",
    "category": "section",
    "text": "Axis make up the labels and titles etc in the figure and is the standard way of wrapping plots, represented in tex as\\begin{axis}[...]\n    ...\n\\end{axis}Examples:julia> @pgf a = Axis( Plot( Expression(\"x^2\")), {\n              xlabel = \"x\"\n              ylabel = \"y\"\n              title = \"Figure\"\n          });\n\njulia> print_tex(a)\n    \\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]\n        \\addplot+[]\n            {x^2}\n        ;\n    \\end{axis}\n\njulia> push!(a, Plot(Coordinates([1,2], [3,4])));\n\n\njulia> print_tex(a)\n    \\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]\n        \\addplot+[]\n            {x^2}\n        ;\n        \\addplot+[]\n            coordinates {\n            (1, 3)\n            (2, 4)\n            }\n        ;\n    \\end{axis}Any struct can be pushed in to an Axis. What will be printed is the result of PGFPlotsX.print_tex(io::IO, t::T, ::Axis) where T is the type of the struct. Pushed strings are written out verbatim."
},

{
    "location": "man/structs.html#GroupPlot-X-1",
    "page": "Building up figures",
    "title": "GroupPlot - X",
    "category": "section",
    "text": "A GroupPlot is a way of grouping multiple plots in one figure.Example:julia> @pgf gp = GroupPlot({group_style = { group_size = \"2 by 1\",}, height = \"6cm\", width = \"6cm\"});\n\njulia> for (expr, data) in zip([\"x^2\", \"exp(x)\"], [\"data1.dat\", \"data2.dat\"])\n           push!(gp, [Plot(Expression(expr)),  Plot(Table(data))])\n       end;\n\njulia> print_tex(gp)\n    \\begin{groupplot}[group style={group size={2 by 1}}, height={6cm}, width={6cm}]\n        \\nextgroupplot[]\n\n        \\addplot+[]\n            {x^2}\n        ;\n        \\addplot+[]\n            table []\n            {data1.dat}\n        ;\n        \\nextgroupplot[]\n\n        \\addplot+[]\n            {exp(x)}\n        ;\n        \\addplot+[]\n            table []\n            {data2.dat}\n        ;\n    \\end{groupplot}In order to add options to the \\nextgroupplot call simply add arguments in an \"option like way\" (using strings / pairs / @pgf) when you push!julia> @pgf gp = GroupPlot({group_style = { group_size = \"1 by 1\",}, height = \"6cm\", width = \"6cm\"});\n\njulia> @pgf for (expr, data) in zip([\"x^2\"], [\"data2.dat\"])\n           push!(gp, [Plot(Expression(expr)),  Plot(Table(data))], {title = \"Data $data\"})\n       end;\n\njulia> print_tex(gp)\n    \\begin{groupplot}[group style={group size={1 by 1}}, height={6cm}, width={6cm}]\n        \\nextgroupplot[title={Data data2.dat}]\n\n        \\addplot+[]\n            {x^2}\n        ;\n        \\addplot+[]\n            table []\n            {data2.dat}\n        ;\n    \\end{groupplot}"
},

{
    "location": "man/structs.html#PolarAxis-1",
    "page": "Building up figures",
    "title": "PolarAxis",
    "category": "section",
    "text": "A PolarAxis plot data on a polar grid.Example:julia> p = PolarAxis( Plot( Coordinates([0, 90, 180, 270], [1, 1, 1, 1])));\n\njulia> print_tex(p)\n    \\begin{polaraxis}[]\n        \\addplot+[]\n            coordinates {\n            (0, 1)\n            (90, 1)\n            (180, 1)\n            (270, 1)\n            }\n        ;\n    \\end{polaraxis}"
},

{
    "location": "man/structs.html#Legend-1",
    "page": "Building up figures",
    "title": "Legend",
    "category": "section",
    "text": "A Legend can be used to add legends to plots.Example:julia> print_tex(Legend([\"Plot A\", \"Plot B\"]))\n\\legend{Plot A, Plot B}"
},

{
    "location": "man/structs.html#TikzPicture-X-1",
    "page": "Building up figures",
    "title": "TikzPicture - X",
    "category": "section",
    "text": "A TikzPicture can contain multiple Axis\'s or GroupPlot\'s.Example:julia> tp = TikzPicture(Axis(Plot(Coordinates([1, 2], [2, 4]))), \"scale\" => 1.5);\n\njulia> print_tex(tp)\n\\begin{tikzpicture}[scale={1.5}]\n    \\begin{axis}[]\n        \\addplot+[]\n            coordinates {\n            (1, 2)\n            (2, 4)\n            }\n        ;\n    \\end{axis}\n\\end{tikzpicture}"
},

{
    "location": "man/structs.html#TikzDocument-1",
    "page": "Building up figures",
    "title": "TikzDocument",
    "category": "section",
    "text": "A TikzDocument is the highest level object and represents a whole .tex file. It includes a list of objects that will sit between \\begin{document} and \\end{document}.A very simple example where we simply create a TikzDocument with a string in is shown below. Normally you would also push Axis\'s that contain plots.julia> td = TikzDocument();\n\njulia> push!(td, \"Hello World\");\n\njulia> print_tex(td)\n\\RequirePackage{luatex85}\n\\documentclass[tikz]{standalone}\n    % Default preamble\n    \\usepackage{pgfplots}\n    \\pgfplotsset{compat=newest}\n    \\usepgfplotslibrary{groupplots}\n    \\usepgfplotslibrary{polar}\n    \\usepgfplotslibrary{statistics}\n\\begin{document}\n    Hello World\n\n\\end{document}note: Note\nThere is usually no need to explicitly create a TikzDocument or TikzPicture. Only do this if you want to give special options to them. It is possible to show or save an Axis or e.g. a Plot directly, and they will then be wrapped in the default \"higher level\" objects."
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
    "location": "man/save.html#Jupyter-1",
    "page": "Showing / Exporting figures",
    "title": "Jupyter",
    "category": "section",
    "text": "Figures are shown in svg format when evaluated in Jupyter. For this you need the pdf2svg software installed. If you want to show them in png format (because perhaps is too large), you can use display(MIME\"image/png\", p) where p is the figure to show."
},

{
    "location": "man/save.html#Juno-1",
    "page": "Showing / Exporting figures",
    "title": "Juno",
    "category": "section",
    "text": "Figures are shown in the Juno plot pane as svgs by default. If you want to show them as png, run show_juno_png(true), (false to go back to svg). To set the dpi of the figures in Juno when using png, run dpi_juno_png(dpi::Int)"
},

{
    "location": "man/save.html#REPL-1",
    "page": "Showing / Exporting figures",
    "title": "REPL",
    "category": "section",
    "text": "In the REPL, the figure will be exported to a pdf and attempted to be opened in the default pdf viewing program. If you wish to disable this, run pgf.enable_interactive(false)."
},

{
    "location": "man/save.html#Exporting-to-files-1",
    "page": "Showing / Exporting figures",
    "title": "Exporting to files",
    "category": "section",
    "text": "Figures can be exported to files usingPGFPlotsX.save(filename::String, figure; include_preamble::Bool = true, dpi = 150)where the file extension of filename determines the file type (can be pdf, svg or tex, or the standalone tikz file extensions below), include_preamble sets if the preamble should be included in the output (only relevant for tex export) and dpi determines the dpi of the figure (only relevant for png export).The standalone file extensions .tikz, .TIKZ, .TikZ, .pgf, .PGF save LaTeX code for a tikzpicture environment without a preamble. You can \\input them directly into a LaTeX document, or use the the tikzscale LaTeX package for using \\includegraphics with possible size adjustments."
},

{
    "location": "man/save.html#Customizing-the-preamble-1",
    "page": "Showing / Exporting figures",
    "title": "Customizing the preamble",
    "category": "section",
    "text": "It is common to use a custom preamble to add user-defined macros or use different packages. There are a few ways to do this:push! strings into the global variable CUSTOM_PREAMBLE. Each string in that vector will be inserted in the preamble.\nModify the custom_premble.tex file in the deps folder of the directory of the package. This file is directly spliced into the preamble of the output.\nDefine the environment variable PGFPLOTSX_PREAMBLE_PATH to a path pointing to a preamble file. The content of that will be inserted into the preamble."
},

{
    "location": "man/save.html#Choosing-the-LaTeX-engine-used-1",
    "page": "Showing / Exporting figures",
    "title": "Choosing the LaTeX engine used",
    "category": "section",
    "text": "Thee are two different choices for latex engines, PDFLATEX, LUALATEX. By default, LUALATEX is used if it was available during Pkg.build(). The active engine can be retrieved with the latexengine() function and be set with latexengine!(engine) where engine is one of the two previously mentioned engines (e.g. PGFPlotsX.PDFLATEX)."
},

{
    "location": "man/save.html#Custom-flags-1",
    "page": "Showing / Exporting figures",
    "title": "Custom flags",
    "category": "section",
    "text": "Custom flags to the engine can be used in the latex command by push!-ing them into the global variable CUSTOM_FLAGS."
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
    "text": "using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    PGFPlotsX.save(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    PGFPlotsX.save(figname * \".tex\", obj);\n    return nothing\nendUse Coordinates to construct the pgfplots construct coordinates. Various constructors are available.For basic usage, consider AbstractVectors and iterables. Notice how non-finite values are skipped. You can also use () or nothing for jumps in functions.x = linspace(-1, 1, 51) # so that it contains 1/0\n@pgf Axis(\n    {\n        xmajorgrids,\n        ymajorgrids,\n    },\n    Plot(\n        {\n            no_marks,\n        },\n        Coordinates(x, 1 ./ x)\n    )\n)\nsavefigs(\"coordinates-simple\", ans) # hide[.pdf], [generated .tex](Image: )Use xerror, xerrorplus, xerrorminus, yerror etc. for error bars.x = linspace(0, 2π, 20)\n@pgf Plot(\n    {\n        \"no marks\",\n        \"error bars/y dir=both\",\n        \"error bars/y explicit\",\n    },\n    Coordinates(x, sin.(x); yerror = 0.2*cos.(x))\n)\nsavefigs(\"coordinates-errorbars\", ans) # hide[.pdf], [generated .tex](Image: )Use three vectors to construct 3D coordinates.t = linspace(0, 6*π, 100)\n@pgf Plot3(\n    {\n        no_marks,\n    },\n    Coordinates(t .* sin.(t), t .* cos.(t), .-t)\n)\nsavefigs(\"coordinates-3d\", ans) # hide[.pdf], [generated .tex](Image: )A convenience constructor is available for plotting a matrix of values calculated from edge vectors.x = linspace(-2, 2, 20)\ny = linspace(-0.5, 3, 25)\nf(x, y) = (1 - x)^2 + 100*(y - x^2)^2\n@pgf Plot3(\n    {\n        surf,\n    },\n    Coordinates(x, y, f.(x, y\'))\n)\nsavefigs(\"coordinates-3d-matrix\", ans) # hide[.pdf], [generated .tex](Image: )x = linspace(-2, 2, 40)\ny = linspace(-0.5, 3, 50)\n@pgf Axis(\n    {\n        view = (0, 90),\n        colorbar,\n        \"colormap/jet\",\n    },\n    Plot3(\n        {\n            surf,\n            shader = \"flat\",\n        },\n        Coordinates(x, y, @. √(f(x, y\')))\n    )\n)\nsavefigs(\"coordinates-3d-matrix-heatmap\", ans) # hide[.pdf], [generated .tex](Image: )"
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
    "text": "Tables are coordinates in a tabular format (essentially a matrix), optionally with named columns. They have various constructors, for direct construction and also for conversion from other types.using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    PGFPlotsX.save(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    PGFPlotsX.save(figname * \".tex\", obj);\n    return nothing\nendLetx = linspace(0, 2*pi, 100)\ny = sin.(x)x = linspace(0, 2*pi, 100)\ny = sin.(x)You can pass these coordinates in unnamed columns:Plot(Table([x, y]))\nsavefigs(\"table-unnamed-columns\", ans) # hide[.pdf], [generated .tex](Image: )or named columns:Plot(Table([:x => x, :y => y]))\nsavefigs(\"table-named-columns\", ans) # hide[.pdf], [generated .tex](Image: )or rename using options:@pgf Plot(\n    {\n        x = \"a\",\n        y = \"b\",\n    },\n    Table([:a => x, :b => y]))\nsavefigs(\"table-dict-rename\", ans) # hide[.pdf], [generated .tex](Image: )In the example below, we use a matrix of values with edge vectors, and omit the points outside the unit circle:x = linspace(-1, 1, 20)\nz = @. 1 - √(abs2(x) + abs2(x\'))\nz[z .≤ 0] .= -Inf\n@pgf Axis(\n    {\n        colorbar,\n        \"colormap/jet\",\n        \"unbounded coords\" = \"jump\"\n    },\n    Plot3(\n        {\n            surf,\n            shader = \"flat\",\n        },\n        Table(x, x, z)\n    )\n)\nsavefigs(\"table-jump-3d\", ans) # hide[.pdf], [generated .tex](Image: )"
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
    "text": "using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    PGFPlotsX.save(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    PGFPlotsX.save(figname * \".tex\", obj);\n    return nothing\nendx = linspace(0, 2*pi, 100)\n@pgf GroupPlot(\n    {\n        group_style =\n        {\n            group_size=\"2 by 1\",\n            xticklabels_at=\"edge bottom\",\n            yticklabels_at=\"edge left\"\n        },\n        no_markers\n    },\n    {},\n    PlotInc(Table(x, sin.(x))),\n    PlotInc(Table(x, sin.(x .+ 0.5))),\n    {},\n    PlotInc(Table(x, cos.(x))),\n    PlotInc(Table(x, cos.(x .+ 0.5))))\nsavefigs(\"groupplot-multiple\", ans) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/gallery.html#",
    "page": "PGFPlots manual gallery",
    "title": "PGFPlots manual gallery",
    "category": "page",
    "text": ""
},

{
    "location": "examples/gallery.html#PGFPlots-manual-gallery-1",
    "page": "PGFPlots manual gallery",
    "title": "PGFPlots manual gallery",
    "category": "section",
    "text": "Examples converted from the PGFPlots manual gallery. This is a work in progress.using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    PGFPlotsX.save(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    PGFPlotsX.save(figname * \".tex\", obj);\n    return nothing\nend@pgf Axis(\n    {\n        xlabel = \"Cost\",\n        ylabel = \"Error\",\n    },\n    Plot(\n        {\n            color = \"red\",\n            mark  = \"x\"\n        },\n        Coordinates(\n            [\n                (2, -2.8559703),\n                (3, -3.5301677),\n                (4, -4.3050655),\n                (5, -5.1413136),\n                (6, -6.0322865),\n                (7, -6.9675052),\n                (8, -7.9377747),\n            ]\n        ),\n    ),\n)\nsavefigs(\"cost-error\", ans) # hide[.pdf], [generated .tex](Image: )using LaTeXStrings\n@pgf Axis(\n    {\n        xlabel = L\"x\",\n        ylabel = L\"f(x) = x^2 - x + 4\"\n    },\n    Plot(\n        Expression(\"x^2 - x + 4\")\n    )\n)\nsavefigs(\"simple-expression\", ans) # hide[.pdf], [generated .tex](Image: )@pgf Axis(\n    {\n        height = \"9cm\",\n        width = \"9cm\",\n        grid = \"major\",\n    },\n    [\n        PlotInc(Expression(\"-x^5 - 242\")),\n        LegendEntry(\"model\"),\n        PlotInc(Coordinates(\n            [\n                (-4.77778,2027.60977),\n                (-3.55556,347.84069),\n                (-2.33333,22.58953),\n                (-1.11111,-493.50066),\n                (0.11111,46.66082),\n                (1.33333,-205.56286),\n                (2.55556,-341.40638),\n                (3.77778,-1169.24780),\n                (5.00000,-3269.56775),\n            ]\n        )),\n        LegendEntry(\"estimate\")\n    ]\n)\nsavefigs(\"cost-gain\", ans) # hide[.pdf], [generated .tex](Image: )@pgf Axis(\n    {\n        xlabel = \"Cost\",\n        ylabel = \"Gain\",\n        xmode = \"log\",\n        ymode = \"log\",\n    },\n    Plot(\n        {\n            color = \"red\",\n            mark  = \"x\"\n        },\n        Coordinates(\n            [\n                (10, 100),\n                (20, 150),\n                (40, 225),\n                (80, 340),\n                (160, 510),\n                (320, 765),\n                (640, 1150),\n            ]\n        )\n    )\n)\nsavefigs(\"cost-gain-log-log\", ans) # hide[.pdf], [generated .tex](Image: )@pgf Axis(\n    {\n        xlabel = \"Cost\",\n        ylabel = \"Gain\",\n        ymode = \"log\",\n    },\n    Plot(\n        {\n            color = \"blue\",\n            mark  = \"*\"\n        },\n        Coordinates(\n            [\n                (1, 8)\n                (2, 16)\n                (3, 32)\n                (4, 64)\n                (5, 128)\n                (6, 256)\n                (7, 512)\n            ]\n        )\n    )\n)\nsavefigs(\"cost-gain-ylog\", ans) # hide[.pdf], [generated .tex](Image: )using LaTeXStrings\n@pgf Axis(\n    {\n        xlabel = \"Degrees of freedom\",\n        ylabel = L\"$L_2$ Error\",\n        xmode  = \"log\",\n        ymode  = \"log\",\n    },\n    [\n        Plot(Coordinates(\n            [(   5, 8.312e-02), (  17, 2.547e-02), (  49, 7.407e-03),\n             ( 129, 2.102e-03), ( 321, 5.874e-04), ( 769, 1.623e-04),\n             (1793, 4.442e-05), (4097, 1.207e-05), (9217, 3.261e-06),]\n        )),\n\n        Plot(Coordinates(\n            [(   7, 8.472e-02), (   31, 3.044e-02), (111,   1.022e-02),\n             ( 351, 3.303e-03), ( 1023, 1.039e-03), (2815,  3.196e-04),\n             (7423, 9.658e-05), (18943, 2.873e-05), (47103, 8.437e-06),]\n        )),\n\n        Plot(Coordinates(\n            [(    9, 7.881e-02), (   49, 3.243e-02), (   209, 1.232e-02),\n             (  769, 4.454e-03), ( 2561, 1.551e-03), (  7937, 5.236e-04),\n             (23297, 1.723e-04), (65537, 5.545e-05), (178177, 1.751e-05),]\n        )),\n\n        Plot(Coordinates(\n            [(   11, 6.887e-02), (    71, 3.177e-02), (   351, 1.341e-02),\n             ( 1471, 5.334e-03), (  5503, 2.027e-03), ( 18943, 7.415e-04),\n             (61183, 2.628e-04), (187903, 9.063e-05), (553983, 3.053e-05),]\n        )),\n\n        Plot(Coordinates(\n            [(    13, 5.755e-02), (    97, 2.925e-02), (    545, 1.351e-02),\n             (  2561, 5.842e-03), ( 10625, 2.397e-03), (  40193, 9.414e-04),\n             (141569, 3.564e-04), (471041, 1.308e-04), (1496065, 4.670e-05),]\n        )),\n    ]\n)\nsavefigs(\"dof-error\", ans) # hide[.pdf], [generated .tex](Image: )@pgf Axis(\n    {\n        \"scatter/classes\" = {\n            a = {mark = \"square*\", \"blue\"},\n            b = {mark = \"triangle*\", \"red\"},\n            c = {mark = \"o\", draw = \"black\"},\n        }\n    },\n    Plot(\n        {\n            scatter,\n            \"only marks\",\n            \"scatter src\" = \"explicit symbolic\",\n        },\n        Table(\n            {\n                meta = \"label\"\n            },\n            x = [0.1, 0.45, 0.02, 0.06, 0.9 , 0.5 , 0.85, 0.12, 0.73, 0.53, 0.76, 0.55],\n            y = [0.15, 0.27, 0.17, 0.1, 0.5, 0.3, 0.52, 0.05, 0.45, 0.25, 0.5, 0.32],\n            label = [\"a\", \"c\", \"a\", \"a\", \"b\", \"c\", \"b\", \"a\", \"b\", \"c\", \"b\", \"c\"],\n        )\n    )\n)\nsavefigs(\"table-label\", ans) # hide[.pdf], [generated .tex](Image: )@pgf Axis(\n    {\n        \"nodes near coords\" = raw\"(\\coordindex)\",\n        title = raw\"\\texttt{patch type=quadratic spline}\",\n    },\n    Plot(\n        {\n            mark = \"*\",\n            patch,\n            mesh, # without mesh, pgfplots tries to fill,\n            # \"patch type\" = \"quadratic spline\", <- Should work??\n        },\n        Coordinates(\n            [\n                # left, right, middle-> first segment\n                (0, 0),   (1, 1),   (0.5, 0.5^2),\n                # left, right, middle-> second segment\n                (1.2, 1), (2.2, 1), (1.7, 2),\n            ]\n        )\n    )\n)\nsavefigs(\"spline-quadratic\", ans) # hide[.pdf], [generated .tex](Image: )@pgf Plot3(\n    {\n        mesh,\n        scatter,\n        samples = 10,\n        domain = 0:1\n    },\n    Expression(\"x * (1-x) * y * (1-y)\")\n)\nsavefigs(\"mesh-scatter\", ans) # hide[.pdf], [generated .tex](Image: )# this is an imitation of the figure in the manual, as we generate the data\nx = linspace(0, 10, 100)\n@pgf plot = Plot({very_thick}, Table(x = x, y = @. (sin(x * 8) + 1) * 4 * x))\n@pgf GroupPlot(\n    {\n        group_style =\n        {\n            group_size=\"2 by 2\",\n            horizontal_sep=\"0pt\",\n            vertical_sep=\"0pt\",\n            xticklabels_at=\"edge bottom\"\n        },\n        xmin = 0,\n        ymin = 0,\n        height = \"3.7cm\",\n        width = \"4cm\",\n        no_markers\n    },\n    nothing,\n    {xmin=5, xmax=10, ymin=50, ymax=100},\n    plot,\n    {xmax=5, ymax=50},\n    plot,\n    {xmin=5, xmax=10, ymax=50, yticklabels={}},\n    plot)\nsavefigs(\"groupplot-nested\", ans) # hide[.pdf], [generated .tex](Image: )"
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
    "text": "There is some support to directly use Julia objects from different popular packages in PGFPlotsX.jl. Examples of these are given here.using PGFPlotsX\nsavefigs = (figname, obj) -> begin\n    PGFPlotsX.save(figname * \".pdf\", obj)\n    run(`pdf2svg $(figname * \".pdf\") $(figname * \".svg\")`)\n    PGFPlotsX.save(figname * \".tex\", obj);\n    return nothing\nend"
},

{
    "location": "examples/juliatypes.html#Colors.jl-1",
    "page": "Julia types",
    "title": "Colors.jl",
    "category": "section",
    "text": "Using a colorant as the line colorusing Colors\nμ = 0\nσ = 1e-3\n\naxis = Axis()\n@pgf for (i, col) in enumerate(distinguishable_colors(10))\n    offset = i * 50\n    p = Plot(\n        {\n            color = col,\n            domain = \"-3*$σ:3*$σ\",\n            style = { ultra_thick },\n            samples = 50\n        },\n        Expression(\"exp(-(x-$μ)^2 / (2 * $σ^2)) / ($σ * sqrt(2*pi)) + $offset\"))\n    push!(axis, p)\nend\naxis\nsavefigs(\"colors\", ans) # hide[.pdf], [generated .tex](Image: )Using a colormapusing Colors\np = @pgf Plot3(\n    {\n        surf,\n        point_meta = \"y\",\n        samples = 13\n    },\n    Expression(\"cos(deg(x)) * sin(deg(y))\")\n)\ncolormaps = [\"Blues\", \"Greens\", \"Oranges\", \"Purples\"]\ntd = TikzDocument()\nfor cmap in colormaps\n    push_preamble!(td, (cmap, Colors.colormap(cmap)))\nend\n\ntp = TikzPicture(\"scale\" => 0.5)\npush!(td, tp)\ngp = @pgf GroupPlot({ group_style = {group_size = \"2 by 2\"}})\npush!(tp, gp)\n\nfor cmap in colormaps\n    @pgf push!(gp, { colormap_name = cmap }, p)\nend\nsavefigs(\"colormap\", td) # hide[.pdf], [generated .tex](Image: )"
},

{
    "location": "examples/juliatypes.html#DataFrames.jl-1",
    "page": "Julia types",
    "title": "DataFrames.jl",
    "category": "section",
    "text": "Creating a Table from a DataFrame will write it as expected.using RDatasets\ndf = dataset(\"datasets\", \"iris\") # load the dataset\n\n@pgf Axis(\n    {\n        legend_pos = \"south east\",\n        xlabel = \"Sepal length\",\n        ylabel = \"Sepal width\",\n    },\n    [Plot(\n        {\n            scatter,\n            \"only marks\",\n            \"scatter src\"=\"explicit symbolic\",\n            \"scatter/classes\"=\n            {\n                setosa     = {mark = \"square*\",   \"blue\"},\n                versicolor = {mark = \"triangle*\", \"red\"},\n                virginica  = {mark = \"o\",         \"black\"},\n            }\n        },\n        Table(\n            {\n                x = \"SepalLength\",\n                y = \"SepalWidth\",\n                meta = \"Species\"\n            },\n            df, # <--- Creating a Table from a DataFrame\n        )\n    ),\n     Legend([\"Setosa\", \"Versicolor\", \"Virginica\"])\n     ]\n)\nsavefigs(\"dataframes\", ans) # hide[.pdf], [generated .tex](Image: )"
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
    "text": "StatsBase.Histogram can be plotted using Table, both for 1D and 2D histograms.using StatsBase: Histogram, fit\n@pgf Axis(\n    {\n        \"ybar interval\",\n        \"xticklabel interval boundaries\",\n        xmajorgrids = false,\n        xticklabel = raw\"$[\\pgfmathprintnumber\\tick,\\pgfmathprintnumber\\nexttick)$\",\n        \"xticklabel style\" =\n        {\n            font = raw\"\\tiny\"\n        },\n    },\n    Plot(Table(fit(Histogram, linspace(0, 1, 100).^3, closed = :left))))\nsavefigs(\"histogram-1d\", ans) # hide[.pdf], [generated .tex](Image: )using StatsBase: Histogram, fit\nw = linspace(-1, 1, 100) .^ 3\nxy = vec(tuple.(w, w\'))\nh = fit(Histogram, (first.(xy), last.(xy)), closed = :left)\n@pgf Axis(\n    {\n        view = (0, 90),\n        colorbar,\n        \"colormap/jet\"\n    },\n    Plot3(\n        {\n            surf,\n            shader = \"flat\",\n\n        },\n        Table(h))\n)\nsavefigs(\"histogram-2d\", ans) # hide[.pdf], [generated .tex](Image: )"
},

]}
