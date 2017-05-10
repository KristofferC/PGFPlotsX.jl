# PGFPlotsX

*PGFPlotsX* is a Julia package to generate high quality figures using the LaTeX library PGFPlots.

It is similar in spirit to the package [PGFPlots.jl](https://github.com/sisl/PGFPlots.jl) but it
tries to have a closer (more low level) mapping to the PGFPlots API as well as striving to reduce the number of dependencies.

Examples can be found at the [PGFPlotsXExamples repo](https://github.com/KristofferC/PGFPlotsXExamples).

A `Plot` or `Axis` can be saved to a `pdf`, `tex` or `svg` file using

```jl
save(filename::String, object; include_preamble::Bool = true)
```

where the file extension of `filename` determines the file type and `include_preamble`
sets if the preamble should be included in the output (only relevant for `tex` export).

### TODO:

* Error bars
* Group plots
* Gnuplot
* Document option macro `@pgf`
* Good way of including Tikz Nodes.
* Create Tables from in memory data.
* Document `merge!`
