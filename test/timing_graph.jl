@testset "Sampling" begin
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
        @test 0.05 < pvalue(hypo_test)
    end

    @testset "empty project" begin
        samples = rand(Examples.empty, 10_000)
        @test all(iszero, samples)
    end
end


@testset "Plotting" begin
    proj = Examples.medium
    result, = RecipesBase.apply_recipe(Dict{Symbol, Any}(), proj)
    xs, = result.args
    @test length(xs) == 100_000
    @test xs isa Vector{Float64}
    @test result.plotattributes[:title] == "Completion Time"
end
