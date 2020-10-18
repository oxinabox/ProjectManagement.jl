@testset "Static Length" begin
    proj = Project(
        (start=0, common=1, short=2, long=3, finish=0,),
        [
            :start => :common,
            :common => :short,
            :common =>:long,
            :short => :finish,
            :long => :finish
        ]
    )

    @testset "no transform" begin
        @test path_durations(proj) == [
            [:start, :common, :long, :finish] => 4,
            [:start, :common, :short, :finish] => 3,
        ]
        @test critical_path(proj) == ([:start, :common, :long, :finish] => 4)
    end

    @testset "negate transform" begin
        @test path_durations(-, proj) == [
            [:start, :common, :short, :finish] => -3,
            [:start, :common, :long, :finish] => -4,
        ]
        @test critical_path(-, proj) == ([:start, :common, :short, :finish] => -3)
    end
end
