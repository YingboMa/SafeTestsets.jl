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
        expr = Expr(:block, expr)
    end

    user_imports = Any[]
    block = Expr(:block)
    for arg in expr.args
        if arg isa Expr && (arg.head === :using || arg.head === :import)
            push!(user_imports, arg)
        else
            push!(block.args, arg)
        end
    end

    quote
        @eval module $mod
            using Test, SafeTestsets
            $(user_imports...)
            @testset $testname $block
        end
    end
end

end # module
