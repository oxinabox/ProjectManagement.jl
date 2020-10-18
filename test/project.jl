# good projects are tested via project_examples.jl
const MissingMilestoneException = ProjectManagement.MissingMilestoneException
const BadMilestoneDurationException = ProjectManagement.BadMilestoneDurationException
const PreStartTasksException = ProjectManagement.PreStartTasksException
const PostFinishTasksException = ProjectManagement.PostFinishTasksException
const CyclicPathException = ProjectManagement.CyclicPathException
const DisconnectedPathException = ProjectManagement.DisconnectedPathException
const UnlinkedTasksException = ProjectManagement.UnlinkedTasksException
const UnspecifiedTasksException = ProjectManagement.UnspecifiedTasksException

@testset "bad projects" begin
    @test_throws MissingMilestoneException Project(
        (start=0, a=1),
        [:start => :a,]
    )

    @test_throws MissingMilestoneException Project(
        (a=1, finish=0,),
        [:a => :finish,]
    )

    @test_throws BadMilestoneDurationException Project(
        (start=1, finish=0,),
        [:start => :finish,]
    )

    @test_throws BadMilestoneDurationException Project(
        (start=0, finish=(0,0),),
        [:start => :finish,]
    )

    @test_throws PreStartTasksException Project(
        (start=0, a=1, finish=0,),
        [:a => :start, :start => :finish,]
    )

    @test_throws PostFinishTasksException Project(
        (start=0, a=1, finish=0,),
        [:start => :finish, :finish=>:a]
    )

    @test_throws CyclicPathException Project(
        (start=0, a=1, b=1, finish=0,),
        [:start => :a, :a => :b, :b  => :a, :a => :finish,]
    )

    @test_throws DisconnectedPathException Project(
        (start=0, a=1, b=1, finish=0,),
        [:start => :a, :a => :b, :a => :finish,]
    )

    @test_throws UnspecifiedTasksException Project(
        (start=0, a=1, finish=0,),
        [:start => :a, :a => :b, :b => :finish, :a => :finish,]
    )

    @test_throws UnlinkedTasksException Project(
        (start=0, a=1, b=1, finish=0,),
        [:start => :a, :a => :finish,]
    )
end

@testset "Error messages" begin
    msg = sprint(showerror, BadMilestoneDurationException(:start, 2))
    @test occursin("start", msg)
    @test occursin("2", msg)
end
