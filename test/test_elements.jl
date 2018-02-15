"Invoke print_tex with the given arguments, collect the results in a string."
function repr_tex(args...)
    io = IOBuffer()
    print_tex(io, args...)
    String(take!(io))
end

"""
Trim lines, merge whitespace to a single space, merge multiple empty lines into
one, merge beginning and ending newlines.

Useful for unit testing printed representations.
"""
function squash_whitespace(str::AbstractString)
    lines = split(str, '\n')
    squashed_lines = map(line -> replace(strip(line), r" +", " "), lines)
    strip(replace(join(squashed_lines, "\n"), r"\n{2,}", "\n\n"), '\n')
end

@test squash_whitespace("\n\n  a  line  \nsome   other line\n\n\ndone\n") ==
    "a line\nsome other line\n\ndone"

"Squashed result of `print_tex` with given arguments."
squashed_repr_tex(args...) = squash_whitespace(repr_tex(args...))

"A simple comparison of fields for unit tests."
≅(x, y) = x == y

function ≅(x::T, y::T) where T <: Union{PGFPlotsX.Coordinate, Coordinates, Table, Plot}
    for f in fieldnames(T)
        getfield(x, f) ≅ getfield(y, f) || return false
    end
    true
end

@testset "printing Julia types to TeX" begin
    @test squashed_repr_tex("something") == "something"
    @test squashed_repr_tex(string.([2, 3, 4])) == "2\n3\n4"
    @test squashed_repr_tex(4) == "4"
    @test squashed_repr_tex(NaN) == "nan"
    @test squashed_repr_tex(Inf) == "+inf"
    @test squashed_repr_tex(-Inf) == "-inf"
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
    table_named_noopt = Table(PGFPlotsX.Options(), hcat(1:10, 11:20), ["a", "b"], Int[])
    table_unnamed_noopt = Table(PGFPlotsX.Options(), hcat(1:10, 11:20), nothing, Int[])
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
                                      [1])) == "table []\n{xx yy\n1.0 nan\n\n-inf 4.0\n}"
end

@testset "tablefile" begin
    path = "somefile.dat"
    _abspath = abspath(path)
    @test squashed_repr_tex(Table(@pgf({x = "a", y = "b"}), path)) ==
        "table [x={a}, y={b}]\n{$(_abspath)}"
    @test squashed_repr_tex(Table("somefile.dat")) == "table []\n{$(_abspath)}"
end

@testset "plot" begin
    # sanity checks for constructors and printing, 2D
    data2 = Table(x = 1:2, y = 3:4)
    p2 = Plot(false, PGFPlotsX.INCREMENTAL, PGFPlotsX.Options(), data2,
              [raw"\closedcycle"])
    @test squashed_repr_tex(p2) ==
        "\\addplot[]\ntable []\n{x y\n1 3\n2 4\n}\n\\closedcycle\n;"
    @test Plot(PGFPlotsX.INCREMENTAL, @pgf({}), data2, raw"\closedcycle") ≅ p2
    @test Plot(@pgf({}), data2, raw"\closedcycle") ≅ p2
    @test Plot(PGFPlotsX.INCREMENTAL, data2, raw"\closedcycle") ≅ p2
    @test Plot(data2, raw"\closedcycle") ≅ p2
    # printing incremental w/ options, 2D and 3D
    @test squashed_repr_tex(Plot(true, data2)) ==
        "\\addplot+[]\ntable []\n{x y\n1 3\n2 4\n}\n;"
    @test squashed_repr_tex(Plot3(true, Table(x = 1:2, y = 3:4, z = 5:6))) ==
        "\\addplot3+[]\ntable []\n{x y z\n1 3 5\n2 4 6\n}\n;"
end
