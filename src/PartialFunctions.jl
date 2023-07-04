module PartialFunctions

using MacroTools

export $, @$
export <|
include("reversedfunctions.jl")

name = (string ∘ Symbol)

struct PartialFunction{KL, UL, F<:Function, T<:Tuple, N<:NamedTuple} <: Function
    expr_string::String
    func::F
    args::T
    kwargs::N
end

function PartialFunction(f, args::T, kwargs::N) where {T<:Tuple, N<:NamedTuple}
    return PartialFunction{nothing, nothing, typeof(f), typeof(args), typeof(kwargs)}("", f, args, kwargs)
end

function PartialFunction(known_args_locations, unknown_args_locations, expr_string::String, f, args::T, kwargs::N) where {T<:Tuple, N<:NamedTuple}
    return PartialFunction{known_args_locations, unknown_args_locations, typeof(f), T, N}(expr_string, f, args, kwargs)
end

function PartialFunction(f::PartialFunction, newargs::Tuple, newkwargs::NamedTuple)
    allargs = (f.args..., newargs...)
    allkwargs = (;f.kwargs..., newkwargs...)
    PartialFunction(f.func, allargs, allkwargs)
end

(p::PartialFunction{nothing})(newargs...; newkwargs...) = p.func(p.args..., newargs...; p.kwargs..., newkwargs...)

"""
    (\$)(f::Function, args...)
Partially apply the given arguments to f. Typically used as infix `f \$ args`

The returned function is of type [`PartialFunctions.PartialFunction{nothing, nothing, typeof(f), typeof(args)}`](@ref)

# Examples

```jldoctest
julia> using PartialFunctions

julia> simonsays = println \$ "Simon says: "
println("Simon says: ", ...)

julia> simonsays("Partial function application is cool!")
Simon says: Partial function application is cool!
```
"""
($)(f::Function, args::Tuple) = PartialFunction(f, args, (;))
($)(f::Function, arg) = PartialFunction(f, (arg,), (;))
($)(f::Function, kwargs::NamedTuple) = PartialFunction(f, (), kwargs)
($)(f::Function, n::Tuple{<:Tuple, <:NamedTuple}) = let (args, kwargs) = n
    PartialFunction(f, args, kwargs)
end
($)(f::Function, n::Tuple{<:Any, <:NamedTuple}) = let (arg, kwargs) = n
    PartialFunction(f, (arg,), kwargs)
end

($)(f::DataType, args) = ($)(identity∘f, args)

@generated function (pf::PartialFunction{kloc, uloc})(args...; kwargs...) where {kloc, uloc}
    L = length(args)
    if L == length(uloc)
        # Execute the function
        final_args = []
        total_args = length(uloc) + length(kloc)
        j, k = 1, 1
        for i in 1:total_args
            if i ∈ uloc
                push!(final_args, :(args[$j]))
                j += 1
            else
                push!(final_args, :(pf.args[$k]))
                k += 1
            end
        end
        return quote
            pf.func($(final_args...); pf.kwargs..., kwargs...)
        end
    else
        return :(pf $ (args..., (; kwargs...)))
    end
end


"""
    @\$ f(args...; kwargs...)

Partially apply the given arguments to `f`. Unknown arguments are represented by `_`.

!!! note
    If no `_` is present, the function is executed immediately.

# Examples

```jldoctest
julia> matmul(A, X, B; C = 1) = A * X .+ B .* C
matmul (generic function with 1 method)

julia> A = randn(2, 2); B = rand(2, 2); X = randn(2, 2);

julia> pf = @\$ matmul(_, X, _; C = 2)
matmul(_, X, _; C = 2)

julia> pf(A, B) ≈ matmul(A, X, B; C = 2)
true
```
"""
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
    kwargs_keys = Tuple(kwargs_keys)

    non_underscore_args_pos = Tuple(setdiff(1:length(args), underscore_args_pos))
    non_underscore_args = map(Base.Fix1(getindex, args), non_underscore_args_pos)
    stored_args = NamedTuple{Symbol.(non_underscore_args_pos)}(non_underscore_args)

    return :(PartialFunction($(esc(non_underscore_args_pos)),
                             $(esc(underscore_args_pos)),
                             $(esc(string(expr))), $(esc(f)),
                             $(esc(tuple))($(esc.(non_underscore_args)...)),
                             $(NamedTuple{kwargs_keys})(tuple($(esc.(kwargs_values)...)))))
end

"""
    <|(f, args)

Applies a function to the succeeding argument or tuple of arguments. Acts as the reverse
of [`|>`](@ref), and is especially useful when combined with partial functions for
an alternative, low-parenthese function chaining syntax

# Examples
```@jldoctest
julia> using PartialFunctions

julia> isdigit <| '1'
true

julia> (+) <| (2, 3)...
5

julia> map \$ Int <| [1.0, 2.0, 3.0]
3-element Array{Int64,1}:
 1
 2
 3
```
"""
(<|)(f::Function, args...) = f(args...)
(<|)(f::Function, ::Tuple{}) = f()

function Base.Symbol(pf::PartialFunction)
    func_name = name(pf.func)
    argstring = "(" * join(repr.(pf.args), ", ") *", ..."
    if isempty(pf.kwargs)
        argstring *= ")"
    else
        argstring *= "; " * strip(repr(pf.kwargs), ['(', ')']) * " ...)"
    end
    Base.Symbol("$(func_name)$(argstring)")
end

Base.show(io::IO, pf::PartialFunction{nothing}) = print(io, name(pf))
Base.show(io::IO, ::MIME"text/plain", pf::PartialFunction{nothing}) = show(io, pf)
Base.show(io::IO, pf::PartialFunction) = print(io, pf.expr_string)
Base.show(io::IO, ::MIME"text/plain", pf::PartialFunction) = print(io, pf.expr_string)

end
