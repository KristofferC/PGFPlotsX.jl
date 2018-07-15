using Crayons
using Crayons.Box

if !isfile(joinpath(@__DIR__, "showed_warning"))
    info("""The new PGFPlotsX-release is a breaking release.
        If you want your old plot codes to work, you can pin PGFPlotsX to v0.1.5.
        """)
    touch(joinpath(@__DIR__, "showed_warning"))
end

const OK =  GREEN_FG * BOLD("OK")
const X =  RED_FG * BOLD("X")

print(STDERR, "Looking for lualatex...")
have_lualatex = try success(`lualatex -v`); catch; false; end
println(STDERR, "   ", have_lualatex ? OK : X)

print(STDERR, "Looking for pdflatex...")
have_pdflatex = try success(`pdflatex -v`); catch; false; end
println(STDERR, "   ", have_pdflatex ? OK : X)


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

print(STDERR, "Looking for pdftoppm...")
have_pdftoppm =  try success(`pdftoppm  -v`); catch; false; end
println(STDERR, "   ", have_pdftoppm ? OK : X)
if !have_pdftoppm
    @warn(string("Did not find `pdftoppm`, png output will be disabled. Install `pdftoppm` ",
                "and run Pkg.build(\"PGFPLotsX\") to enable"))
end

print(STDERR, "Looking for pdf2svg...")
pdfpath = joinpath(@__DIR__, "pdf2svg.pdf")
svgpath = joinpath(@__DIR__, "pdf2svg.svg")
have_pdf2svg = try success(`pdf2svg $pdfpath $svgpath`); catch; false; end
println(STDERR, "    ", have_pdf2svg ? OK : X)
if !have_pdf2svg
    @warn(string("Did not find `pdf2svg`, svg output will be disabled. Install `pdf2svg` ",
                "and run Pkg.build(\"PGFPLotsX\") to enable"))
end

if !have_pdf2svg && !have_pdftoppm
    @warn(string("Found neither pdf2svg or pdftoppm, figures will not be viewable in Jupyter or Juno"))
end


open(joinpath(@__DIR__, "deps.jl"), "w") do f
    println(f, "DEFAULT_ENGINE = \"", default_engine, "\"")
    println(f, "HAVE_PDFTOPPM = ", have_pdftoppm)
    println(f, "HAVE_PDFTOSVG = ", have_pdf2svg)
end


const PREAMBLE_PATH = joinpath(@__DIR__, "custom_preamble.tex")
if !isfile(PREAMBLE_PATH)
    touch(PREAMBLE_PATH)
end
