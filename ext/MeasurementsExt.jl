module MeasurementsExt

import PGFPlotsX

PGFPlotsX.EXTENSIONS_SUPPORTED ? (using Measurements) : (using ..Measurements)

function PGFPlotsX.Coordinates(x::AbstractVector{T}, y::AbstractVector;
                            kwargs...) where T <: Measurements.Measurement{<:Real}
    PGFPlotsX.Coordinates(Measurements.value.(x), y;
        xerror = Measurements.uncertainty.(x), kwargs...)
end

function PGFPlotsX.Coordinates(x::AbstractVector, y::AbstractVector{T};
                            kwargs...) where T <: Measurements.Measurement{<:Real}
    PGFPlotsX.Coordinates(x, Measurements.value.(y);
        yerror = Measurements.uncertainty.(y), kwargs...)
end

function PGFPlotsX.Coordinates(x::AbstractVector{T}, y::AbstractVector{T};
                            kwargs...) where T <: Measurements.Measurement{<:Real}
    PGFPlotsX.Coordinates(Measurements.value.(x), Measurements.value.(y);
        xerror = Measurements.uncertainty.(x),
        yerror = Measurements.uncertainty.(y), kwargs...)
end

end
