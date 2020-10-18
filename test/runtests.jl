using HypothesisTests
using Random
using RecipesBase
using Test
using ProjectManagement

Random.seed!(1)

@testset "ProjectManagement.jl" begin
    @testset "$f" for f in (
        "project_examples.jl", # must be first
        "project.jl",
        "timing_distributions.jl",
        "timing_graph.jl",
        "graph_viz.jl",
    )
        include(f)
    end
end
