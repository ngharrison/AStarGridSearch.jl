#*

# obstacle
n = 100
occupancy = zeros(Bool, n, n)
obstacle = CartesianIndex.([
    tuple.((20:30)', 30:50)...,
    tuple.((30:40)', 30:50)...,
    tuple.((40:50)', 40:60)...,
    tuple.((50:60)', 50:70)...,
    tuple.((60:70)', 40:60)...,
    tuple.((70:80)', 30:50)...,
    tuple.((80:90)', 30:50)...,
])
occupancy[obstacle] .= 1

start = CartesianIndex(41, 39)
goals = [
    CartesianIndex(69, 89),
    CartesianIndex(20, 90),
    CartesianIndex(75, 65),
    CartesianIndex(85, 16),
    CartesianIndex(85, 95),
    CartesianIndex(10, 5),
]
res = (1, 1)

#*
using AStarGridSearch

pathCost = PathCost(start, occupancy, res)

pathCost.(goals)

paths = [Tuple.(getPath(pathCost, goals[i])) for i in eachindex(goals)]

#**
using CairoMakie
using FileIO: save

p = plot(pathCost.costMatrix)
p.axis.title = "1 Start, $(length(goals)) Goals, Shared Cost Map"

Colorbar(p.figure[:, end+1], p.plot, label="Cost")

for i in eachindex(paths)
    scatter!(paths[i]; color=:gray)
end

scatter!(Tuple(start); label="Goals", color=:orange)
scatter!(Tuple(start); label="Start", color=:blue)
for i in eachindex(paths)
    scatter!(Tuple(goals[i]); color=:orange)
end

axislegend(; position = :cb)

display(p)

save("img/blocks_paths.png", p)
