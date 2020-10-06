```@meta
CurrentModule = PartialFunctions
DocTestSetup = quote
    using PartialFunctions
end
```

# PartialFunctions

This is a small Julia package that makes partial function application as simple as possible

## Usage

To apply an argument `x` to a function `f`, use the `$` binary operator like so

```julia-repl
julia> f $ x
f(x, ...)
```

To apply multiple arguments, wrap them in a `Tuple`, like you would a normal function call
```julia-repl
julia> f $ (x, y, z)
f(x, y, z, ...)
```

```jldoctest
julia> f = println $ (("This is", "a Tuple"),)
println(("This is", "a Tuple"), ...)

julia> f(", and this is an additional argument")
("This is", "a Tuple"), and this is an additional argument
```

## Examples

```jldoctest
julia> using PartialFunctions

julia> a(x) = x^2
a (generic function with 1 method)

julia> f = map $ a
map(a, ...)

julia> f([1,2,3])
3-element Array{Int64,1}:
 1
 4
 9
```
 
```jldoctest
julia> simonsays = println $ "Simon says: "
println("Simon says: ", ...)

julia> simonsays("Partial function application is cool!")
Simon says: Partial function application is cool!

julia> typeof(simonsays)
PartialFunctions.PartialFunction{typeof(println),Tuple{String}}
```

## The Reverse Pipe

PartialFunctions also exports the `<|`, or "reverse pipe" operator, which can be used to apply the arguments succeeding it to the function preceding it. This operator has low precedence, making it useful when chaining function calls if one wants to avoid a lot of parentheses

Here's an extremely contrived example to add a bunch of numbers together
```jldoctest
julia> (+) $ 2 $ 3 $ 5 $ 10 <| 12
32
```

Unlike the normal pipe (`|>`), it can also be used with tuples of arguments
```jldoctest
julia> (+) <| (1, 2)...
3
```

Passing an empty tuple calls the preceding function with zero arguments
```jldoctest
julia> a = isequal $ (1, 2)
isequal(1, 2, ...)

julia> isequal $ (1, 2) <| ()   # equivalent to a() or isequal(1, 2)
false
```

