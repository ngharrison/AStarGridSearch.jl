#*

using FileIO: load, save

img = load("maps/obstacles.tif")

occupancy = [(px.b == px.g == px.r == 0) for px in img[401:end, 151:end]]

start = CartesianIndex(51,51)
goals = [
    CartesianIndex(275,430),
    CartesianIndex(500,1),
    CartesianIndex(550,800),
    CartesianIndex(250,750),
    CartesianIndex(590,550),
    CartesianIndex(110,390),
]
res = (1,1)

#*
using AStarGridSearch

pathCost = PathCost(start, occupancy, res)

pathCost.(goals)

paths = [Tuple.(getPath(pathCost, goals[i])) for i in eachindex(goals)]

#*
using CairoMakie
using FileIO: save

p = plot(pathCost.costMatrix)

Colorbar(p.figure[:, end+1], p.plot, label="Distance (m)")

mask = zeros(size(occupancy))
mask[.!occupancy] .= NaN
image!(mask; colorrange=[0.0, 1.0])

p.axis.title = "1 Start, $(length(goals)) Goals, Shared Distance Map"

for i in eachindex(paths)
    scatter!(paths[i]; color=:gray)
end

scatter!(Tuple(start); label="Goals", color=:orange)
scatter!(Tuple(start); label="Start", color=:blue)
for i in eachindex(paths)
    scatter!(Tuple(goals[i]); color=:orange)
end

axislegend(; position = :lt)

display(p)

save("img/field_paths.png", p)
