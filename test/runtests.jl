using SafeTestsets, Test

@safetestset "SafeTestsets Tests" begin
    @safetestset "Tests" begin
        include("tests.jl")
        @isdefined(a) == true
    end
    @safetestset "Tests" include("tests.jl")

    @test @isdefined(a) == false

    @safetestset MyTests = "Tests" begin
        include("tests.jl")
        @isdefined(a) == true
    end

    @test @isdefined(a) == false
    @test @isdefined(MyTests) == true
end
