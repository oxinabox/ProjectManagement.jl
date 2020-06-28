
"""
    PertBeta(a, b, c) <: ContinuousUnivariateDistribution

The [PERT Beta distribution](https://en.wikipedia.org/wiki/PERT_distribution).

 - `a`: the minimum value of the support
 - `b`: the mode
 - `c`: the maximum value of the support
"""
struct PertBeta{T<:Real} <: ContinuousUnivariateDistribution
    a::T # min
    b::T # mode
    c::T # max
    PertBeta{T}(a::T, b::T, c::T) where {T} = new{T}(a, b, c)
end

function PertBeta(min::T, mode::T, max::T; check_args=true) where {T<:Real}
    check_args && Distributions.@check_args(PertBeta, min ≤ mode ≤ max)
    return PertBeta{T}(min, mode, max)
end

function beta_dist(dd::PertBeta)
    α = (4dd.b + dd.c - 5dd.a)/(dd.c - dd.a)
    β = (5dd.c - dd.a - 4dd.b)/(dd.c - dd.a)
    return Beta(α, β)
end

# Shifts x to the domain of the beta_dist
input_shift(dd::PertBeta, x) = (x - dd.a)/(dd.c - dd.a)
# Shifts y from the domain of the beta_dist
output_shift(dd::PertBeta, y) = y*(dd.c - dd.a) + dd.a

Distributions.mode(dd::PertBeta) = dd.b
Base.minimum(dd::PertBeta) = dd.a
Base.maximum(dd::PertBeta) = dd.c
Statistics.mean(dd::PertBeta) = (dd.a + 4dd.b + dd.c)/6
Statistics.var(dd::PertBeta) = ((mean(dd) - dd.a) * (dd.c - mean(dd)))/7
Distributions.insupport(dd::PertBeta, x) = dd.a < x < dd.c

for f in (:skewness, :kurtosis)
    @eval Distributions.$f(dd::PertBeta) = $f(beta_dist(dd))
end
for f in (:pdf, :cdf, :logpdf)
    @eval Distributions.$f(dd::PertBeta, x::Real) = $f(beta_dist(dd), input_shift(dd, x))
end

Statistics.quantile(dd::PertBeta, x) = output_shift(dd, quantile(beta_dist(dd), x))
Base.rand(rng::AbstractRNG, dd::PertBeta) = output_shift(dd, rand(rng, beta_dist(dd)))

struct PertBetaSampler{B<:PertBeta, S<:Distributions.BetaSampler} <: Sampleable{Univariate, Continuous}
    dd::B
    beta_sampler::S
end
PertBetaSampler(dd) = PertBetaSampler(dd, sampler(beta_dist(dd)))

Base.rand(rng::AbstractRNG, ss::PertBetaSampler) = output_shift(ss.dd, rand(ss.beta_sampler))
Distributions.sampler(dd::PertBeta) = PertBetaSampler(dd)
