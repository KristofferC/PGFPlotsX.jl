
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
