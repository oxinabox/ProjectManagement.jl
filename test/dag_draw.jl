using JuMP
using Ipopt
using LightGraphs

using IterTools: IterTools
using ProjectManagement
include(joinpath(@__DIR__, "project_examples.jl"))

###

proj = Examples.medium
graph = SimpleDiGraph(ProjectManagement.adjancy_matrix(proj))

roots = findall(iszero, indegree(graph))
leaves = findall(iszero, outdegree(graph))

function longest_paths(graph, roots)
    dists = zeros(nv(graph))
    pending = [0 => r for r in roots]
    while(!isempty(pending))
        depth, node = pop!(pending)
        dists[node] = max(dists[node], depth)
        append!(pending, (depth+1) .=> outneighbors(graph, node))
    end
    return dists
end
dists = longest_paths(graph, roots)

column_groups = IterTools.groupby(i->dists[i], vertices(graph))

m = Model(Ipopt.Optimizer)
ys = map(enumerate(column_groups)) do (column, nodes)
    y_min = 0  # IPOpt can't find a solution without this
    y_max = 2length(nodes)  # Unclear why but this works better than any other way of centering it
    @variable(m, [nodes], base_name="y_$column", lower_bound=y_min, upper_bound=y_max)
end

node_vars = Dict{Int, VariableRef}() # lookup list from vertex index to variable
for (y, nodes) in zip(ys, column_groups)
    for n in nodes
        @assert !haskey(node_vars, n)
        node_vars[n] = y[n] # remember this for later
    end
end

# Root should be at origin
#y_root = node_vars[first(roots)]
#@constraint(m,y_root == 5_000)


for (y, nodes) in zip(ys, column_groups)
    for n1 in nodes
        for n2 in nodes
            n1==n2 && continue
            # With in each column nodes must be at least 1 unit apart
            @constraint(m, 1 <= (y[n1] - y[n2])^2)
        end
    end
end

# Make all links as short as possible
@objective(m, Min, sum(
    (node_vars[link.src]-node_vars[link.dst])^2 
    for link in edges(graph)
))

optimize!(m)


############
# Lets visualise the solution.
using Plots

coords = Dict{Int, Tuple{Float64, Float64}}()
for (column, nodes) in enumerate(column_groups)
    for node in nodes
        x = column
        y = value(node_vars[node])
        coords[node] = (x, y)
    end
end

scatter(
    first.(values(coords)), last.(values(coords));
    text=string.(keys(proj.task_durations)[i] for i in keys(coords)),
)
xs = Float64[]
ys = Float64[]
for edge in edges(graph)
    x1, y1 = coords[edge.src]
    x2, y2 = coords[edge.dst]
    append!(xs, [x1, x2, NaN])
    append!(ys, [y1, y2, NaN])
end
plot!(xs, ys; legend=false)

