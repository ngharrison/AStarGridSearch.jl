#%%

using FileIO: load, save

img = load("maps/obstacles_full.tif")

occupancy = [(px.color.b == px.color.g == px.color.r == 0) for px in img]

start = CartesianIndex(180,650)
goals = [
    CartesianIndex(5,400),
    CartesianIndex(10,990),
    CartesianIndex(950,950),
    CartesianIndex(650,900),
    CartesianIndex(885,200),
    CartesianIndex(150,550),
    CartesianIndex(30,20),
    CartesianIndex(900,85),
    CartesianIndex(370,100),
]
res = (1,1)

#%%
using AStarGridSearch

pathCost = PathCost(start, occupancy, res)

pathCost.(goals)

paths = [Tuple.(getPath(pathCost, goals[i])) for i in eachindex(goals)]

#%%
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

axislegend(; position = :rc)

display(p)

save("img/full_field_paths.png", p)
