const PREAMBLE_PATH = joinpath(@__DIR__, "custom_preamble.tex")
if !isfile(PREAMBLE_PATH)
    touch(PREAMBLE_PATH)
end
