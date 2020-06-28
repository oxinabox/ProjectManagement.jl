using Documenter, ProjectManagement

makedocs(;
    modules=[ProjectManagement],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/oxinabox/ProjectManagement.jl/blob/{commit}{path}#L{line}",
    sitename="ProjectManagement.jl",
    authors="Lyndon White",
)

deploydocs(;
    repo="github.com/oxinabox/ProjectManagement.jl",
    push_preview=true,
)
