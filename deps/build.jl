using Crayons
using Crayons.Box

const OK =  GREEN_FG * BOLD("OK")
const X =  RED_FG * BOLD("X")

print(stderr, "Looking for lualatex...")
have_lualatex = try success(`lualatex -v`); catch; false; end
println(stderr, "   ", have_lualatex ? OK : X)

print(stderr, "Looking for pdflatex...")
have_pdflatex = try success(`pdflatex -v`); catch; false; end
println(stderr, "   ", have_pdflatex ? OK : X)


default_engine = ""
if have_lualatex
    default_engine = "LUALATEX"
elseif have_pdflatex
    default_engine = "PDFLATEX"
else
    @warn(string("No LaTeX installation found, figures will not be generated. ",
                 "Make sure either pdflatex or lualatex are installed and that ",
                 "the correct paths are set then run Pkg.build(\"PGFPLotsX\")"))
end

print(stderr, "Looking for pdftocairo...")
have_pdftocairo =  try success(`pdftocairo  -v`); catch; false; end
println(stderr, "   ", have_pdftocairo ? OK : X)

if have_pdftocairo
    have_pdftoppm = true
    default_pdftoppm = `pdftocairo`
    have_pdf2svg = true
    default_pdftosvg = `pdftocairo -svg -l 1`
else
    print(stderr, "Looking for pdftoppm...")
    have_pdftoppm =  try success(`pdftoppm  -v`); catch; false; end
    println(stderr, "   ", have_pdftoppm ? OK : X)
    if have_pdftoppm
        default_pdftoppm = `pdftoppm`
    else
        have_pdftoppm
        @warn(string("Did not find `pdftocairo` or `pdftoppm`, png output will be disabled. Install `pdftocairo` or `pdftoppm` ",
                    "and run Pkg.build(\"PGFPLotsX\") to enable"))
    end

    print(stderr, "Looking for pdf2svg...")
    pdfpath = joinpath(@__DIR__, "pdf2svg.pdf")
    svgpath = joinpath(@__DIR__, "pdf2svg.svg")
    have_pdf2svg = try success(`pdf2svg $pdfpath $svgpath`); catch; false; end
    println(stderr, "    ", have_pdf2svg ? OK : X)
    if have_pdf2svg
        default_pdftosvg = `pdf2svg`
    else
        @warn(string("Did not find `pdftocairo` or `pdf2svg`, svg output will be disabled. Install `pdftocairo` or `pdf2svg` ",
                    "and run Pkg.build(\"PGFPLotsX\") to enable"))
    end
end

if !have_pdftocairo && !have_pdf2svg && !have_pdftoppm
    @warn(string("Found none of pdftocairo, pdf2svg, or pdftoppm; figures will not be viewable in Jupyter or Juno"))
end


open(joinpath(@__DIR__, "deps.jl"), "w") do f
    println(f, "DEFAULT_ENGINE = \"", default_engine, "\"")
    println(f, "HAVE_PDFTOPPM = ", have_pdftoppm)
    println(f, "DEFAULT_PDFTOPPM = ", default_pdftoppm)
    println(f, "HAVE_PDFTOSVG = ", have_pdf2svg)
    println(f, "DEFAULT_PDFTOSVG = ", default_pdftosvg)
end


const PREAMBLE_PATH = joinpath(@__DIR__, "custom_preamble.tex")
if !isfile(PREAMBLE_PATH)
    touch(PREAMBLE_PATH)
end
