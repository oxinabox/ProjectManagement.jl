# Demos

### Defining the Project object

We start by defining the `Project` object.

```@example {{NAME}}
using ProjectManagement

proj = {{CONSTRUCTION}}
```

### Visualizing the PERT Chart

```@example {{NAME}}
using Plots
plot(PertChart(proj))
```

### Sampling Durations

Using that `Project` object we can sample possible durations of the project.
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