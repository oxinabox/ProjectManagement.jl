
struct PertChart{T, L}
    tasks::T
    links::L
end

function index(x::NamedTuple{L}) where L
    indexes = ntuple(identity, length(L))
    return NamedTuple{L, typeof(indexes)}(indexes)
end


@recipe function f(proj::Project)
    is_milestone(name) = name ∈ (:start, :finish)

    task_index = index(proj.task_durations)
    nodes = collect(keys(proj.task_durations))
    n = length(proj.task_durations)
    sources = Int[]
    dests = Int[]
    for (src, dest) in proj.links
        push!(sources, task_index[src])
        push!(dests, task_index[dest])
    end

    # set up the graphplot
    names := String.(nodes)
    nodecolor := ifelse.(is_milestone.(nodes), "#79bbf5", "#f9f8dd")
    nodeshape := ifelse.(is_milestone.(nodes), :hexagon, :rect)
    nodesize --> 0.2
    method --> :spectral
    root --> :left
    arrow --> true
    shorten --> 0.1
    curves --> false
    GraphRecipes.GraphPlot((sources, dests))
end
