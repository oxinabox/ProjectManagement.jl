const examples = [
    "Empty_Example" => raw"""Project(
        (
            start=(0,),
            finish=(0,),
        ),
        [
            :start => :finish,
        ]
    )
    """,
    
    "One_Task_Example" => raw"""Project(
        (
            start=(0,),
            a = PertBeta(0,1,2),
            finish=(0,),
        ),
        [
            :start => :a,
            :a => :finish,
        ]
    )
    """,
    
    "Shortlong_Example" => raw"""Project(
        (
            start=(0,),
            short = PertBeta(0,1,2),
            long = PertBeta(10,20,200),
            finish=(0,),
        ),
        [
            :start .=> [:short, :long];
            [:short, :long] .=> :finish;
        ]
    )
    """,
    
    
    "Chain_Example" => raw"""Project(
        (
            start=(0,),
            a=PertBeta(1,2,3),
            b=PertBeta(10,20,30),
            c=PertBeta(100,200,600),
            finish=(0,),
        ),
        [
            :start => :a,
            :a => :b,
            :b => :c,
            :c => :finish,
        ]
    )
    """,
    
    "Realistic_Example" => raw"""Project(
        (
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
        ),
        [
            :start .=> [:a, :b, :c, :d];
            :a => :f;
            :b .=> [:f, :g];
            [:c, :d] .=> :e;
            :e .=> [:f, :g, :h];
            [:f, :g, :h] .=> :j;
            :j => :finish;
        ]
    )
    """,
]

function create_demofiles()
    demo_dir = mkpath(joinpath(@__DIR__, "src", "demos",))
    template = String(read(joinpath(@__DIR__, "demo_template.md"))) 
    for (name, construction) in examples
        filled_template = replace(template, "{{NAME}}" => name)
        filled_template = replace(filled_template, "{{CONSTRUCTION}}" => construction)
        open(joinpath(demo_dir, "$name.md"), "w") do fh
            write(fh, filled_template)
        end
    end
end
