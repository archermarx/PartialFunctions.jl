using MacroTools

struct GeneralizedPartialFunction{L, F<:Function, T<:NamedTuple, N<:NamedTuple} <: Function
    expr_string::String
    func::F
    args::T
    kwargs::N
end

Base.show(io::IO, pf::GeneralizedPartialFunction) = print(io, pf.expr_string)
Base.show(io::IO, ::MIME"text/plain", pf::GeneralizedPartialFunction) = print(io, pf.expr_string)

function GeneralizedPartialFunction(expr_string::String, f::F, loc::Tuple, args::T,
                                    kwargs::N) where {F<:Function, T<:NamedTuple,
                                                      N<:NamedTuple}
    return GeneralizedPartialFunction{loc, typeof(f), T, N}(expr_string, f, args, kwargs)
end

@generated function (pf::GeneralizedPartialFunction{loc, F, T})(args...; kwargs...) where {loc, F, T}
    L = length(args)
    kloc = fieldnames(T)
    if L == length(loc)
        # Execute the function
        final_args = []
        total_args = length(loc) + length(kloc)
        j, k = 1, 1
        for i in 1:total_args
            if i ∈ loc
                push!(final_args, :(args[$j]))
                j += 1
            else
                push!(final_args, :(pf.args[$k]))
                k += 1
            end
        end
        return quote
            @show pf.func
            @show typeof.(($(final_args...),))
            pf.func($(final_args...); pf.kwargs..., kwargs...)
        end
    else
        # Construct another GeneralizedPartialFunction
    end
end

macro ($)(expr::Expr)
    if !@capture(expr, f_(args__; kwargs__) | f_(args__))
        throw(ArgumentError("Only function calls are supported!"))
    end

    kwargs = kwargs === nothing ? [] : kwargs

    underscore_args_pos = Tuple(findall(x -> x == :_, args))
    if length(args) == 0 || length(underscore_args_pos) == 0
        return :($(esc(expr)))
    end

    kwargs_keys = Symbol[]
    kwargs_values = Any[]
    for kwarg in kwargs
        @assert kwarg.head == :kw "Malformed keyword argument!"
        push!(kwargs_keys, kwarg.args[1])
        push!(kwargs_values, kwarg.args[2])
    end
    final_kwargs = NamedTuple{Tuple(kwargs_keys)}(kwargs_values)

    non_underscore_args_pos = Tuple(setdiff(1:length(args), underscore_args_pos))
    non_underscore_args = map(Base.Fix1(getindex, args), non_underscore_args_pos)
    stored_args = NamedTuple{Symbol.(non_underscore_args_pos)}(non_underscore_args)

    return :(GeneralizedPartialFunction($(esc(string(expr))), $(esc(f)),
                                        $(esc(underscore_args_pos)), $(esc(args)),
                                        $(esc(final_kwargs))))
end
