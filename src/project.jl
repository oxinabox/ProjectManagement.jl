 struct Project{D<:NamedTuple}
    task_durations::D
    links::Vector{Pair{Symbol, Symbol}}
 end

