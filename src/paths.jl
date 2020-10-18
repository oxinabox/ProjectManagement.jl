const TRANSFORM_DURATION_DOCS = """
You may pass in a function `f` to transform the duration when computing the cost.
By default it uses `mean`, but for example you can assume everything is worst case using
`path_durations(maximum, proj)`; or you could   compute the path length in terms of number
of tasks using `path_durations(x->1, proj)`.
"""

"""
    path_durations([f=mean], proj::Project)

Compute the duration of every path of tasks with in the project.
They are returned as a vector of pairs: `path => cost`, sorted by cost (descending).
Thus the first is the critical path, and the last is the least critical path.

$TRANSFORM_DURATION_DOCS

See also [`critical_path`](@ref).
"""
path_durations(proj::Project) = path_durations(mean, proj)

function path_durations(f, proj::Project)
    children_lookup = MultiDict(proj.links)

    path_costs = Pair{Vector{Symbol}, Float64}[]
    function inner(path, cost)
        node = path[end]
        if node == :finish
            push!(path_costs, (copy(path) => cost))
            return
        end

        for child in children_lookup[node]
            push!(path, child)
            new_cost = cost + f(proj.task_durations[child])
            inner(path, new_cost)
            pop!(path)  # remove it before we compute the next
        end
    end

    inner([:start], 0.0)

    return sort(path_costs; rev=true, by=last)
end

"""
    critical_path([f=mean], proj::Project)

Computes the critical path though the project.
This is the path who's duration determines the completion time of the project.

$TRANSFORM_DURATION_DOCS

See also [`path_durations`](@ref).
"""
critical_path(args...) = first(path_durations(args...))
