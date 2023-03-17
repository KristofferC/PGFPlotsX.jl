#  Showing / Exporting figures

## Jupyter

Figures are shown in `svg` format when evaluated in Jupyter. For this you need the `pdf2svg` software installed. If you want to show figures in `png` format (because perhaps the svg format is too large), you can use `display("image/png", p)` where `p` is the figure to show.

## REPL

In the REPL, the figure will be exported to a `pdf` and attempted to be opened in the default `pdf` viewing program. If you wish to disable this, run `PGFPlotsX.enable_interactive(false)`.

## Exporting to files

Figures can be exported to files using

```jlcon
pgfsave(filename::AbstractString, figure; include_preamble::Bool = true, dpi = 150)
```

where the file extension of `filename` determines the file type (can be `pdf`, `svg` or `tex`, or the standalone `tikz` file extensions below), `include_preamble` sets if the preamble should be included in the output (only relevant for `tex` export) and `dpi` determines the dpi of the figure (only relevant for `png` export).

```@docs
pgfsave
```

The standalone file extensions `tikz`, `TIKZ`, `TikZ`, `pgf`, `PGF` save LaTeX code for a `tikzpicture` environment without a preamble. You can `\input` them directly into a LaTeX document, or use the the [tikzscale](https://www.ctan.org/pkg/tikzscale) LaTeX package for using `\includegraphics` with possible size adjustments.

!!! hint

    You can use the externalization feature of `tikz`/`pgfplots`, which caches generated `pdf` files for faster compilation of LaTeX documents. Use
    ```tex
    \usepgfplotslibrary{external}
    \tikzexternalize
    ```
    in the preamble of the LaTeX document which uses these plots, see the manuals for more details.

## [Customizing the preamble](@id customizing_the_preamble)

It is common to use a custom preamble to add user-defined macros or use different packages.
There are a few ways to do this:

* `push!` strings into the global variable [`PGFPlotsX.CUSTOM_PREAMBLE`](@ref). Each string in that vector will be inserted in the preamble.

* Modify the `custom_preamble.tex` file in the `deps` folder of the directory of the package. This file is directly spliced into the preamble of the output.

* Define the environment variable `PGFPLOTSX_PREAMBLE_PATH` to a path pointing to a preamble file. The content of that will be inserted into the preamble.

```@docs
PGFPlotsX.CUSTOM_PREAMBLE
```

Access to the class options of the standalone document class is possible with
[`PGFPlotsX.CLASS_OPTIONS`](@ref).

```@docs
PGFPlotsX.CLASS_OPTIONS
```

## Choosing the LaTeX engine used

Thee are three different choices for latex engines, `PDFLATEX`, `LUALATEX` and `XELATEX`.
By default, `LUALATEX` is used if it was available during `Pkg.build()`. The active engine can be retrieved with the `latexengine()` function and be set with `latexengine!(engine)` where `engine` is one of the three previously mentioned engines (i.e. `PGFPlotsX.PDFLATEX` or `PGFPlotsX.XELATEX`).

## File conversions

When saving a file in PNG or SVG formats, it is first saved as a PDF and then converted using external programs. When the user needs more than one version, this can be done more efficiently by converting the PDF manually, as in
```julia
pdf_path = "/tmp/filename.pdf"
pgfsave(pdf_path, my_figure)
PGFPlotsX.convert_pdf_to_png(pdf_path) # /tmp/filename.png
PGFPlotsX.convert_pdf_to_svg(pdf_path) # /tmp/filename.svg
```

The following are utility functions available for this purpose, but not exported.

```@docs
PGFPlotsX.convert_pdf_to_png
PGFPlotsX.convert_pdf_to_svg
```

## Custom flags

```@docs
PGFPlotsX.CUSTOM_FLAGS
```
