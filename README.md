# AStarGridSearch

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ngharrison.github.io/AStarGridSearch.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ngharrison.github.io/AStarGridSearch.jl/dev/)
[![Build Status](https://github.com/ngharrison/AStarGridSearch.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ngharrison/AStarGridSearch.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

This package contains types and methods for searching for paths on a 2D grid using the A* algorithm. Its main use is to get the path cost (distance), but it can return the full path as well. See the documentation for more details and use.

This package is registered and can be installed using Julia's builtin package manager:

``` julia
using Pkg; Pkg.add("GridMaps")
```
