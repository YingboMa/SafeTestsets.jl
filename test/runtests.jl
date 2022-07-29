using SafeTestsets, Test

@safetestset "SafeTestsets Tests" begin
    @safetestset "Tests" begin
        include("tests.jl")
        @isdefined(a) == true
    end

    @test @isdefined(a) == false

    @safetestset MyTests = "Tests" begin
        include("tests.jl")
        @isdefined(a) == true
    end

    @test @isdefined(a) == false
    @test @isdefined(MyTests) == true
end

@safetestset "SafeTimedTestsets Tests" begin
    times = Dict()
    @safetimedtestset times "Tests A" begin
        include("tests.jl")
        @isdefined(a) == true
    end

    @test @isdefined(a) == false

    @safetimedtestset times MyTests = "Tests B" begin
        include("tests.jl")
        @isdefined(a) == true
    end

    @test @isdefined(a) == false
    @test @isdefined(MyTests) == true
    @test haskey(times, "Tests A")
    @test sort(collect(keys(times))) == ["Tests A", "Tests B"]
end
