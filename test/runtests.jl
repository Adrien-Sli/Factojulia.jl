# inside test/runtests.jl

using Test
using CSV, DataFrames
using FactoJulia

# Path to CSV in the same folder as this test file
csv_path = joinpath(@__DIR__, "test_data.csv")
df = CSV.read(csv_path, DataFrame; missingstring=["Na", "NA", ""])

@testset "FactoJulia smoke tests with custom dataset" begin
    # Simple tests...
    @test isa(df, DataFrame)

    # Run PCA_ without plots
    res = PCA_(df; scale=true, ncp=3, dropNa=true, graph=true)

    @test isa(res, NamedTuple)
    @test haskey(res, :scores)
    # ... rest of the tests ...
end
