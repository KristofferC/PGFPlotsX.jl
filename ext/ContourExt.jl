module ContourExt

import PGFPlotsX

PGFPlotsX.EXTENSIONS_SUPPORTED ? (using Contour) : (using ..Contour)

function PGFPlotsX.TableData(c::Contour.ContourCollection; kwargs...)
    colx = Any[]
    coly = Any[]
    colz = Any[]
    ns = Int[]
    for cl in Contour.levels(c)
        lvl = Contour.level(cl) # the z-value of this contour level
        for line in Contour.lines(cl)
            xs, ys = Contour.coordinates(line) # coordinates of this line segment
            n = length(xs)
            append!(colx, xs)
            append!(coly, ys)
            append!(colz, fill(lvl, n))
            push!(ns, n)
        end
    end
    PGFPlotsX.TableData(hcat(colx, coly, colz); colnames=["x", "y", "z"], scanlines=cumsum(ns), kwargs...)
end

end
