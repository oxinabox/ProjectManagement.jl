# good projects are tested via project_examples.jl
@testset "bad projects" begin
    MissingMilestoneException = ProjectManagement.MissingMilestoneException
    PreStartTasksException = ProjectManagement.PreStartTasksException
    PostFinishTasksException = ProjectManagement.PostFinishTasksException
    CyclicPathException = ProjectManagement.CyclicPathException
    DisconnectedPathException = ProjectManagement.DisconnectedPathException
    UnlinkedTasksException = ProjectManagement.UnlinkedTasksException
    UnspecifiedTasksException = ProjectManagement.UnspecifiedTasksException

    @test_throws MissingMilestoneException Project(
        (start=(0,), a = (1,)),
        [:start => :a,]
    )

    @test_throws MissingMilestoneException Project(
        (a = (1,), finish=(0,),),
        [:a => :finish,]
    )

    @test_throws PreStartTasksException Project(
        (start=(0,), a = (1,), finish=(0,),),
        [:a => :start, :start => :finish,]
    )

    @test_throws PostFinishTasksException Project(
        (start=(0,), a = (1,), finish=(0,),),
        [:start => :finish, :finish=>:a]
    )

    @test_throws CyclicPathException Project(
        (start=(0,), a = (1,), b = (1,), finish=(0,),),
        [:start => :a, :a => :b, :b  => :a, :a => :finish,]
    )

    @test_throws DisconnectedPathException Project(
        (start=(0,), a = (1,), b = (1,), finish=(0,),),
        [:start => :a, :a => :b, :a => :finish,]
    )

    @test_throws UnspecifiedTasksException Project(
        (start=(0,), a = (1,), finish=(0,),),
        [:start => :a, :a => :b, :b => :finish, :a => :finish,]
    )

    @test_throws UnlinkedTasksException Project(
        (start=(0,), a = (1,), b = (1,), finish=(0,),),
        [:start => :a, :a => :finish,]
    )
end
