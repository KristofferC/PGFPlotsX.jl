"""
    $SIGNATURES

Print `str` to `io`, appending four spaces before each line.
"""
print_indent(io::IO, str::String) = join(io, "    " .* split(str, '\n'), "\n")

"""
    $SIGNATURES

Call the `f` with an IO buffer, capture the output, print it to `io_main`
indended with four spaces.
"""
function print_indent(f, io_main::IO)
    io = IOBuffer()
    f(io)
    print_indent(io_main, String(take!(io)))
end

"""
    $SIGNATURES

Replace the extension in `filename` by `ext` (which should include the `.`).
When the resulting filename is unchanged, throw an error.
"""
function _replace_fileext(filename, ext)
    filebase, fileext = splitext(filename)
    new_filename = filebase * ext
    if filename == new_filename
        error("$filename already has extension $ext.")
    end
    new_filename
end

"""
    $SIGNATURES

Given edges `x`, `y` for a matrix `z`, return a tuple of three vectors which
contain the matching elements of `x`, `y`, and `z`, respectively. Useful for
`surf` and `mesh` plots.
"""
function matrix_xyz(x::AbstractVector, y::AbstractVector, z::AbstractMatrix)
    x_grid = @. first(tuple(x, y'))
    y_grid = @. last(tuple(x, y'))
    @argcheck size(x_grid) == size(y_grid) == size(z) "Incompatible sizes."
    vec(x_grid), vec(y_grid), vec(z)
end
