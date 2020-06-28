using ProjectManagement

@testset "Basic consistency $f" for f in 
    (:empty, :onetask, :chain, :shortlong, :medium)
    proj = getfield(Examples, f)

    samples = rand(proj, 10_000);

    # if we just did all tasks one after the other we get absolutely worst possible case
    worsecase = sum(maximum, proj.task_durations)
    # if we did everything in parallel we get absolutely best possible case
    # but it can never be shorter than the longest minimum duration of any single task
    bestcase = maximum(minimum, proj.task_durations)
    @test all(bestcase ≤ s ≤ worsecase for s in samples)
end

@testset "known distribution: proj $f, task $t" for (f,t) in (
    (:shortlong, :long), (:onetask, :a)
)
    # These projects have their duration fully controlled by 1 task
    # so should use same distribution.
    proj = getfield(Examples, f)
    expected_dist = proj.task_durations[t]

    # Make sure we would *not* reject the null hypothesios that it does indeed
    # come from this distrubition
    samples = rand(proj, 10_000);
    hypo_test = HypothesisTests.OneSampleADTest(samples, expected_dist)
    @test pvalue(hypo_test) < 0.99
end



@testset "empty project" begin
    samples = rand(Examples.empty, 10_000)
    @test all(iszero, samples)
end

#==
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
==#