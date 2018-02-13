#  Showing / Exporting figures

## Jupyter

Figures are shown in `svg` format when evaluated in Jupyter. For this you need the `pdf2svg` software installed.
If you want to show them in `png` format (because perhaps is too large), you can use `display(MIME"image/png", p)` where `p` is the figure to show.

## Juno

Figures are shown in the Juno plot pane as `svg`s by default. If you want to show them as `png`, run `show_juno_png(true)`, (`false` to go back to `svg`).
To set the dpi of the figures in Juno when using `png`, run `dpi_juno_png(dpi::Int)`

## REPL

In the REPL, the figure will be exported to a `pdf` and attempted to be opened in the default `pdf` viewing program.
If you wish to disable this, run `pgf.enable_interactive(false)`.

## Exporting

Figures can be exported to files using

```jlcon
PGFPlotsX.save(filename::String, figure; include_preamble::Bool = true, dpi = 150)
```

where the file extension of `filename` determines the file type (can be `.pdf`, `.svg` or `.tex`, or the standalone `tikz` file extensions below), `include_preamble` sets if the preamble should be included in the output (only relevant for `tex` export) and `dpi` determines the dpi of the figure (only relevant for `png` export).

The standalone file extensions `.tikz`, `.TIKZ`, `.TikZ`, `.pgf`, `.PGF` save LaTeX code for a `tikzpicture` environment without a preamble. You can `\input` them directly into a LaTeX document, or use the the [tikzscale](https://www.ctan.org/pkg/tikzscale) LaTeX package for using `\includegraphics` with possible size adjustments.

## Customizing the preamble

It is common to want to use a custom preamble to add user-defined macros or different packages to the preamble. There are a few ways to do this:

* `push!` strings into the global variable `CUSTOM_PREAMBLE`. Each string in that vector will be inserted in the preamble.
* Modify the `custom_premble.tex` file in the `deps` folder of the directory of the package. This file is directly spliced into the preamble of the output.
* Define the environment variable `PGFPLOTSX_PREAMBLE_PATH` to a path pointing to a preamble file. The content of that will be inserted into the preamble.

## Choosing the LaTeX engine used

Thee are two different choices for latex engines, `PDFLATEX`, `LUALATEX`.
By default, `LUALATEX` is used if it was available during `Pkg.build()`. The active engine can be retrieved with the `latexengine()` function and be set with `latexengine!(engine)` where `engine` is one of the three previously mentioned engines.

## Custom flags

Custom flags to the engine can be used in the latex command by `push!`-ing them into the global variable `CUSTOM_FLAGS`.
