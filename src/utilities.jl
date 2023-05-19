"""
    $SIGNATURES

Add 4 spaces before each line in `str`. It is recommended (but not required)
that the argument is terminated with a newline.
"""
function add_indent(str::AbstractString)
    isterminated = endswith(str, "\n")
    lines = split(str, '\n')
    if isterminated
        lines = lines[1:(end-1)]
    end
    indent = (str) -> isempty(strip(str)) ? str : "    " * str
    result = join(indent.(lines), '\n')
    if isterminated
        result *= "\n"
    end
    result
end

"""
    $SIGNATURES

Call the `f` with an IO buffer, capture the output, print it to `io_main`
indented with four spaces.
"""
function print_indent(f, io_main::IO)
    io = IOBuffer()
    f(io)
    print(io_main, add_indent(String(take!(io))))
end

"""
    $SIGNATURES

Print `elt` to `io` with indentation. Shortcut for the function wrapper of
`print_indent` for a single element.
"""
function print_indent(io_main::IO, elt)
    print_indent(io_main) do io
        print_tex(io, elt)
    end
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
