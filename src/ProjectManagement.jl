module ProjectManagement
using DataStructures: MultiDict
using Compose
using Distributions
using Gadfly: Gadfly

using Graphs
using LayeredLayouts
using Random
using RecipesBase
using Statistics
using Random
export PertBeta, Project
export critical_path, density, sample_time, path_durations, visualize_chart


include("project.jl")
include("timing_distributions.jl")
include("timing_graphs.jl")
include("paths.jl")
include("graph_viz.jl")
end # module
