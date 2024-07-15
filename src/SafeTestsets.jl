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

    module_block = Expr(:block)
    module_expr = Expr(:module, true, mod, module_block)
    push!(module_block.args, :(using Test, SafeTestsets))

    line = nothing
    testset_block = Expr(:block)
    for arg in expr.args
        if arg isa LineNumberNode
            line = arg
        elseif arg isa Expr && (arg.head === :using || arg.head === :import)
            isnothing(line) || push!(module_block.args, line)
            push!(module_block.args, arg)
        else
            isnothing(line) || push!(testset_block.args, line)
            push!(testset_block.args, arg)
        end
    end

    push!(module_block.args, :(const ts = @testset $testname $testset_block))

    return Expr(:block,
        :($__module__.eval($(QuoteNode(module_expr)))),
        :($__module__.$mod.ts),
    )
end

end # module
