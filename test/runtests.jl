using AStarGridSearch
using Test
using Aqua
using JET

@testset "AStarGridSearch.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(AStarGridSearch)
    end

    @testset "Code linting (JET.jl)" begin
        JET.test_package(AStarGridSearch; target_defined_modules = true)
    end

    @testset "Basic functionality" begin
        occupancy = zeros(Bool, 10, 10) # open area
        start = CartesianIndex(2, 3)
        pathCost = PathCost(start, occupancy, (1, 1))

        @test pathCost(start) == 0 # zero
        @test pathCost(start + CartesianIndex(1, 0)) == 1 # single cell down
        @test pathCost(start + CartesianIndex(-1, 0)) == 1 # single cell up
        @test pathCost(start + CartesianIndex(0, 1)) == 1 # single cell right
        @test pathCost(start + CartesianIndex(0, -1)) == 1 # single cell left

        @test pathCost(start + CartesianIndex(1, 1)) ≈ √2 # diagonal
        a, b = 2, 4
        @test pathCost(start + CartesianIndex(a, b)) ≈ abs(b - a) + min(a, b) * √2 # straight and diagonal

        @test pathCost(start + CartesianIndex(0, 7)) ≈ 7 # to edge

        a, b = 8, 7
        @test pathCost(start + CartesianIndex(a, b)) ≈ abs(b - a) + min(a, b) * √2 # to corner

        # out of bounds
        @test_throws BoundsError pathCost(start + CartesianIndex(-2, 0))

        a, b = 2, 4
        r1, r2 = 0.24, 1.1 # different resolution
        pathCost = PathCost(start, occupancy, (r1, r2))
        @test pathCost(start + CartesianIndex(a, b)) ≈ (b - a) * r2 + a√(r1^2 + r2^2) # straight and diagonal

        # obstacle
        occupancy = zeros(Bool, 10, 10)
        obstacle = CartesianIndex.([
            tuple.(2, 3:5)...,
            tuple.(3, 3:5)...,
            tuple.(4, 4:6)...,
            tuple.(5, 5:7)...,
            tuple.(6, 4:6)...,
            tuple.(7, 3:5)...,
            tuple.(8, 3:5)...,
        ])
        occupancy[obstacle] .= 1

        start = CartesianIndex(4, 3)
        pathCost = PathCost(start, occupancy, (1, 1))
        @test pathCost(CartesianIndex(7, 9)) ≈ 7 + 4√2

        @test pathCost(CartesianIndex(7, 9)) ≈ 7 + 4√2 # redo

        path = [
            CartesianIndex(4, 3),
            CartesianIndex(5, 3),
            CartesianIndex(6, 3),
            CartesianIndex(7, 2),
            CartesianIndex(8, 2),
            CartesianIndex(9, 3),
            CartesianIndex(9, 4),
            CartesianIndex(9, 5),
            CartesianIndex(9, 6),
            CartesianIndex(9, 7),
            CartesianIndex(8, 8),
            CartesianIndex(7, 9)
        ]

        @test getPath(pathCost, CartesianIndex(7, 9)) == path
        @test finalOrientation(pathCost, CartesianIndex(7, 9)) ≈ 3π / 4
    end
end
