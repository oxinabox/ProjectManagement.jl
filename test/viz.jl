@testset "Plotting $f" for f in (:empty, :onetask, :chain, :shortlong, :medium)
    # Just making sure no errors are thrown
    proj = getfield(Examples, f)
    pert_chart = PertChart(proj)
    result, = RecipesBase.apply_recipe(Dict{Symbol, Any}(), pert_chart)
end