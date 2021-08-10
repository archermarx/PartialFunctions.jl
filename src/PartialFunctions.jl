module PartialFunctions

export $, <|
include("reversedfunctions.jl")

name = (string ∘ Symbol)

struct PartialFunction{F<:Function, T<:Tuple, N<:NamedTuple} <: Function
    func::F
    args::T
    kwargs::N
    PartialFunction(f, args::T, kwargs::N) where {T<:Tuple, N<:NamedTuple} = let
        new{typeof(f), T, N}(f, args, kwargs)
    end
end

function PartialFunction(f::PartialFunction, newargs::Tuple, newkwargs::NamedTuple)
    allargs = (f.args..., newargs...)
    allkwargs = (;f.kwargs..., newkwargs...)
    PartialFunction(f.func, allargs, allkwargs)
end

(p::PartialFunction)(newargs...; newkwargs...) = p.func(p.args..., newargs...; p.kwargs..., newkwargs...)

"""
    (\$)(f::Function, args...)
Partially apply the given arguments to f. Typically used as infix `f \$ args`

The returned function is of type [`PartialFunctions.PartialFunction{typeof(f), typeof(args)}`](@ref)

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

Base.show(io::IO, pf::PartialFunction) = print(io, name(pf))
Base.show(io::IO, ::MIME"text/plain", pf::PartialFunction) = show(io, pf)

end
