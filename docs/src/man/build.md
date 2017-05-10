# Build

## Choosing the LaTeX engine

Thee are three different choices for latex engines, `PDFLATEX`, `LUALATEX` and `XELATEX`.
By default, `LUALATEX` is used. The active engine can be retrieved with the `latexengine()` function and be set with `latexengine!(engine)` where `engine` is one of the three previously metntioned engines.

## Custom flags

Custom flags can be used in the latex command by `push!`-ing them into the global variable `CUSTOM_FLAGS`.

## Custom preamble

It is common to want to use a custom preamble to add user-defined macros or different packages to the preamble. There are a few ways to do this in *PGFPlotsX*:

* `push!` strings into the global variable `CUSTOM_PREAMBLE`. Each string in that vector will be inserted in the preamble.
* Modify the `custom_premble.tex` file in the `deps` folder of the directory of the package. This file is directly spliced into the preamble of the output.
* Define the environment variable `PGFPLOTSX_PREAMBLE_PATH` to a path pointing to a preamble file. The content of that will be inserted into the preamble.
