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
    "text": "PGFPlotsX is a Julia package to generate publication quality figures using the LaTeX library PGFPlots.It is similar in spirit to the package PGFPlots.jl but it tries to have a very close mapping to the PGFPlots API as well as minimize the number of dependencies. The fact that the syntax is similar to the TeX version means that examples from Stack Overflow and the PGFPlots manual can easily be incorporated in the Julia code.Documentation is a WIP but a quite extensive set of examples can be found at the PGFPlotsXExamples repo."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Pkg.add(\"PGFPlotsX\")"
},

{
    "location": "index.html#Manual-Outline-1",
    "page": "Home",
    "title": "Manual Outline",
    "category": "section",
    "text": "note: Note\nPGFPlotsX does not export anything. In the manual we assume that the command import PGFPlotsX; const pgf = PGFPlotsX has been runPages = [\n    \"man/options.md\",\n    \"man/structs.md\",\n    \"man/save.md\",\n    \"man/custom_types.md\",\n]\nDepth = 1"
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
    "text": "In PGFPlots, options are given as a list of keys that might have corresponding values inside of two square brackets e.g.\\begin{axis}[ybar, width = 4.5cm]\n...\n\\end{axis}This section shows the method for which to set and retrieve such options.note: Note\nSometimes examples are more telling than documentation so please check out the examples."
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
    "text": "When constructing an object (like a Plot), options to that object can be entered in the argument list where a string represents a key without a value (e.g. \"very thick\") and a pair represents a key/value option, (e.g. \"samples\" => 50). This works well when the options are few and there is only one level of options in the object.julia> c = pgf.Coordinates([1,2,3], [2, 4, 8]);\n\njulia> p = pgf.Plot(c, \"very thick\", \"mark\" => \"halfcircle\");\n\njulia> pgf.print_tex(p); # print_tex is typically not called from user code\n\\addplot+[very thick, mark={halfcircle}]\n        coordinates {\n        (1, 2)\n        (2, 4)\n        (3, 8)\n        }\n    ;"
},

{
    "location": "man/options.html#The-@pgf-macro-1",
    "page": "Defining options",
    "title": "The @pgf macro",
    "category": "section",
    "text": "When there are nested options the previous method does not work so well. Instead, we provide a macro @pgf so that options can be entered similarly to how they are in tex.The previous example is then written aspgf.@pgf pgf.Plot(c,\n    {\n        very_thick,\n        mark = \"halfcircle\"\n    });A more complicated example is:pgf.@pgf p2 = pgf.Plot(c,\n    {\n        \"axis background/.style\" =\n        {\n            shade,\n            top_color = \"gray\",\n            bottom_color = \"white\",\n        },\n        ymode = \"log\"\n    }\n)which is printed asjulia> pgf.print_tex(p2)\n    \\addplot+[axis background/.style={shade, top color={gray}, bottom color={white}}, ymode={log}]\n        coordinates {\n        (1, 2)\n        (2, 4)\n        (3, 8)\n        }\n    ;The macro can be applied to any type of expression and will be applied to everything inside that expression that is of the form { expr }.!!!note     * Keys that contain symbols that in Julia are operators (e.g the key \"axis background/.style\") has to be entered       as strings, as in the example above."
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
    "text": "It is sometimes convenient to set and get options after an object has been created.julia> c = pgf.Coordinates([1,2,3], [2, 4, 8]);\n\njulia> p = pgf.Plot(c)\n\njulia> p[\"fill\"] = \"blue\";\n\njulia> p[\"fill\"]\n\"blue\"\n\njulia> pgf.@pgf p[\"axis background/.style\"] = { shade, top_color = \"gray\", bottom_color = \"white\" };\n\njulia> p[\"axis background/.style\"][\"top_color\"]\n\"gray\"\n\njulia> p[\"very tick\"] = nothing # Set a value less options\n\njulia> delete!(p, \"fill\")\n\njulia> pgf.print_tex(p)\n    \\addplot+[axis background/.style={shade, top color={gray}, bottom color={white}}, very tick]\n        coordinates {\n        (1, 2)\n        (2, 4)\n        (3, 8)\n        }\n    ;You can also merge in options that have been separately created using merge!julia> a = pgf.Axis()\n\njulia> pgf.@pgf opts =  {xmin = 0, ymax = 1, ybar};\n\njulia> merge!(a, opts)\n\njulia> pgf.print_tex(a)\n    \\begin{axis}[xmin={0}, ymax={1}, ybar]\n    \\end{axis}It is then easy to apply for example a \"theme\" to an axis where the themed is a set of options already saved."
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
    "text": "This section presents the structs used in PGFPlotsX to build up figures. An X after the struct name means that it supports option as described in"
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
    "text": "Coordinates a are a list of points (x,y) or (x,y,z). They can be created as:Coordinates(x, y, [z]) where x and y (and optionally z) are lists.\nCoordinates(x, f2) or Coordinates(x, y, f3) where x and y are lists and f2, f3 are functions taking one and two arguments respectively.\nCoordinates(points) where points is a list of tuples, e.g. x = [(1.0, 2.0), (2.0, 4.0)].For two dimensional coordinates, errors can be added to Coordinates with the keywords:* `xerror`, `yerror` for symmetric errors\n* `xerrorplus` `yerrorplus` for positive errors\n* `xerrorminus` `yerrorminus` for positive errorsExamples:julia> x = [1, 2, 3]; y = [2, 4, 8]; z = [-1, -2, -3];\n\njulia> pgf.print_tex(pgf.Coordinates(x, y))\n    coordinates {\n    (1, 2)\n    (2, 4)\n    (3, 8)\n    }\n\njulia> pgf.print_tex(pgf.Coordinates(x, y, z))\n    coordinates {\n    (1, 2, -1)\n    (2, 4, -2)\n    (3, 8, -3)\n    }\n\njulia> pgf.print_tex(pgf.Coordinates(x, x -> x^3))\n\n    coordinates {\n    (1, 1)\n    (2, 8)\n    (3, 27)\n    }\n\njulia> pgf.print_tex(pgf.Coordinates([(1.0, 2.0), (2.0, 4.0)]))\n    coordinates {\n    (1.0, 2.0)\n    (2.0, 4.0)\n    }\n\njulia> c = pgf.Coordinates(x, y, xerror = [0.2, 0.3, 0.5], yerror = [0.2, 0.1, 0.5]);\n\njulia> pgf.print_tex(c)\n    coordinates {\n    (1, 2)+-(0.2, 0.2)\n    (2, 4)+-(0.3, 0.1)\n    (3, 8)+-(0.5, 0.5)\n    }"
},

{
    "location": "man/structs.html#Expression-1",
    "page": "Building up figures",
    "title": "Expression",
    "category": "section",
    "text": "An Expression is a string, representing a function and is written in a way LaTeX understands.Example:julia> ex = pgf.Expression(\"exp(-x^2)\");\n\njulia> pgf.print_tex(ex)\n    {exp(-x^2)}"
},

{
    "location": "man/structs.html#Table-X-1",
    "page": "Building up figures",
    "title": "Table - X",
    "category": "section",
    "text": "A table represents a matrix of data where each column is labeled. It can simply point to an external data file or store the data inline in the .tex file.Examples:julia> t = pgf.Table(\"data.dat\", \"x\" => \"Dof\");\n\njulia> pgf.print_tex(t)\n    table [x={Dof}]\n    {data.dat}Inline data is constructed using a keyword constructor:julia> t = pgf.Table(\"x\" => \"Dof\", \"y\" => \"Err\"; Dof = rand(3), Err = rand(3));\n\njulia> pgf.print_tex(t)\n    table [x={Dof}, y={Err}]\n    {Dof    Err    \n    0.6073590230719768    0.36281513247882136    \n    0.7285438246638971    0.11629575623266741    \n    0.29590973933842424    0.9782972101143201    \n    }If you load the DataFrames package, you can also create tables from data frames, see the TODO"
},

{
    "location": "man/structs.html#Graphics-X-1",
    "page": "Building up figures",
    "title": "Graphics - X",
    "category": "section",
    "text": "Graphics data simply wraps an image like a .png. It is constructed as Graphics(filepath) where filepath is the path to the image.Example:julia> pgf.print_tex(pgf.Graphics(\"img.png\"))\n    graphics []\n    {img.png}"
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
    "text": "A keyword argument incremental::Bool is used to determine if \\addplot+ (default) should be used or \\addplot.Example:julia> p = pgf.@pgf pgf.Plot(pgf.Table(\"plotdata/invcum.dat\"), { blue }; incremental = false);\n\njulia> pgf.print_tex(p)\n    \\addplot[blue]\n        table []\n        {plotdata/invcum.dat}\n    ;"
},

{
    "location": "man/structs.html#Plot3-X-1",
    "page": "Building up figures",
    "title": "Plot3 - X",
    "category": "section",
    "text": "Plot3 will use the \\addplot3 command instead of \\addplot to draw 3d graphics. Otherwise it works the same as Plot.Example:julia> x, y, z = rand(3), rand(3), rand(3);\n\njulia> p = pgf.@pgf pgf.Plot3(pgf.Coordinates(x,y,z), { very_thick });\n\njulia> pgf.print_tex(p)\n    \\addplot3+[very thick]\n        coordinates {\n        (0.7399041050338018, 0.4333342656950161, 0.31102760595379864)\n        (0.8533903392895954, 0.4437618168514108, 0.05325494618659876)\n        (0.4871968750637172, 0.09021596022672318, 0.817385325577578)\n        }\n    ;"
},

{
    "location": "man/structs.html#Axis-like-1",
    "page": "Building up figures",
    "title": "Axis-like",
    "category": "section",
    "text": ""
},

{
    "location": "man/structs.html#Axis-1",
    "page": "Building up figures",
    "title": "Axis",
    "category": "section",
    "text": "Axis make up the labels and titles etc in the figure and is the standard way of wrapping plots, represented in tex as\\begin{axis}[...]\n    ...\n\\end{axis}Examples:julia> pgf.@pgf a = pgf.Axis( pgf.Plot( pgf.Expression(\"x^2\")), {\n              xlabel = \"x\"\n              ylabel = \"y\"\n              title = \"Figure\"\n          });\n\njulia> pgf.print_tex(a)\n    \\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]\n        \\addplot+[]\n            {x^2}\n        ;\n    \\end{axis}\n\njulia> push!(a, pgf.Plot( pgf.Table(\"data.dat\")));\n\njulia> pgf.print_tex(a)\n    \\begin{axis}[xlabel={x}, ylabel={y}, title={Figure}]\n        \\addplot+[]\n            {x^2}\n        ;\n        \\addplot+[]\n            table []\n            {data.dat}\n        ;\n    \\end{axis}Any struct can be pushed in to an Axis. What will be printed is the result of PGFPlotsX.print_tex(io::IO, t::T, ::Axis) where T is the type of the struct. Pushed strings are written out verbatim."
},

{
    "location": "man/structs.html#GroupPlot-1",
    "page": "Building up figures",
    "title": "GroupPlot",
    "category": "section",
    "text": "A GroupPlot is a way of grouping multiple plots in one figure.Example:julia> pgf.@pgf gp = pgf.GroupPlot({group_style = { group_size = \"2 by 1\",}, height = \"6cm\", width = \"6cm\"});\n\njulia> for (expr, data) in zip([\"x^2\", \"exp(x)\"], [\"data1.dat\", \"data2.dat\"])\n           push!(gp, [pgf.Plot(pgf.Expression(expr)),  pgf.Plot(pgf.Table(data))])\n       end\n\njulia> pgf.print_tex(gp)\n    \\begin{groupplot}[group style={group size={2 by 1}}, height={6cm}, width={6cm}]\n        \\nextgroupplot[]\n\n        \\addplot+[]\n            {x^2}\n        ;\n        \\addplot+[]\n            table []\n            {data1.dat}\n        ;\n        \\nextgroupplot[]\n\n        \\addplot+[]\n            {exp(x)}\n        ;\n        \\addplot+[]\n            table []\n            {data2.dat}\n        ;\n    \\end{groupplot}In order to add options to the \\nextgroupplot call simply add arguments in an \"option like way\" (using strings / pairs / @pgf) when you push!julia> pgf.@pgf gp = pgf.GroupPlot({group_style = { group_size = \"1 by 1\",}, height = \"6cm\", width = \"6cm\"});\n\njulia> pgf.@pgf for (expr, data) in zip([\"x^2\"], [\"data2.dat\"])\n           push!(gp, [pgf.Plot(pgf.Expression(expr)),  pgf.Plot(pgf.Table(data))], {title = \"Data $data\"})\n       end;\n\njulia> pgf.print_tex(gp)\n    \\begin{groupplot}[group style={group size={1 by 1}}, height={6cm}, width={6cm}]\n        \\nextgroupplot[title={Data data2.dat}]\n\n        \\addplot+[]\n            {x^2}\n        ;\n        \\addplot+[]\n            table []\n            {data2.dat}\n        ;\n    \\end{groupplot}"
},

{
    "location": "man/structs.html#TikzPicture-1",
    "page": "Building up figures",
    "title": "TikzPicture",
    "category": "section",
    "text": "A TikzPicture can contain multiple Axis's or GroupPlot's.Example:julia> tp = pgf.TikzPicture( pgf.Axis( pgf.Plot( pgf.Coordinates(rand(5), rand(5)))), \"scale\" => 1.5);\n\njulia> pgf.print_tex(tp)\n\\begin{tikzpicture}[scale={1.5}]\n    \\begin{axis}[]\n        \\addplot+[]\n            coordinates {\n            (0.019179024805588307, 0.2501519456458139)\n            (0.05113231216989789, 0.9221777779905538)\n            (0.5648080180343429, 0.9586784922834994)\n            (0.5248828812399753, 0.8642592693396507)\n            (0.02943482346303017, 0.7327568460567329)\n            }\n        ;\n    \\end{axis}\n\\end{tikzpicture}"
},

{
    "location": "man/structs.html#TikzDocument-1",
    "page": "Building up figures",
    "title": "TikzDocument",
    "category": "section",
    "text": "A TikzDocument is the highest level object and represents a whole .tex file. It includes a list of objects that will sit between \\begin{document} and \\end{document}.A very simple example where we simply create a TikzDocument with a string in is shown below. Normally you would also push Axis's that contain plots.julia> td = pgf.TikzDocument();\n\njulia> push!(td, \"Hello World\");\n\njulia> save(\"hello.pdf\", td);note: Note\nThere is usually no need to explicitly create a TikzDocument or TikzPicture. Only do this if you want to give special options to them. It is possible to show or save an Axis or e.g. a Plot directly, and they will then be wrapped in the default \"higher level\" objects."
},

{
    "location": "man/save.html#",
    "page": "Exporting figures",
    "title": "Exporting figures",
    "category": "page",
    "text": ""
},

{
    "location": "man/save.html#Exporting-figures-1",
    "page": "Exporting figures",
    "title": "Exporting figures",
    "category": "section",
    "text": "Figures that are shown in the Jupyter notebook in the examples are saved withsave(filename::String, figure; include_preamble::Bool = true)where the file extension of filename determines the file type (can be .pdf, .svg or .tex) and include_preamble sets if the preamble should be included in the output (only relevant for tex export)."
},

{
    "location": "man/save.html#Customizing-the-preamble-1",
    "page": "Exporting figures",
    "title": "Customizing the preamble",
    "category": "section",
    "text": "It is common to want to use a custom preamble to add user-defined macros or different packages to the preamble. There are a few ways to do this:push! strings into the global variable CUSTOM_PREAMBLE. Each string in that vector will be inserted in the preamble.\nModify the custom_premble.tex file in the deps folder of the directory of the package. This file is directly spliced into the preamble of the output.\nDefine the environment variable PGFPLOTSX_PREAMBLE_PATH to a path pointing to a preamble file. The content of that will be inserted into the preamble."
},

{
    "location": "man/save.html#Choosing-the-LaTeX-engine-used-1",
    "page": "Exporting figures",
    "title": "Choosing the LaTeX engine used",
    "category": "section",
    "text": "Thee are three different choices for latex engines, PDFLATEX, LUALATEX and XELATEX. By default, LUALATEX is used. The active engine can be retrieved with the latexengine() function and be set with latexengine!(engine) where engine is one of the three previously mentioned engines."
},

{
    "location": "man/save.html#Custom-flags-1",
    "page": "Exporting figures",
    "title": "Custom flags",
    "category": "section",
    "text": "Custom flags to the engine can be used in the latex command by push!-ing them into the global variable CUSTOM_FLAGS."
},

{
    "location": "man/custom_types.html#",
    "page": "Optional packages",
    "title": "Optional packages",
    "category": "page",
    "text": ""
},

{
    "location": "man/custom_types.html#Optional-packages-1",
    "page": "Optional packages",
    "title": "Optional packages",
    "category": "section",
    "text": "By loading different packages, you automatically get access to new functionality.Please see the example notebook"
},

]}
