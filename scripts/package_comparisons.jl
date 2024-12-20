# Note: this code is for interactive comparisons and requires installing the
# other packages

#*
using BenchmarkTools

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

valid = findall(!, occupancy)

start = CartesianIndex(41, 39)
goal = CartesianIndex(69, 89)
res = (1, 1)

m = 50000

#*
using AStarGridSearch

pathCost = PathCost(start, occupancy, res)
pathCost(goal)
p1 = Tuple.(getPath(pathCost, goal))

function runAStarGridSearch(m)
    pathCost = PathCost(start, occupancy, res)
    for _ in 1:m
        local goal = rand(valid)
        pathCost(goal)
    end
end

@benchmark runAStarGridSearch(m)

#*
using GridGraphs

gg_weights = ones(n, n)
vertex_activities = .!occupancy

sgg = GridGraph(gg_weights;
    vertex_activities,
    directions=QUEEN_DIRECTIONS,
    nb_corners_for_diag=1,
    pythagoras_cost_for_diag=true)

si = coord_to_index(sgg, Tuple(start)...)
spt = grid_dijkstra(sgg, si)
p2 = index_to_coord.(Ref(sgg), get_path(spt, si, gi))

function runGridGraphs(m)
    gg_weights = ones(n, n)
    vertex_activities = .!occupancy

    sgg = GridGraph(gg_weights;
        vertex_activities,
        directions=QUEEN_DIRECTIONS,
        nb_corners_for_diag=1,
        pythagoras_cost_for_diag=true)

    si = coord_to_index(sgg, Tuple(start)...)

    spt = grid_dijkstra(sgg, si)

    for _ in 1:m
        local goal = rand(valid)
        local gi = coord_to_index(sgg, Tuple(goal)...)
        spt.dists[gi]
    end
end

@benchmark runGridGraphs(m)

#*
using Graphs

# create a graph for path finding
graph = grid(size(occupancy))
li = LinearIndices(occupancy)
m, n = size(occupancy)
for i in 1:m, j in 1:n-1
    if occupancy[i,j]
        i < m && rem_edge!(graph, li[i,j], li[i+1,j])
        rem_edge!(graph, li[i,j], li[i,j+1])
        continue
    end
    i < m && occupancy[i+1,j] && rem_edge!(graph, li[i,j], li[i+1,j])
    occupancy[i,j+1] && rem_edge!(graph, li[i,j], li[i,j+1])
    i < m && !occupancy[i+1,j+1] && add_edge!(graph, li[i,j], li[i+1,j+1])
    i > 1 && !occupancy[i-1,j+1] && add_edge!(graph, li[i,j], li[i-1,j+1])
end

# give diagonal paths correct distance in weight matrix
graph_weights = ones(size(graph))
ci = CartesianIndices(occupancy)
for i in axes(graph_weights, 1), j in axes(graph_weights, 2)
    diff = ci[i] - ci[j]
    if abs(diff[1]) == 1 && abs(diff[2]) == 1
        graph_weights[i,j] = sqrt(sum(res .^ 2))
    elseif abs(diff[1]) == 1
        graph_weights[i,j] = res[1]
    elseif abs(diff[2]) == 1
        graph_weights[i,j] = res[2]
    end
end

getGraphIndex(x, occupancy) = LinearIndices(occupancy)[x]

getMapIndex(i, occupancy) = CartesianIndices(occupancy)[i]

function graphPathCost(start, goal, graph, occupancy)
    # if either point is within an obstacle, just return infinity
    (occupancy[start] || occupancy[goal]) && return Inf

    # calculate cost
    s, t = getGraphIndex.((start, goal), Ref(occupancy))
    heuristic = v->sqrt(sum(Tuple(goal - getMapIndex(v, occupancy)).^2))
    path = a_star(graph, s, t, graph_weights, heuristic)
    return path, isempty(path) ? 0.0 : sum(graph_weights[e.src, e.dst] for e in path)
end

path, cost = graphPathCost(start, goal, graph, occupancy)
p3 = Tuple.(getMapIndex.([first.(Tuple.(path))..., last(Tuple(path[end]))], Ref(occupancy)))

function runGraphs(m)
    si = getGraphIndex(start, occupancy)
    ps = dijkstra_shortest_paths(graph, si, graph_weights)
    for _ in 1:m
        local goal = rand(valid)
        # graphPathCost(start, goal, graph, occupancy)
        local gi = getGraphIndex(goal, occupancy)
        ps.dists[gi]
    end
end

@benchmark runGraphs(m)

#*
using AStarSearch

const UP = CartesianIndex(-1, 0)
const DOWN = CartesianIndex(1, 0)
const LEFT = CartesianIndex(0, -1)
const RIGHT = CartesianIndex(0, 1)
const UP_LEFT = UP + LEFT
const UP_RIGHT = UP + RIGHT
const DOWN_LEFT = DOWN + LEFT
const DOWN_RIGHT = DOWN + RIGHT
const DIRECTIONS = [UP, DOWN, LEFT, RIGHT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT]

# euclidean distance between positions in the maze matrix
euclidean(a::CartesianIndex, b::CartesianIndex) = sqrt(sum((b - a).I .^ 2))
# check to be in the maze and filter out moves that go into walls
function mazeneighbours(maze, p)
  res = CartesianIndex[]
  for d in DIRECTIONS
      n = p + d
      if 1 ≤ n[1] ≤ size(maze)[1] && 1 ≤ n[2] ≤ size(maze)[2] && !maze[n]
          push!(res, n)
      end
  end
  return res
end

currentmazeneighbours(state) = mazeneighbours(occupancy, state)

result = astar(currentmazeneighbours, start, goal;
               heuristic=euclidean,
               cost=euclidean)

result.cost
p4 = Tuple.(result.path)

function runAStarSearch(m)
    for _ in 1:m
        local goal = rand(valid)
        result = astar(currentmazeneighbours, start, goal;
            heuristic=euclidean,
            cost=euclidean)
    end
end

@benchmark runAStarSearch(1000)

#*
using CairoMakie

p = plot(pathCost.costMatrix)
scatter!(p1; label="Path 1", color=:gray)
display(p)

#*
p = plot(occupancy)
scatter!(p1; label="Path 1")
scatter!(p2; label="Path 2")
scatter!(p3; label="Path 3")
scatter!(p4; label="Path 4")

scatter!(Tuple(start); label="Start")
scatter!(Tuple(goal); label="Goal")

axislegend()

display(p)
