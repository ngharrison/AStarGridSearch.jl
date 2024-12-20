# AStarGridSearch

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ngharrison.github.io/AStarGridSearch.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ngharrison.github.io/AStarGridSearch.jl/dev/)
[![Build Status](https://github.com/ngharrison/AStarGridSearch.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ngharrison/AStarGridSearch.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## Overview

This package contains types and methods for searching for paths on a 2D grid using the A* algorithm. Its main purpose is to provide a way to efficiently compute the path cost (distance) from a single starting cell to many goal cells as chosen in the user's code. The intended scenario for the path cost is to be included within an optimization objective function, causing the cost to be calculated many times for different points in space. Because of this use case, the provided type is also made callable so it can be used directly as a function itself. The type can also return the full path if desired. See the documentation for more details and usage examples.

## Installation

This package is registered and can be installed using Julia's builtin package manager:

``` julia
using Pkg; Pkg.add("GridMaps")
```

## Relation to other packages

(relevant as of Dec 19, 2024)

- [AStarSearch](https://github.com/PaoloSarti/AStarSearch.jl) -- Provides a general A* algorithm (along with a few uninformed path searches). Doesn't cover a way to save path cost data to be reused for further searches and so less efficient for planning multiple paths from the same starting state.
- [Graphs](https://github.com/JuliaGraphs/Graphs.jl) -- A large package with APIs and all sorts of graph creation and manipulation methods and graph algorithms. Has efficient A* and dijkstra implementations. Specifically appropriate use of the dijkstra algorithm can be suitable for the use case of this package. Has a grid graph constructor but the builtin only has connectivity along the square sides and not diagonals. Computationally intensive to add the extra edges and euclidean distance weights needed for spatial path planning.
- [GridGraphs](https://github.com/gdalle/GridGraphs.jl) -- Provides a GridGraph type, choices of directions for connectedness, and dijkstra's algorithm (as well as a couple other shortest-paths algorithms). No A* currently, but the dijkstra path finding is efficient and an appropriate use of it can be somewhat faster and use less memory for the use case of this package. However, it doesn't yet have edge weights that are dependent on both of the vertices they each connect, so it can't handle graphs with different spatial resolutions in each graph direction. This addition could make this a more viable option than this package as it currently stands.

