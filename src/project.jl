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
end

