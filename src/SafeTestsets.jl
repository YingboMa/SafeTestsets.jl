module SafeTestsets

export @safetestset


const err = ArgumentError("""
              Use `@safetestset` like the following:
              @safetestset "Benchmark Tests" begin include("benchmark_tests.jl") end
              @safetestset BenchmarkTests = "Benchmark Tests" begin include("benchmark_tests.jl") end
              """)
macro safetestset(args...)
    length(args) != 2 && throw(err)
    name, expr = args
    if name isa String
        mod = gensym(name)
        testname = name
    elseif name isa Expr && name.head == :(=) && length(name.args) == 2
        mod, testname = name.args
    else
        throw(err)
    end
    if expr isa Expr && (expr.head == :call || expr.head == :let)
        expr = :(begin
            $expr
        end)
    end
    quote
        @eval module $mod
            using Test, SafeTestsets
            @testset $testname $expr
        end
        nothing
    end
end

end # module
