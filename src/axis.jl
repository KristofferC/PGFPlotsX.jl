immutable Axis <: TikzElement
    options::Vector{String}
    plots::Vector{Plot}
end

Base.push!(axis::Axis, plot::Plot) = push!(axis.plots, plot)

function Axis(options = String[], plots = Plot[])
    Axis(options, plots)
end

function print_tex(io_main::IO, axis::Axis)
    print_indent(io_main) do io
        print(io, "\\begin{axis}")
        print_options(io, axis.options)
        for plot in axis.plots
            print_tex(io, plot)
        end
        print(io, "\\end{axis}")
    end
end
