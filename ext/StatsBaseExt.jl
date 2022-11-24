module StatsBaseExt

import PGFPlotsX

PGFPlotsX.EXTENSIONS_SUPPORTED ? (using StatsBase) : (using ..StatsBase)

function PGFPlotsX.TableData(h::StatsBase.Histogram{T, 1};
                                kwargs...) where T
    PGFPlotsX.TableData(hcat(h.edges[1], vcat(h.weights, 0)); kwargs...)
end

function PGFPlotsX.TableData(histogram::StatsBase.Histogram{T, 2};
                                kwargs...) where T
    PGFPlotsX.TableData(StatsBase.midpoints(histogram.edges[1]),
                        StatsBase.midpoints(histogram.edges[2]),
                        histogram.weights; kwargs...)
end

function PGFPlotsX.TableData(e::StatsBase.ECDF; n = 100, kwargs...)
    x = range(extrema(e)...; length = n)
    PGFPlotsX.TableData(hcat(x, map(e, x)); kwargs...)
end

function PGFPlotsX.Coordinates(histogram::StatsBase.Histogram{T, 2}) where T
    PGFPlotsX.Coordinates(StatsBase.midpoints(histogram.edges[1]),
                            StatsBase.midpoints(histogram.edges[2]),
                            histogram.weights)
end

end
