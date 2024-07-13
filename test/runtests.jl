using SafeTestsets, Test

@safetestset "SafeTestsets Tests" begin
    @safetestset "Tests" begin
        include("tests.jl")
        @test @isdefined(a) == true
    end

    @safetestset "Tests" include("tests.jl")

    @test @isdefined(a) == false

    @safetestset MyTests = "Tests" begin
        include("tests.jl")
        @test @isdefined(a) == true
    end

    @test @isdefined(a) == false
    @test @isdefined(MyTests) == true

    @safetestset "external macros" begin
        expr = :(@ccallable Cvoid f() = nothing)
        @test_throws UndefVarError Meta.macroexpand(@__MODULE__(), expr)

        # Use another `@safetestset` to import `@ccallable`
        @safetestset "b" begin
            using Base: @ccallable
            expr = :(@ccallable Cvoid f() = nothing)
            @test Meta.macroexpand(@__MODULE__(), expr) isa Expr
        end
    end
end
