@testset "engine" begin
    pgf.latexengine!(pgf.XELATEX)
    @test pgf.latexengine() == pgf.XELATEX
    @test pgf._engine_cmd() == `xelatex`
end

@testset "preamble" begin
    mktemp() do path, f
        withenv("PGFPLOTSX_PREAMBLE_PATH" => path) do
            test_preamble_env = "test preamble env"
            test_preamble_var = "test preamble var"

            push!(pgf.CUSTOM_PREAMBLE, test_preamble_var)
            print(f, test_preamble_env)
            close(f)

            io = IOBuffer()
            pgf._print_preamble(io)

            preamble = String(take!(io))
            println(preamble)
            @test contains(preamble, test_preamble_env)
            @test contains(preamble, test_preamble_var)
        end
    end
end

@testset "gnuplot"

end
