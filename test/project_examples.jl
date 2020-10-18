module Examples
using ProjectManagement

const empty = Project(
    (
        start=0,
        finish=0,
    ),
    [
        :start => :finish,
    ]
)

const onetask = Project(
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

"Two tasks in parellel `:short` and `:long`. `:long` completely controls the timing."
const shortlong = Project(
    (
        start=0,
        short = PertBeta(0,1,2),
        long = PertBeta(10,100,200),
        finish=0,
    ),
    [
        :start .=> [:short, :long];
        [:short, :long] .=> :finish;
    ]
)


const chain = Project(
    (
        start=0,
        a=PertBeta(1,2,3),
        b=PertBeta(10,20,30),
        c=PertBeta(100,200,300),
        finish=0,
    ),
    [
        :start => :a,
        :a => :b,
        :b => :c,
        :c => :finish,
    ]
)

const medium = Project(
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
    ]
)

end # module
