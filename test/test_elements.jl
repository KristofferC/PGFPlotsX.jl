
"Invoke print_tex with the given arguments, collect the results in a string."
function repr_tex(args...)
    io = IOBuffer()
    pgf.print_tex(io, args...)
    String(take!(io))
end

"""
Trim lines, merge whitespace to a single space, remove empty lines.

Useful for unit testing printed representations.
"""
function squash_whitespace(str::AbstractString)
    lines = split(str, '\n')
    squashed_lines = map(line -> replace(strip(line), r" +", " "), lines)
    join(filter(!isempty, squashed_lines), "\n")
end

@test squash_whitespace("  a  line  \nsome   other line\n\ndone\n") ==
    "a line\nsome other line\ndone"

"Squashed result of `print_tex` with given arguments."
squashed_repr_tex(args...) = squash_whitespace(repr_tex(args...))

@testset "printing Julia types to TeX" begin
    @test squashed_repr_tex("something") == "something"
    @test squashed_repr_tex(string.([2, 3, 4])) == "2\n3\n4"
    @test_throws ArgumentError repr_tex(4) # undefined
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
