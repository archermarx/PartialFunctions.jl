export flip

struct ReversedFunction{F<:Function} <: Function
    func::F
    ReversedFunction(rf::ReversedFunction) = rf.func
    ReversedFunction(f::F) where F<:Function = new{F}(f)
end

(r::ReversedFunction)(args...) = r.func(reverse(args)...)

"""
    flip(f::Function)
Creates a function which takes arguments in backwards order from f, that is last argument first, and so on. Returns a
[`PartialFunctions.ReversedFunction{typeof(f)}`](@ref). Flipping a ReversedFunction returns the original function.

## Examples

```jldoctest
julia> firstsecond(first, second) = (first = first, second = second)
firstsecond (generic function with 1 method)

julia> firstsecond("First thing", "Second thing")
(first = "First thing", second = "Second thing")

julia> using PartialFunctions

julia> secondfirst = flip(firstsecond);

julia> secondfirst("First thing", "Second thing")
(first = "Second thing", second = "First thing")
```
"""
flip(f::F) where F<:Function = ReversedFunction(f)