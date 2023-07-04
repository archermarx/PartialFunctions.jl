using PartialFunctions
using Documenter

push!(LOAD_PATH,"../src/")

makedocs(;
    sitename = "PartialFunctions.jl",
    pages=[
        "Home" => "index.md",
        "Internals" => "internals.md"
    ],
)

deploydocs(;
    repo="github.com/archermarx/PartialFunctions.jl.git",
)
