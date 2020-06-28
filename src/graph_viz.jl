"""
    PertChart(::Project)

By wrapping a [`Project`](@ref) object in a `PertChart`,
it can be `plot`ed to visualize the chart.
"""
struct PertChart{P<:Project}
    proj :: P
end

function index(x::NamedTuple{L}) where L
    indexes = ntuple(identity, length(L))
    return NamedTuple{L, typeof(indexes)}(indexes)
end

is_milestone(name) = name ∈ (:start, :finish)

function adjancy_matrix(proj::Project)
    task_index = index(proj.task_durations)
    n = length(proj.task_durations)
    adjmat = zeros(n, n)
    for (src, dest) in proj.links
        ii = task_index[src]
        jj = task_index[dest]
        adjmat[ii, jj] = 1
    end
    return adjmat
end

function node_string(name, duration)
    if length(duration) == 1
        duration = only(duration)
    end
    return "$name\n$duration"
end
function node_string(name, dur::PertBeta)
    expected = @sprintf("%.2f", mean(dur))
    "$name\n$(minimum(dur)) | $(mode(dur)) | $(maximum(dur)) ⟹ $expected"
end


@recipe function f(pert::PertChart)
    proj = pert.proj
    adjmat = adjancy_matrix(proj)
    nodes = collect(keys(proj.task_durations))
    
    # set up the graphplot
    names := [node_string(name, dur) for (name, dur) in pairs(proj.task_durations)]
    nodecolor := ifelse.(is_milestone.(nodes), "#79bbf5", "#f9f8dd")
    nodeshape := ifelse.(is_milestone.(nodes), :hexagon, :rect)
    nodesize --> 0.12
    method --> :spring
    root --> :left
    arrow --> true
    shorten --> 0.1
    curves --> false
    GraphRecipes.GraphPlot((adjmat,))
end