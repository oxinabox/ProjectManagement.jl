const examples = [
    (
        "Empty_Example",
        raw"""Project(
            (
                start=0,
                finish=0,
            ),
            [
                :start => :finish,
            ]
        )
        """,
        8,
    ),

    (
        "One_Task_Example",
        raw"""Project(
            (
                start=0,
                a = PertBeta(0,1,2),
                finish=0,
            ),
            [
                :start => :a,
                :a => :finish,
            ]
        )
        """,
        4,
    ),

    (
        "Shortlong_Example",
        raw"""Project(
            (
                start=0,
                short = PertBeta(0,1,2),
                long = PertBeta(10,20,200),
                finish=0,
            ),
            [
                :start .=> [:short, :long];
                [:short, :long] .=> :finish;
            ]
        )
        """,
        4,
    ),

    (
        "Chain_Example",
        raw"""Project(
            (
                start=0,
                a=PertBeta(1,2,3),
                b=PertBeta(10,20,30),
                c=PertBeta(100,200,600),
                finish=0,
            ),
            [
                :start => :a,
                :a => :b,
                :b => :c,
                :c => :finish,
            ]
        )
        """,
        2.5,
    ),

    (
        "Realistic_Example",
        raw"""Project(
            (
                start=0,
                a=PertBeta(2,3,4),
                b=PertBeta(1,2,6),
                c=PertBeta(0,1,2),
                d=PertBeta(0,1,2),
                e=PertBeta(0,1,2),
                f=PertBeta(3.0, 6.5, 13.0),
                g=PertBeta(3.5, 7.5, 14.0),
                h=PertBeta(0, 1, 2),
                j=PertBeta(0, 1, 2),
                finish=0,
            ),
            [
                :start .=> [:a, :b, :c, :d];
                :a => :f;
                :b .=> [:f, :g];
                [:c, :d] .=> :e;
                :e .=> [:f, :g, :h];
                [:f, :g, :h] .=> :j;
                :j => :finish;
            ],
        )
        """,
        2.5,
    ),
    (
        "Larger_Realistic_Example",
        raw"""Project(
            (
                start=0,
                t1a=PertBeta(2,3,4),
                t1b=PertBeta(2,3,5),
                t1c=PertBeta(3,4,5),
                t2a=PertBeta(1,2,3),
                t2b=PertBeta(1,2,3),
                t2c=PertBeta(1,2,3),
                t3a=PertBeta(2,3,4),
                t3b=PertBeta(1,2,3),
                t3c=PertBeta(2,5,7),
                t3d=PertBeta(5,8,12),
                t3e=PertBeta(2,3,4),
                t4a=PertBeta(1,2,4),
                t4b=PertBeta(5,8,12),
                t4c=PertBeta(5,8,12),
                t4d=PertBeta(2,3,4),
                t5a=PertBeta(1,2,3),
                t5b=PertBeta(5,7,8),
                t5c=PertBeta(3,5,7),
                t6a=PertBeta(5,6,7),
                t6b=PertBeta(3,6,10),
                t6c=PertBeta(3,6,8),
                t7a=PertBeta(2,4,6),
                t7b=PertBeta(2,3,4),
                finish=0,
            ),
            [
                [:start] .=> [:t1c, :t1a, :t2a, :t3a, :t4a, :t6a, :t7a];
                [:t1a] .=> [:t1b, :t4b, :t4c];
                [:t1b] .=> [:t4b, :t4c];
                [:t1c] .=> [:t4b, :t4c];
                :t2a => :t2b; :t2b => :t2c; :t2c => :finish;
                :t3a => :t3b; :t3b => :t3c; :t3c => :t3d; :t3d => :t3e; :t3e => :finish;
                :t4a => :t4b;
                [:t4b, :t4c] .=> :t4d;
                :t4d => :finish;
                [:t4b, :t4c] .=> :t5a;
                :t5a => :t5b; :t5b => :t5c; :t5c => :finish;
                :t6a => :t6b; :t6b => :t6c; :t6c => :finish;
                :t7a => :t7b; :t7b => :finish;
            ]
        )
        """,
        1.0,
    )
]



# Taken from https://github.com/GiovineItalia/Compose.jl/blob/7fde5c28ceb46dae0927f8fdb6b347680eb86387/docs/make.jl#L4-L7
struct SVGJSWritable{T}
    x :: T
end
Base.show(io::IO, m::MIME"text/html", x::SVGJSWritable) = show(io, m, x.x)

function create_demofiles()
    demo_dir = mkpath(joinpath(@__DIR__, "src", "demos",))
    template = String(read(joinpath(@__DIR__, "demo_template.md")))
    for (name, construction, fontsize) in examples
        filled_template = replace(template, "{{NAME}}" => name)
        filled_template = replace(filled_template, "{{CONSTRUCTION}}" => construction)
        filled_template = replace(filled_template, "{{FONTSIZE}}" => fontsize)
        open(joinpath(demo_dir, "$name.md"), "w") do fh
            write(fh, filled_template)
        end
    end
end
