HAVE_PDFTOPPM = success(`pdftoppm -v`)

if !HAVE_PDFTOPPM
    warn("Did not find `pdftoppm`, png output will be disabled")
end

open(joinpath(@__DIR__, "deps.jl"), "w") do f
    print(f, "HAVE_PDFTOPPM = ", HAVE_PDFTOPPM)
end


const PREAMBLE_PATH = joinpath(@__DIR__, "custom_preamble.tex")
if !isfile(PREAMBLE_PATH)
    touch(PREAMBLE_PATH)
end
