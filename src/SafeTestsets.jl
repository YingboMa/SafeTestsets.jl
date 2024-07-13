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

    # TODO: Line numbers aren't working yet for imports
    line = nothing
    user_imports = Any[]
    block = Expr(:block)
    for arg in expr.args
        if arg isa LineNumberNode
            line = arg
        elseif arg isa Expr && (arg.head === :using || arg.head === :import)
            isnothing(line) || (arg = Expr(:toplevel, line, arg))
            push!(user_imports, arg)
        else
            isnothing(line) || push!(block.args, line)
            push!(block.args, arg)
        end
    end
    testset_expr = :(@testset $testname $block)
    quote
        @eval $__module__ module $mod
            using Test, SafeTestsets
            $(user_imports...)
        end
        $__module__.$mod.eval($(QuoteNode(testset_expr)))
    end
end

end # module
