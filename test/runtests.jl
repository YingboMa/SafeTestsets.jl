using SafeTestsets, Test

@safetestset "SafeTestsets Tests" begin
    ts = @safetestset "Tests" begin
        include("tests.jl")
        @test @isdefined(a) == true
    end
    @test ts isa Test.DefaultTestSet
    @test ts.n_passed == 2

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

    @safetestset "keep line numbers" begin
        # Returns all of the expressions associated with the given line number
        function expressions_with_line(expr::Expr, line::LineNumberNode)
            results = Any[]
            matched = false
            for arg in expr.args
                if arg isa LineNumberNode
                    matched = arg == line
                elseif matched
                    push!(results, arg)
                end

                if arg isa Expr
                    append!(results, expressions_with_line(arg, line))
                elseif arg isa QuoteNode && arg.value isa Expr
                    append!(results, expressions_with_line(arg.value, line))
                end
            end
            return results
        end

        expr = quote
            @safetestset "test" begin
                using Base: foo
            end
        end

        # The line number location of `using Base: foo` in `expr`
        location = LineNumberNode(@__LINE__() - 5, @__FILE__())

        found = expressions_with_line(Meta.macroexpand(@__MODULE__(), expr), location)
        @test first(found) == :(using Base: foo)
    end
end
