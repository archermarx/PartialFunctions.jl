module PartialFunctions

export $, <|

name(x) = (string ∘ Symbol)(x)

struct PartialFunction{F<:Function, T<:Tuple} <: Function
    func::F
    args::T
    PartialFunction(f::F, args::T) where {F<:Function, T<:Tuple} = new{F, T}(f, args)
    function PartialFunction(f::PartialFunction, newargs::T) where T<:Tuple
        allargs = (f.args..., newargs...)
        new{typeof(f.func), typeof(allargs)}(f.func, allargs)
    end
end

(p::PartialFunction)(newargs...) = p.func(p.args..., newargs...)

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

julia> typeof(simonsays)
PartialFunctions.PartialFunction{typeof(println),Tuple{String}}
```
"""
($)(f::Function, args::Tuple) = PartialFunction(f, args)
($)(f::Function, arg) = PartialFunction(f, (arg,))

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
    argstring = "(" * join(repr.(pf.args), ", ") *", ...)"
    Base.Symbol("$(func_name)$(argstring)")
end

Base.show(io::IO, pf::PartialFunction) = print(io, name(pf))
Base.show(io::IO, ::MIME"text/plain", pf::PartialFunction) = show(io, pf)

end
