@testset "printing Julia types to TeX" begin
    @test squashed_repr_tex("something") == "something"
    @test squashed_repr_tex(4) == "4"
    @test squashed_repr_tex(NaN) == "nan"
    @test squashed_repr_tex(Inf) == "+inf"
    @test squashed_repr_tex(-Inf) == "-inf"
    @test squashed_repr_tex(missing) == "nan"
end

@testset "coordinate" begin
    @test_throws ArgumentError PGFPlotsX.Coordinate((1, ))    # dimension not 2 or 3
    @test_throws ArgumentError PGFPlotsX.Coordinate((NaN, 1)) # not finite
    @test_throws ArgumentError PGFPlotsX.Coordinate((1, 2);   # can't specify both
                                              error = (0, 0), errorplus = (0, 0))
    @test_throws MethodError Coordinates((1, 2); error = (3, )) # incompatible dims
    @test squashed_repr_tex(PGFPlotsX.Coordinate((1, 2))) == "(1, 2)"
    @test squashed_repr_tex(PGFPlotsX.Coordinate((1, 2); error = (3, 4))) == "(1, 2) +- (3, 4)"
    @test squashed_repr_tex(PGFPlotsX.Coordinate((1, 2); errorminus = (3, 4))) ==
        "(1, 2) -= (3, 4)"
    @test squashed_repr_tex(PGFPlotsX.Coordinate((1, 2);
                                           errorminus = (3, 4),
                                           errorplus = (5, 6))) ==
                                               "(1, 2) += (5, 6) -= (3, 4)"
    @test squashed_repr_tex(PGFPlotsX.Coordinate((1, 2); meta = "blue")) == "(1, 2) [blue]"
end

@testset "coordinates and convenience constructors" begin
    @test_throws ArgumentError Coordinates([(1, 2), (1, 2, 3)]) # incompatible dims
    @test_throws ArgumentError Coordinates([(1, 2), "invalid"]) # invalid value

    # from Vectors and AbstractVectors
    @test Coordinates([1, 2], [3.0, 4.0]).data == PGFPlotsX.Coordinate.([(1, 3.0), (2, 4.0)])
    @test Coordinates(1:2, 3:4).data == PGFPlotsX.Coordinate.([(1, 3), (2, 4)])
    # skip empty
    @test Coordinates([(2, 3), (), nothing]).data ==
        [PGFPlotsX.Coordinate((2, 3)), EmptyLine(), EmptyLine()]
    @test Coordinates(1:2, 3:4, (1:2)./((3:4)')).data ==
        Coordinates(Any[1, 2, NaN, 1, 2, NaN],
                        Any[3, 3, NaN, 4, 4, NaN],
                        Any[1/3, 2/3, NaN, 1/4, 2/4, NaN]).data
    # from iterables
    @test Coordinates(enumerate(3:4)).data == PGFPlotsX.Coordinate.([(1, 3), (2, 4)])
    @test Coordinates((x, 1/x) for x in -1:1).data ==
        [PGFPlotsX.Coordinate((-1, -1.0)), EmptyLine(), PGFPlotsX.Coordinate((1, 1.0))]
    let x = 1:3,
        y = -1:1,
        z = x ./ y
        @test Coordinates(x, y, z).data ==
            Coordinates((x, y, x / y) for (x,y) in zip(x, y)).data
    end
end

@testset "tables" begin
    # compare results to these using ≅, defined above
    table_named_noopt = Table(hcat(1:10, 11:20), ["a", "b"], Int[])
    table_unnamed_noopt = Table(hcat(1:10, 11:20), nothing, Int[])
    opt = @pgf { meaningless = "option" }
    table_named_opt = Table(opt, hcat(1:10, 11:20), ["a", "b"], Int[])

    # named columns, without options
    @test Table(:a => 1:10, :b => 11:20) ≅ table_named_noopt
    @test Table(; a = 1:10, b = 11:20) ≅ table_named_noopt
    @test Table([:a => 1:10, :b => 11:20]) ≅ table_named_noopt
    @test Table(hcat(1:10, 11:20); colnames = [:a, :b]) ≅ table_named_noopt

    # named columns, with options
    @test Table(opt, :a => 1:10, :b => 11:20) ≅ table_named_opt
    @test Table(opt, [:a => 1:10, :b => 11:20]) ≅ table_named_opt
    @test Table(opt, hcat(1:10, 11:20); colnames = [:a, :b]) ≅ table_named_opt

    # unnamed columns, without options
    @test Table(1:10, 11:20) ≅ table_unnamed_noopt
    @test Table([1:10, 11:20]) ≅ table_unnamed_noopt
    @test Table(hcat(1:10, 11:20)) ≅ table_unnamed_noopt

    # matrix and edges
    let x = randn(10), y = randn(5), z = cos.(x .+ y')
        @test Table(x, y, z) ≅ Table(PGFPlotsX.Options(),
                                             hcat(PGFPlotsX.matrix_xyz(x, y, z)...),
                                             ["x", "y", "z"], 10)
    end

    # dataframe
    @test Table(DataFrame(a = 1:5, b = 6:10)) ≅
        Table(PGFPlotsX.Options(), hcat(1:5, 6:10), ["a", "b"], 0)

    # can't determine if it is named or unnamed
    @test_throws ArgumentError Table([1:10, :a => 11:20])

    @test squashed_repr_tex(Table(PGFPlotsX.Options(),
                                      [1 NaN;
                                       -Inf 4.0],
                                      ["xx", "yy"],
                                      [1])) == "table[row sep={\\\\}]\n{\nxx yy \\\\\n1.0 nan \\\\\n\\\\\n-inf 4.0 \\\\\n}"
end

@testset "table file" begin
    path = "somefile.dat"
    @test squashed_repr_tex(Table(@pgf({x = "a", y = "b"}), path)) ==
        "table[x={a}, y={b}] {$(path)}"
    @test squashed_repr_tex(Table(path)) == "table {$(path)}"
end

@testset "plot" begin
    # sanity checks for constructors and printing, 2D
    data2 = Table(x = 1:2, y = 3:4)
    p2 = Plot(false, false, Options(), data2, [raw"\closedcycle"])
    @test squashed_repr_tex(p2) ==
        "\\addplot\ntable[row sep={\\\\}]\n{\nx y \\\\\n1 3 \\\\\n2 4 \\\\\n}\n\\closedcycle\n;"
    @test Plot(data2, raw"\closedcycle") ≅ p2
    @test PlotInc(data2, raw"\closedcycle") ≅
        Plot(false, true, Options(), data2, [raw"\closedcycle"])
    @test PlotInc(data2, raw"\closedcycle") ≅
        Plot(false, true, PGFPlotsX.Options(), data2, [raw"\closedcycle"])
    @test Plot(data2, raw"\closedcycle") ≅ p2
    # printing incremental w/ options, 2D and 3D
    @test squashed_repr_tex(PlotInc(data2)) ==
        "\\addplot+\ntable[row sep={\\\\}]\n{\nx y \\\\\n1 3 \\\\\n2 4 \\\\\n}\n;"
    @test squashed_repr_tex(@pgf Plot3Inc({xtick = 1:3},
                                          Table(x = 1:2, y = 3:4, z = 5:6))) ==
        "\\addplot3+[xtick={1,2,3}]\ntable[row sep={\\\\}]\n{\nx y z \\\\\n1 3 5 \\\\\n2 4 6 \\\\\n}\n;"
end

@testset "printing and indentation" begin
    # adding indent, with corner cases for newlines
    @test PGFPlotsX.add_indent("foo") == "    foo"
    @test PGFPlotsX.add_indent("foo\n") == "    foo\n"
    @test PGFPlotsX.add_indent("foo\nbar") == "    foo\n    bar"
    @test PGFPlotsX.add_indent("foo\n\nbar\n") == "    foo\n\n    bar\n"
    @test PGFPlotsX.add_indent("\nfoo\n\nbar\n") == "\n    foo\n\n    bar\n"
    # expression
    @test repr_tex(Expression("x^2")) == "{x^2}"
    @test repr_tex(Expression(["x^2", "y^2"])) == "(\n{x^2},\n{y^2})"
    # graphics
    @test repr_tex(@pgf Graphics({ testopt = 1}, "filename")) ==
        "graphics[testopt={1}] {filename}\n"
    # coordinates, tables, and plot
    c = Coordinates([(1, 2), (3, 4)])
    @test repr_tex(c) == "coordinates {\n    (1, 2)\n    (3, 4)\n}\n"
    t = Table(x = 1:2, y = 3:4)
    @test repr_tex(t) == "table[row sep={\\\\}]\n{\n    x  y  \\\\\n    1  3  \\\\\n    2  4  \\\\\n}\n"
    @test repr_tex(@pgf Plot({ no_marks }, c)) ==
        "\\addplot[no marks]\n    coordinates {\n        (1, 2)\n        (3, 4)\n    }\n    ;\n"
    @test repr_tex(@pgf Plot({ no_marks }, t, "trailing")) ==
        "\\addplot[no marks]\n    table[row sep={\\\\}]\n    {\n        x  y  \\\\\n" *
        "        1  3  \\\\\n        2  4  \\\\\n    }\n    trailing\n    ;\n"
    # legend
    @test repr_tex(Legend(["a", "b", "c"])) == "\\legend{{a}, {b}, {c}}\n"
    l = LegendEntry("a")
    @test repr_tex(l) == "\\addlegendentry {a}\n"
    # axis
    @test repr_tex(@pgf Axis({ optaxis }, Plot({ optplot }, c), l)) ==
        "\\begin{axis}[optaxis]\n    \\addplot[optplot]\n" *
        "        coordinates {\n            (1, 2)\n            (3, 4)\n        }\n" *
        "        ;\n    \\addlegendentry {a}\n\\end{axis}\n"
end

@testset "explicit empty options" begin
    @test repr_tex(Axis(Options(; print_empty = true))) ==
        "\\begin{axis}[]\n\\end{axis}\n"
end
