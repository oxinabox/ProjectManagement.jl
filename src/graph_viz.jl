
function index(x::NamedTuple{L}) where L
    indexes = ntuple(identity, length(L))
    return NamedTuple{L, typeof(indexes)}(indexes)
end

function adjancy_matrix(proj::Project)
    task_index = index(proj.task_durations)
    n = length(proj.task_durations)
    adjmat = zeros(n, n)
    for (src, dest) in proj.links
        ii = task_index[src]
        jj = task_index[dest]
        adjmat[ii, jj] = 1
    end
    return adjmat
end

chart_duration_string(duration) = string(duration)
function chart_duration_string(duration::Tuple{<:Any})
    return if iszero(only(duration))
        ""
    else
        string(only(duration))
    end
end
function chart_duration_string(dur::PertBeta)
    return string(
        "(", minimum(dur), "|", mode(dur), "|", maximum(dur), ")",
        "\n", round(mean(dur); digits=2),
    )
end

function chart_task(name, duration; fontsize=2)
    str = "$name\n" * chart_duration_string(duration)
    return compose(
        context(),
        (
            context(;order=1),
            stroke("blue"),
            # flattened hexegon
            polygon([(0, 0), (1, 1.5), (4, 1.5), (5, 0), (4, -1.5), (1, -1.5),]),
            fill("white"), fillopacity(1.0)
        ),
        (
             # rectanle in the hexegon
            context(1, -1, 3, 2; order=2, units=UnitBox(0, 0, 10, 10)),
            text(5, 2, str, hcenter, vtop),
            Compose.fontsize(fontsize),
            #rectangle(), fill("red"),
        ),
    )
end

"""
    visualize_chart(proj::Project; fontsize=2)

Visualizes the project as a PERT Chart.
Each task is places to the right of the tasks that much be completed first.
"""
function visualize_chart(proj; fontsize=2)
    graph = SimpleDiGraph(ProjectManagement.adjancy_matrix(proj))
    xs_original, ys_original = solve_positions(Zarate(), graph)
    x_factor = 9
    y_factor = 6
    xs = x_factor .* xs_original
    ys = y_factor .* ys_original
    x_min, x_max = extrema(xs)
    y_min, y_max = extrema(ys)
    box_max = max(x_max-x_min+2x_factor, y_max-y_min+2y_factor)

    set_default_graphic_size(22cm, 22cm)
    return compose(
        context(; units=UnitBox(x_min-x_factor, y_min-y_factor, box_max, box_max)),
        (
            context(; order=2),
            map(keys(proj.task_durations), proj.task_durations, xs, ys) do name, duration, x, y
                compose(
                    context(x, y),
                    chart_task(name, duration; fontsize=fontsize),
                )
            end...,
        ),
        (
            context(2.5, 0; order=1),
            line(map(edges(graph)) do edge
                [(xs[edge.src], ys[edge.src]), (xs[edge.dst], ys[edge.dst])]
            end),
            stroke("green"),
        )
    )
end
