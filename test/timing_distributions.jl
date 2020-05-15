using StatsPlots

using ProjectManagement
using Distributions
using Statistics
using Random
using Test

@testset "PertBeta" begin
    dist = PertBeta(4, 10, 20)
    @test minimum(dist) == 4
    @test maximum(dist) == 20
    @test mode(dist) == 10
    @test mean(dist) == (4 + 4*10 + 20)/6


    @testset "$dist" for dist in (PertBeta(4, 10, 20), PertBeta(0.0,0.5,1.0), PertBeta(1.0, 1.01, 10.0), )
        samples = rand(dist, 1_000_000)
        @test minimum(dist) < minimum(samples)
        @test maximum(samples) < maximum(dist)
        @test mean(samples) ≈ mean(dist) atol=0.01
        @test std(samples) ≈ std(dist) atol=0.01
    end

end
