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

## Manual Outline

!!! note
    `PGFPlotsX` does not export anything. In the manual we assume that the command
    `import PGFPlotsX; const pgf = PGFPlotsX` has been run


```@contents
Pages = [
    "man/options.md",
    "man/structs.md",
    "man/save.md",
    "man/custom_types.md",
]
Depth = 1
```
