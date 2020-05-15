using ProjectManagement

tasks = (
    start=(0,),
    a=PertBeta(2,3,4),
    b=PertBeta(1,2,6),
    c=PertBeta(0,1,2),
    d=PertBeta(0,1,2),
    e=PertBeta(0,1,2),
    f=PertBeta(3.0, 6.5, 13.0),
    g=PertBeta(3.5, 7.5, 14.0),
    h=PertBeta(0, 1, 2),
    j=PertBeta(0, 1, 2),
    finish=(0,),
)

links = [
    :start .=> [:a, :b, :c, :d];
    :a => :f;
    :b .=> [:f, :g];
    [:c, :d] .=> :e;
    :e .=> [:f, :g, :h];
    [:f, :g, :h] .=> :j;
    :j => :finish;
]


function sample_time(tasks, links, overall_start=:start, overall_finish=:finish)
    realizations = Dict{Symbol, Float64}()
    realization(task_name::Symbol) = get!(realizations, task_name) do
        task_dist = tasks[task_name]
        return rand(task_dist)
    end

    function time_taken(start, finish)
        start == finish && return 0.0
        dependencies = (pre for (pre, this) in links if this==finish)
        time_to_begin = maximum(time_taken.(start, dependencies))
        time_to_finish = realization(finish)
        return time_to_begin + time_to_finish
    end

    return time_taken(overall_start, overall_finish)
end

timing_samples = [sample_time(tasks, links) for ii in 1:1_000_000];

using StatsPlots

plot()
density!(timing_samples; lab="time taken (sampled)")
plot!(Normal(mean(timing_samples), var(timing_samples)); lab="moment matched gaussian")
plot!(;
    xlims= (5,21),
    xticks=5:2.5:25,
    legend=:bottom,
    title="Completion Time",
    xlabel="Duration (weeks)",
)

extrema(timing_samples)

median(timing_samples)
