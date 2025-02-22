# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SimpleKriging(γ, μ)
    SimpleKriging(data, γ, μ)

Simple Kriging with variogram model `γ` and constant mean `μ`.

Optionally, pass the geospatial `data` to the [`fit`](@ref) function.

### Notes

* Simple Kriging requires stationary variograms
"""
struct SimpleKriging{G<:Variogram,V} <: KrigingEstimator
  # input fields
  γ::G
  μ::V

  function SimpleKriging{G,V}(γ, μ) where {G<:Variogram,V}
    @assert isstationary(γ) "Simple Kriging requires stationary variogram"
    new(γ, μ)
  end
end

SimpleKriging(γ, μ) = SimpleKriging{typeof(γ),typeof(μ)}(γ, μ)

SimpleKriging(data, γ, μ) = GeoStatsBase.fit(SimpleKriging(γ, μ), data)

nconstraints(::SimpleKriging) = 0

set_constraints_lhs!(::SimpleKriging, LHS::AbstractMatrix, domain) = nothing

factorize(::SimpleKriging, LHS::AbstractMatrix) = cholesky(Symmetric(LHS), check=false)

set_constraints_rhs!(::FittedKriging{<:SimpleKriging}, pₒ) = nothing

function combine(fitted::FittedKriging{<:SimpleKriging},
                 weights::KrigingWeights, z::AbstractVector)
  γ = fitted.estimator.γ
  μ = fitted.estimator.μ
  b = fitted.state.RHS
  λ = weights.λ
  y = z .- μ

  μ + y⋅λ, sill(γ) - b⋅λ
end
