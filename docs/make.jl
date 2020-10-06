using PartialFunctions
using Documenter

makedocs(;
    modules=[PartialFunctions],
    authors="Thomas Marks <marksta@umich.edu> and contributors",
    repo="https://github.com/archermarx/PartialFunctions.jl/blob/{commit}{path}#L{line}",
    sitename="PartialFunctions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://archermarx.github.io/PartialFunctions.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Internals" => "internals.md"
    ],
)

deploydocs(;
    repo="github.com/archermarx/PartialFunctions.jl",
)
