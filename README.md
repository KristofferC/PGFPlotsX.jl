![logo](https://cloud.githubusercontent.com/assets/1282691/26036705/1ef7236c-38e3-11e7-9555-91d8a8921334.png)

# PGFPlotsX

| **Documentation**                                                               | **Build Status**                                                                                |
|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
| [![][docs-stable-img]][docs-stable-url] [![][docs-latest-img]][docs-latest-url] | [![][travis-img]][travis-url] |


*PGFPlotsX* is a Julia package to generate publication quality figures using the LaTeX library PGFPlots.

It is similar in spirit to the package [PGFPlots.jl](https://github.com/sisl/PGFPlots.jl) but it
tries to have a very close mapping to the PGFPlots API as well as minimize the number of dependencies.
The fact that the syntax is similar to the TeX version means that examples from Stack Overflow and the PGFPlots manual can
easily be incorporated in the Julia code.

Documentation is currently lacking but a quite extensive set of examples can be found at the [PGFPlotsXExamples repo](https://github.com/KristofferC/PGFPlotsXExamples).


## Installation

The package is registered in `METADATA.jl` and so can be installed with `Pkg.add`.

```julia-repl
julia> Pkg.add("PGFPlotsX")
```

## Documentation

- [**STABLE**][docs-stable-url] &mdash; **most recently tagged version of the documentation.**
- [**LATEST**][docs-latest-url] &mdash; *in-development version of the documentation.*


## TODO:s / Roadmap

* Add more examples
* Make the generated LaTeX code pretty printed (more than currently)
* Add figures to the documentation

## Author

Kristoffer Carlsson - @KristofferC89


[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://kristofferc.github.io/PGFPlotsX.jl/latest/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://kristofferc.github.io/PGFPlotsX.jl/stable

[travis-img]: https://travis-ci.org/KristofferC/PGFPlotsX.jl.svg?branch=master
[travis-url]: https://travis-ci.org/KristofferC/PGFPlotsX.jl

[issues-url]: https://github.com/KristofferC/PGFPlotsX.jl/issues
