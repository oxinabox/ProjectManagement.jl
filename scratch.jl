using ProjectManagement
using Compose
using LinearAlgebra: Tridiagonal
using LightGraphs
using LayeredLayouts


proj = Project(
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

graph = SimpleDiGraph(ProjectManagement.adjancy_matrix(proj))
xs_original, ys_original, path_map = solve_positions(Zarate(), graph)
x_factor = 9
y_factor = 6
xs = x_factor .* xs_original
ys = y_factor .* ys_original
x_min, x_max = extrema(xs)
y_min, y_max = extrema(ys)
box_max = max(x_max-x_min+2x_factor, y_max-y_min+2y_factor)

set_default_graphic_size(22cm, 22cm)



# 1D (can do x and y independently)
function compute_control_points(knots)
    # based on based on equations from https://www.particleincell.com/2012/bezier-splines/
    # and https://www.codeproject.com/Articles/31859/Draw-a-Smooth-Curve-through-a-Set-of-2D-Points-wit
    # but not using Thomas algorithm cos that gives worse results than julia's `\`
    # possibly algorithm sample code on wikipedia is wrong
    # even though this case is supposed to be numerically stable for Thomas algorithm.
    @assert length(knots) > 1
    if length(knots) == 2  # special case: straight line
        return [knots[1]], [knots[2]]
    end


    n = length(knots) - 1;
    p1 = Vector{Float32}(undef, n)

    rhs = [
        knots[1] + 2knots[2];
        [4knots[i] + 2knots[i+1] for i in 2:n-1];
        8knots[end-1] + knots[end]
    ]

    lhs = Tridiagonal(
        [ones(n-2); 2],
        [2; 4ones(n-2); 7],  # d
        ones(n-1),
    )
    # lhs * q1 = rhs
    @show q1 =  lhs\rhs

    display(lhs)
    @show lhs
    @show rhs

    # TODO the above equation for q1 should be used instead of the below for p1
    # they should be equivielent, but looks like i am computing q1 wrong
    #################################

    # rhs vector
    a = Vector{Float32}(undef, n)
    b = Vector{Float32}(undef, n)
    c = Vector{Float32}(undef, n)
    r = Vector{Float32}(undef, n)

    a[1]=0
    b[1]=2
    c[1]=1
    r[1] = knots[1] + 2knots[2]

    # internal segments
    for i in 2:(n-1)
        a[i]=1;
        b[i]=4;
        c[i]=1;
        r[i] = 4 * knots[i] + 2 * knots[i+1];
    end

    # last segment
    a[end] = 2;
    b[end] = 7;
    c[end] = 0;
    r[end] = 8knots[end-1] + knots[end];
    @show a b c r

    # TODO use `\`
    #/*solves Ax=b with the Thomas algorithm (from Wikipedia)*/
    for i in 2:(n-1)
        m = a[i]/b[i-1];
        b[i] = b[i] - m * c[i - 1];
        r[i] = r[i] - m*r[i-1];
    end

    p1[end] = r[end]/b[end];
    for i in (n-1):-1:1
        p1[i] = (r[i] - c[i] * p1[i+1]) / b[i]
    end
    @show p1

    #####################

    #/*we have p1, now compute p2*/
    p2 = Vector{Float32}(undef, n)
    for i in 1:(n-1)
        p2[i] = 2knots[i+1] - p1[i+1];
    end
    p2[end]=0.5*(knots[end]+p1[end]);

    return p1, p2
end

function connected_curve(xs, ys)
    path = collect(zip(xs, ys))
    @show path
    length(path) == 2 && return line(path)

    starts = path[1:end-1]
    ends = path[2:end]
    p1x, p2x = compute_control_points(first.(path))
    p1y, p2y = compute_control_points(last.(path))
    p1s = collect(zip(p1x, p1y))
    p2s = collect(zip(p2x, p2y))
    return curve(starts, p1s, p2s, ends)
end



return compose(
    context(; units=UnitBox(x_min-x_factor, y_min-y_factor, box_max, box_max)),
    (
        context(; order=2),
        map(keys(proj.task_durations), proj.task_durations, xs, ys) do name, duration, x, y
            compose(
                context(x, y),
                ProjectManagement.chart_task(name, duration; fontsize=1),
            )
        end...,

    ),
    (
        context(2.5, 0; order=1),
        line(map(edges(graph)) do edge
            [(xs[edge.src], ys[edge.src]), (xs[edge.dst], ys[edge.dst])]
        end),
        stroke("green"),
        (context(), (connected_curve(x_factor.*xs, y_factor.*ys) for (xs, ys) in values(path_map))..., stroke("red"))
    ),
)
