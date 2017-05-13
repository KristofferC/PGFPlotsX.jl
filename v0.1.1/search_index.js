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
    "text": "PGFPlotsX is a Julia package to generate publication quality figures using the LaTeX library PGFPlots.It is similar in spirit to the package PGFPlots.jl but it tries to have a very close mapping to the PGFPlots API as well as minimize the number of dependencies. The fact that the syntax is similar to the TeX version means that examples from Stack Overflow and the PGFPlots manual can easily be incorporated in the Julia code.Documentation is currently lacking but a quite extensive set of examples can be found at the PGFPlotsXExamples repo."
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
    "text": "Note that PGFPlotsX does not export anything. Therefore the objects used in the documentation must be explicitly imported to be used.pages = Any[\n    \"Home\" => \"index.md\",\n    \"Manual\" => [\n        \"man/build.md\"\n        ],\n]\nDepth = 1"
},

{
    "location": "man/build.html#",
    "page": "Saving objects",
    "title": "Saving objects",
    "category": "page",
    "text": ""
},

{
    "location": "man/build.html#Saving-objects-1",
    "page": "Saving objects",
    "title": "Saving objects",
    "category": "section",
    "text": "Objects that are shown in the Jupyter notebook in the examples are saved withsave(filename::String, object; include_preamble::Bool = true)where the file extension of filename determines the file type (can be .pdf, .svg or .tex) and include_preamble sets if the preamble should be included in the output (only relevant for tex export)."
},

{
    "location": "man/build.html#Customizing-the-preamble-1",
    "page": "Saving objects",
    "title": "Customizing the preamble",
    "category": "section",
    "text": "It is common to want to use a custom preamble to add user-defined macros or different packages to the preamble. There are a few ways to do this in PGFPlotsX:push! strings into the global variable CUSTOM_PREAMBLE. Each string in that vector will be inserted in the preamble.\nModify the custom_premble.tex file in the deps folder of the directory of the package. This file is directly spliced into the preamble of the output.\nDefine the environment variable PGFPLOTSX_PREAMBLE_PATH to a path pointing to a preamble file. The content of that will be inserted into the preamble."
},

{
    "location": "man/build.html#Choosing-the-LaTeX-engine-used-1",
    "page": "Saving objects",
    "title": "Choosing the LaTeX engine used",
    "category": "section",
    "text": "Thee are three different choices for latex engines, PDFLATEX, LUALATEX and XELATEX. By default, LUALATEX is used. The active engine can be retrieved with the latexengine() function and be set with latexengine!(engine) where engine is one of the three previously mentioned engines."
},

{
    "location": "man/build.html#Custom-flags-1",
    "page": "Saving objects",
    "title": "Custom flags",
    "category": "section",
    "text": "Custom flags can be used in the latex command by push!-ing them into the global variable CUSTOM_FLAGS."
},

]}
