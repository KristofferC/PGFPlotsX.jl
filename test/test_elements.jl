"Invoke print_tex with the given arguments, collect the results in a string."
function repr_tex(args...)
    io = IOBuffer()
    pgf.print_tex(io, args...)
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

function ≅(x::T, y::T) where T
    for f in fieldnames(T)
        getfield(x, f) == getfield(y, f) || return false
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
    @test_throws ArgumentError pgf.Coordinate((1, ))    # dimension not 2 or 3
    @test_throws ArgumentError pgf.Coordinate((NaN, 1)) # not finite
    @test_throws ArgumentError pgf.Coordinate((1, 2);   # can't specify both
                                              error = (0, 0), errorplus = (0, 0))
    @test_throws MethodError pgf.Coordinates((1, 2); error = (3, )) # incompatible dims
    @test squashed_repr_tex(pgf.Coordinate((1, 2))) == "(1, 2)"
    @test squashed_repr_tex(pgf.Coordinate((1, 2); error = (3, 4))) == "(1, 2) +- (3, 4)"
    @test squashed_repr_tex(pgf.Coordinate((1, 2); errorminus = (3, 4))) ==
        "(1, 2) -= (3, 4)"
    @test squashed_repr_tex(pgf.Coordinate((1, 2);
                                           errorminus = (3, 4),
                                           errorplus = (5, 6))) ==
                                               "(1, 2) += (5, 6) -= (3, 4)"
    @test squashed_repr_tex(pgf.Coordinate((1, 2); meta = "blue")) == "(1, 2) [blue]"
end

@testset "coordinates and convenience constructors" begin
    @test_throws ArgumentError pgf.Coordinates([(1, 2), (1, 2, 3)]) # incompatible dims
    @test_throws ArgumentError pgf.Coordinates([(1, 2), "invalid"]) # invalid value

    # from Vectors and AbstractVectors
    @test pgf.Coordinates([1, 2], [3.0, 4.0]).data == pgf.Coordinate.([(1, 3.0), (2, 4.0)])
    @test pgf.Coordinates(1:2, 3:4).data == pgf.Coordinate.([(1, 3), (2, 4)])
    # skip empty
    @test pgf.Coordinates([(2, 3), (), nothing]).data ==
        [pgf.Coordinate((2, 3)), pgf.EmptyLine(), pgf.EmptyLine()]
    @test pgf.Coordinates(1:2, 3:4, (1:2)./((3:4)')).data ==
        pgf.Coordinates(Any[1, 2, NaN, 1, 2, NaN],
                        Any[3, 3, NaN, 4, 4, NaN],
                        Any[1/3, 2/3, NaN, 1/4, 2/4, NaN]).data
    # from iterables
    @test pgf.Coordinates(enumerate(3:4)).data == pgf.Coordinate.([(1, 3), (2, 4)])
    @test pgf.Coordinates((x, 1/x) for x in -1:1).data ==
        [pgf.Coordinate((-1, -1.0)), pgf.EmptyLine(), pgf.Coordinate((1, 1.0))]
    let x = 1:3,
        y = -1:1,
        z = x ./ y
        @test pgf.Coordinates(x, y, z).data ==
            pgf.Coordinates((x, y, x / y) for (x,y) in zip(x, y)).data
    end
end

@testset "tables" begin
    # compare results to these using ≅, defined above
    table_named_noopt = pgf.Table(OrderedDict{Any, Any}(), hcat(1:10, 11:20),
                                  ["a", "b"], Int[])
    table_unnamed_noopt = pgf.Table(OrderedDict{Any, Any}(), hcat(1:10, 11:20),
                                    nothing, Int[])
    opt = pgf.@pgf { meaningless = "option" }
    table_named_opt = pgf.Table(opt, hcat(1:10, 11:20), ["a", "b"], Int[])

    # named columns, without options
    @test pgf.Table(Dict(:a => 1:10, :b => 11:20)) ≅ table_named_noopt
    @test pgf.Table(:a => 1:10, :b => 11:20) ≅ table_named_noopt
    @test pgf.Table(; a = 1:10, b = 11:20) ≅ table_named_noopt
    @test pgf.Table([:a => 1:10, :b => 11:20]) ≅ table_named_noopt
    @test pgf.Table(hcat(1:10, 11:20); colnames = [:a, :b]) ≅ table_named_noopt

    # named columns, with options
    @test pgf.Table(opt, Dict(:a => 1:10, :b => 11:20)) ≅ table_named_opt
    @test pgf.Table(opt, :a => 1:10, :b => 11:20) ≅ table_named_opt
    @test pgf.Table(opt, [:a => 1:10, :b => 11:20]) ≅ table_named_opt
    @test pgf.Table(opt, hcat(1:10, 11:20); colnames = [:a, :b]) ≅ table_named_opt

    # unnamed columns, without options
    @test pgf.Table(1:10, 11:20) ≅ table_unnamed_noopt
    @test pgf.Table([1:10, 11:20]) ≅ table_unnamed_noopt
    @test pgf.Table(hcat(1:10, 11:20)) ≅ table_unnamed_noopt

    # matrix and edges
    let x = randn(10), y = randn(5), z = cos.(x .+ y')
        @test pgf.Table(x, y, z) ≅ pgf.Table(OrderedDict{Any, Any}(),
                                             hcat(pgf.matrix_xyz(x, y, z)...),
                                             ["x", "y", "z"], 10)
    end

    # dataframe
    @test pgf.Table(DataFrame(a = 1:5, b = 6:10)) ≅
        pgf.Table(OrderedDict{Any, Any}(), hcat(1:5, 6:10), ["a", "b"], 0)

    # can't determine if it is named or unnamed
    @test_throws ArgumentError pgf.Table([1:10, :a => 11:20])

    @test squashed_repr_tex(pgf.Table(OrderedDict{Any, Any}(),
                                      [1 NaN;
                                       -Inf 4.0],
                                      ["xx", "yy"],
                                      [1])) == "table []\n{xx yy\n1.0 nan\n\n-inf 4.0\n}"
end

@testset "tablefile" begin
    @test squashed_repr_tex(pgf.TableFile(pgf.@pgf({x = "a", y = "b"}), "somefile.dat")) ==
                                              "table [x={a}, y={b}]\n{somefile.dat}"
    @test squashed_repr_tex(pgf.TableFile("somefile.dat")) == "table []\n{somefile.dat}"
end
