@testset "Plotting $f" for f in (:empty, :onetask, :chain, :shortlong, :medium)
    # Just making sure no errors are thrown
    proj = getfield(Examples, f)
    pert_chart = visualize_chart(proj)
end
