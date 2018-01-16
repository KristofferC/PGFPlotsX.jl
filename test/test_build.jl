@testset "preamble" begin
    mktemp() do path, f
        withenv("PGFPLOTSX_PREAMBLE_PATH" => path) do
            try
                test_preamble_env = "test preamble env"
                test_preamble_var = "test preamble var"

                push!(pgf.CUSTOM_PREAMBLE, test_preamble_var)
                print(f, test_preamble_env)
                close(f)

                td = pgf.TikzDocument()

                io = IOBuffer()
                pgf.savetex(io, td)

                texstring = String(take!(io))
                @test contains(texstring, test_preamble_env)
                @test contains(texstring, test_preamble_var)
            finally
                empty!(pgf.CUSTOM_PREAMBLE)
            end
        end
    end
end

@testset "simple" begin
    tmp = tempname()
    mktempdir() do dir
        cd(dir) do
            a = pgf.Axis(pgf.Plot(pgf.Expression("x^2")))
            pgf.save("$tmp.tex", a)
            println(readstring("$tmp.tex"))
            pgf.save("$tmp.pdf", a)
            pgf.save("$tmp.tikz", a)
            let tikz_lines = readlines("$tmp.tikz")
                @test ismatch(r"^\\begin{tikzpicture}.*", tikz_lines[1])
                last_line = findlast(!isempty, tikz_lines)
                @test tikz_lines[last_line] == "\\end{tikzpicture}"
            end
        end
    end
end

@testset "gnuplot / shell-escape" begin
    tmp_pdf = tempname() * ".pdf"
    expr = "-2.051^3*1000./(2*3.1415*(2.99*10^2)^2)/(x^2*cos(y)^2)"
    mktempdir() do dir
        cd(dir) do
            pgf.@pgf p =
                pgf.Axis(pgf.Plot3(pgf.Expression(expr),
                                   {
                                       contour_gnuplot = {
                                           number = 30,
                                           labels = false},
                                       thick,
                                       samples = 40,
                                   }; incremental = false),
                         {
                             colorbar,
                             xlabel = "x",
                             ylabel = "y",
                             domain = 1:2,
                             y_domain = "74:87.9",
                             view = (0, 90),
                         })
            pgf.save(tmp_pdf, p)
            @test isfile(tmp_pdf)
            rm(tmp_pdf)
        end
    end
end
