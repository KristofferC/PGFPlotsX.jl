function is_file_starting_with(filename, bytes::DenseVector{UInt8})
    isfile(filename) && read(filename, length(bytes)) == bytes
end

function is_file_starting_with(filename, regex::Regex, nlines = 1)
    isfile(filename) || return false
    content = ""
    open(filename, "r") do io
        for _ in 1:nlines
            content *= readline(io; chomp = true)
        end
    end
    contains(content, regex)
end

is_png_file(filename) = is_file_starting_with(filename, b"\x89PNG")

is_pdf_file(filename) = is_file_starting_with(filename, b"%PDF")

is_tex_document(filename) =     # may have a \Require in the first line
    is_file_starting_with(filename, r"\\documentclass\[tikz\]{standalone}", 2)

is_tikz_standalone(filename) =
    is_file_starting_with(filename, r"\\begin{tikzpicture}")

is_svg_file(filename) = is_file_starting_with(filename, r"<svg .*>", 2)

@testset "preamble" begin
    mktemp() do path, f
        withenv("PGFPLOTSX_PREAMBLE_PATH" => path) do
            try
                test_preamble_env = "test preamble env"
                test_preamble_var = "test preamble var"

                push!(CUSTOM_PREAMBLE, test_preamble_var)
                print(f, test_preamble_env)
                close(f)

                td = TikzDocument()

                io = IOBuffer()
                PGFPlotsX.savetex(io, td)

                texstring = String(take!(io))
                @test contains(texstring, test_preamble_env)
                @test contains(texstring, test_preamble_var)
            finally
                empty!(CUSTOM_PREAMBLE)
            end
        end
    end
end

@testset "simple" begin
    tmp = tempname()
    mktempdir() do dir
        cd(dir) do
            a = Axis(Plot(Expression("x^2")))
            pgfsave("$tmp.tex", a)
            @test is_tex_document("$tmp.tex")
            println(readstring("$tmp.tex"))
            pgfsave("$tmp.png", a)
            @test is_png_file("$tmp.png")
            pgfsave("$tmp.pdf", a)
            @test is_pdf_file("$tmp.pdf")
            pgfsave("$tmp.svg", a)
            @test is_svg_file("$tmp.svg")
            pgfsave("$tmp.tikz", a)
            @test is_tikz_standalone("$tmp.tikz")

            let tikz_lines = readlines("$tmp.tikz")
                @test ismatch(r"^\\begin{tikzpicture}.*", tikz_lines[1])
                last_line = findlast(!isempty, tikz_lines)
                @test strip(tikz_lines[last_line]) == "\\end{tikzpicture}"
            end
        end
    end
end

@testset "gnuplot / shell-escape" begin
    tmp_pdf = tempname() * ".pdf"
    expr = "-2.051^3*1000./(2*3.1415*(2.99*10^2)^2)/(x^2*cos(y)^2)"
    mktempdir() do dir
        cd(dir) do
            @pgf p =
                Axis(
                    {
                        colorbar,
                        xlabel = "x",
                        ylabel = "y",
                        domain = "1:2",
                        y_domain = "74:87.9",
                        view = (0, 90),
                    },
                    Plot3(
                        {
                            contour_gnuplot = {
                                number = 30,
                                labels = false},
                            thick,
                            samples = 40,
                        },
                        Expression(expr)))
            pgfsave(tmp_pdf, p)
            @test is_pdf_file(tmp_pdf)
            rm(tmp_pdf)
        end
    end
end
