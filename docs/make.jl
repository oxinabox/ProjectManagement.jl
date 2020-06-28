using Documenter, ProjectManagement

include("create_demos.jl")
create_demofiles()


makedocs(;
    modules=[ProjectManagement],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Demos" => [
            replace(file[1:end-2], "_"=>" ") => joinpath("demos", file) 
            for file in readdir(joinpath(@__DIR__, "src", "demos"))
        ],
        "API" => "API.md",
    ],
    repo="https://github.com/oxinabox/ProjectManagement.jl/blob/{commit}{path}#L{line}",
    sitename="ProjectManagement.jl",
    authors="Lyndon White",
)

deploydocs(;
    repo="github.com/oxinabox/ProjectManagement.jl",
    push_preview=true,
)
