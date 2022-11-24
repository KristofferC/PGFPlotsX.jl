![logo](docs/src/assets/logo.png)

# PGFPlotsX

| **Documentation**                                                               | **Build Status**                                                                                |
|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
| [![][docs-stable-img]][docs-stable-url] | [![build](https://github.com/KristofferC/PGFPlotsX.jl/workflows/CI/badge.svg)](https://github.com/KristofferC/PGFPlotsX.jl/actions?query=workflow%3ACI) [![codecov](https://codecov.io/gh/KristofferC/PGFPlotsX.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/KristofferC/PGFPlotsX.jl)|



*PGFPlotsX* is a Julia package to generate publication quality figures using the LaTeX library PGFPlots.

It is similar in spirit to the package [PGFPlots.jl](https://github.com/sisl/PGFPlots.jl) but it
tries to have a very close mapping to the PGFPlots API as well as minimize the number of dependencies.
The fact that the syntax is similar to the TeX version means that examples from Stack Overflow and the PGFPlots manual can
easily be incorporated in the Julia code.

Features include:

* Showing figures inline in Jupyter notebooks, VSCode-julia. Both png- and svg-figures can be shown.
* Exporting to tex, pdf, svg, and png, file formats.
* Customizing the preamble so that commands from latex packages can be used.
* [Extra functionality](https://kristofferc.github.io/PGFPlotsX.jl/stable/examples/juliatypes) when different packages are loaded, for example *Colors*, *DataFrames*, *Contour* etc.

## Installation

The package is registered in the general registry and so can be installed with `Pkg.add`.

```julia
julia> Pkg.add("PGFPlotsX")
```

## [Documentation][docs-stable-url]


## Authors

- Kristoffer Carlsson - [@KristofferC89](https://github.com/KristofferC/)
- Tamas K. Papp - [@tpapp](https://github.com/tpapp)

[docs-stable-img]: https://img.shields.io/badge/docs-blue.svg
[docs-stable-url]: https://kristofferc.github.io/PGFPlotsX.jl/v1/

[travis-img]: https://travis-ci.org/KristofferC/PGFPlotsX.jl.svg?branch=master
[travis-url]: https://travis-ci.org/KristofferC/PGFPlotsX.jl

[issues-url]: https://github.com/KristofferC/PGFPlotsX.jl/issues
