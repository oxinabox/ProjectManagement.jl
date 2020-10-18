"""
    Project(task_durations, links)

 - `task_durations::NamedTuple`: a namedtuple where the keys are the names of the tasks,
   and the values indicate the timing.
    - The timing values can be anything sampleable.
      i.e. any object `dur` that has `rand(rng, dur)::Real` defined on it. e.g. any
      collection or distribution object. Particularly relevent is `PertBeta(min, mode, max)`
      which is the standard used for PERT estimation. as well as using a single element
      `tuple` to represent things of fixed duration.
 - `links::Vector{Pair{Symbol, Symbol}}`: a collection of pairs for all the depencencies of
   tasks. e.g. `[:a => :b, :a=>:c, :c=>:d]`. A convienent way to write this is often using
   broadcasting and matrix notation for vcat: `[:a .=> [:b, :c]; :c => :d]`.

The task names `start` and `finish` are special, in that they represent the begining
and ending milestones of the project.
They must be in the `task_durations` with duration `(0,)`, and they must be the
root and only leaf of the graph decribed by the `links`.
"""
struct Project{D<:NamedTuple}
    task_durations::D
    links::Vector{Pair{Symbol, Symbol}}

    function Project(task_durations::D, links) where D
        proj = new{D}(task_durations, links)
        validate_project(proj)
        return proj
    end
end

function validate_project(proj::Project)
    validate_milestones(proj)
    validate_links(proj)
end

function validate_milestones(proj)
    haskey(proj.task_durations, :start) || throw(MissingMilestoneException(:start))
    haskey(proj.task_durations, :finish) || throw(MissingMilestoneException(:finish))

    after_finish = [b for (a, b) in proj.links if a === :finish]
    isempty(after_finish) || throw(PostFinishTasksException(after_finish))

    before_start = [a for (a, b) in proj.links if b === :start]
    isempty(before_start) || throw(PreStartTasksException(before_start))

    return nothing
end

"""
    validate_links(proj)

Checks that:
    - the links in `proj` form a directed acyclic graph
    - that every end-point in the `links` is on `task_durations`
    - that every task in `task_durations` occurs in `links`
"""
function validate_links(proj)
    children_lookup = MultiDict(proj.links)
    children_lookup
    all_seen = Set{Symbol}()  # for checking at the end that everything was covered

    function inner(node, path)
        push!(all_seen, node)
        node == :finish && return
        children = get(children_lookup, node, nothing)
        children === nothing && throw(DisconnectedPathException(path))
        for child in children
            # PREM-OPT: this could use a PersistentList or pop! after rather than copying
            new_path = copy(path)
            push!(new_path, child)
            child ∈ path && throw(CyclicPathException(new_path))
            inner(child, new_path)
        end
    end

    inner(:start, Symbol[])

    missing_links = setdiff(keys(proj.task_durations), all_seen)
    isempty(missing_links) || throw(UnlinkedTasksException(missing_links))

    missing_durations = setdiff(all_seen, keys(proj.task_durations))
    isempty(missing_durations) || throw(UnspecifiedTasksException(missing_durations))

    return nothing
end

struct MissingMilestoneException <: Exception
    milestone
end

struct PostFinishTasksException <: Exception
    task
end
struct PreStartTasksException <: Exception
    task
end

struct CyclicPathException <: Exception
    cycle
end
struct DisconnectedPathException <: Exception
    path
end


struct UnlinkedTasksException <: Exception
    tasks
end

struct UnspecifiedTasksException <: Exception
    tasks
end
