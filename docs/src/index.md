# PGFPlotsX

## Introduction

*PGFPlotsX* is a Julia package to generate publication quality figures using the LaTeX library PGFPlots.

It is similar in spirit to the package [PGFPlots.jl](https://github.com/sisl/PGFPlots.jl) but it
tries to have a very close mapping to the PGFPlots API as well as minimize the number of dependencies.
The fact that the syntax is similar to the TeX version means that examples from Stack Overflow and the PGFPlots manual can
easily be incorporated in the Julia code.

Documentation is a WIP but a quite extensive set of examples can be found at the [PGFPlotsXExamples repo](https://github.com/KristofferC/PGFPlotsXExamples).

## Installation

```julia-repl
Pkg.add("PGFPlotsX")
```

To show figures in svg (like is done by default in Jupyter notebooks) you need `pdf2svg`. On Ubuntu, you can get this by running `sudo apt-get install pdf2svg` and on RHEL/Fedora by running `sudo dnf install pdf2svg`. On Windows, you can download the binaries from [here](http://www.cityinthesky.co.uk/opensource/pdf2svg/). Be sure to add `pdf2svg` to your path.

For saving (or showing) png figures you need `pdftoppm` which should be installed by default on Linux but can otherwise be downloaded [here](http://www.foolabs.com/xpdf/download.html).

!!! note
    If you installed a new latex engine, `pdf2svg` or `pdftoppm` after you installed *PGFPlotsX* you need to run `Pkg.build("PGFPlotsX")` for this to be reflected.

## Manual Outline

!!! note
    `PGFPlotsX` does not export anything. In the manual we assume that the command
    `import PGFPlotsX; const pgf = PGFPlotsX` has been run
