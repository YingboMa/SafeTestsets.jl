module SafeTestsets

export @safetestset
export @safetimedtestset

const err = ArgumentError("""
              Use `@safetestset` like the following:
              @safetestset "Benchmark Tests" begin include("benchmark_tests.jl") end
              @safetestset BenchmarkTests = "Benchmark Tests" begin include("benchmark_tests.jl") end
              """)

const errt = ArgumentError("""
              Use `@safetimedtestset` like the following:
              times = Dict()
              @safetimedtestset times "Benchmark Tests" begin include("benchmark_tests.jl") end
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
    quote
        @eval module $mod
            using Test, SafeTestsets
            @testset $testname $expr
        end
        nothing
    end
end

macro safetimedtestset(times, args...)
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
    quote
        $(esc(times))[$testname] = @elapsed @time @eval module $mod
            using Test, SafeTestsets
            @testset $testname $expr
            end
        nothing
    end
end

end # module
