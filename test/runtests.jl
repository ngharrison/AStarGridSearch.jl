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
    # Write your tests here.
end
