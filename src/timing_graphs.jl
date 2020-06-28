function sample_time(
    rng::AbstractRNG, proj::Project, overall_start=:start, overall_finish=:finish
)
    realizations = Dict{Symbol, Float64}()
    realization(task_name::Symbol) = get!(realizations, task_name) do
        task_dist = proj.task_durations[task_name]
        return rand(rng, task_dist)
    end

    function time_taken(start, finish)
        start == finish && return 0.0
        dependencies = (pre for (pre, this) in proj.links if this==finish)
        time_to_begin = maximum(time_taken.(start, dependencies))
        time_to_finish = realization(finish)
        return time_to_begin + time_to_finish
    end

    return time_taken(overall_start, overall_finish)
end


Base.eltype(::Type{<:Project}) = Float64
Base.eltype(::Type{<:Random.SamplerTrivial{<:Project}}) = Float64
function Random.Sampler(rng::AbstractRNG, proj::Project, ::Union{Val{1}, Val{Inf}})
    return Random.SamplerTrivial(proj)
end

Random.rand(rng::AbstractRNG, d::Random.SamplerTrivial{<:Project}) = sample_time(rng, d[])
