using BitView
using Documenter

DocMeta.setdocmeta!(BitView, :DocTestSetup, :(using BitView); recursive=true)

makedocs(;
    modules=[BitView],
    authors="arhik <arhik23@gmail.com>",
    repo="https://github.com/arhik/BitView.jl/blob/{commit}{path}#{line}",
    sitename="BitView.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://arhik.github.io/BitView.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/arhik/BitView.jl",
    devbranch="main",
)
