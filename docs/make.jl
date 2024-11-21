using AStarGridSearch
using Documenter

DocMeta.setdocmeta!(AStarGridSearch, :DocTestSetup, :(using AStarGridSearch); recursive=true)

makedocs(;
    modules=[AStarGridSearch],
    authors="Nicholas Harrison",
    sitename="AStarGridSearch.jl",
    format=Documenter.HTML(;
        canonical="https://ngharrison.github.io/AStarGridSearch.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ngharrison/AStarGridSearch.jl",
    devbranch="main",
)
