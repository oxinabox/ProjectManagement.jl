# Demos

### Defining the Project object

We start by defining the [`Project`](@ref) object.

```@example {{NAME}}
using ProjectManagement

proj = {{CONSTRUCTION}}
```

### Visualizing the PERT Chart

```@example {{NAME}}
using Plots
plot(PertChart(proj))
```

### Critical Path

We can compute the critical path and it's cost using the [`critical_path`](@ref) function.

```@example {{NAME}}
critical_path(proj)
```

We can compute all the path costs using [`path_durations`](@ref).
For example we can find the critical path and near critical paths as:

```@example {{NAME}}
path_durations(proj)[1:min(3, end)]
```

### Sampling Durations

Using that [`Project`](@ref) object we can sample possible durations of the project.
Which allows for statistical analysis of possible outcomes.

```@repl {{NAME}}
using Statistics

duration_samples = rand(proj, 100_000);

mean(duration_samples)
minimum(duration_samples)
quantile(duration_samples, 0.25)
median(duration_samples)
quantile(duration_samples, 0.75)
maximum(duration_samples)
```

We can plot the distribution showing the probability density function for project completion duration.

```@example {{NAME}}
density(proj; legend=false)
```
