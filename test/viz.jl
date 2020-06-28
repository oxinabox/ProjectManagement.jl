using ProjectManagement
using GraphRecipes
using Plots

graphplot(
    [0 1; 0 0];
    arrow="->",
    nodeshape=[:rect, :hexagon],
    names = ["a" "start"],
)



tasks = (
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
)

links = [
    :start .=> [:a, :b, :c, :d];
    :a => :f;
    :b .=> [:f, :g];
    [:c, :d] .=> :e;
    :e .=> [:f, :g, :h];
    [:f, :g, :h] .=> :j;
    :j => :finish;
]

plot(PertChart(tasks, links))
