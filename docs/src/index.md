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


You can add keyword arguments by passing a `NamedTuple`
```julia
julia> sort_by_length = sort $ (;by = length)
sort(...; by = length, ...)

julia> sort_by_length([[1,2,3], [1,2]])
2-element Vector{Vector{Int64}}:
 [1, 2]
 [1, 2, 3]
```

You can pass arguments and keyword arguments at the same time
```julia
julia> a = [[1,2,3], [1,2]];

julia> sort_a_by_length = sort $ (a, (;by = length))
sort([[1, 2, 3], [1, 2]], ...; by = length, ...)

julia> sort_a_by_length()
2-element Vector{Vector{Int64}}:
 [1, 2]
 [1, 2, 3]
```

You can also pass a tuple of arguments to this form, or pass the args first then the keyword args second to reduce the number of parentheses. Care must be taken here to avoid unintended results.

```julia
# These are equivalent
sort $ a $ (;by = length)
sort $ (a, (;by = length))
sort $ ((a,), (;by = length))
```
The following are incorrect, or will yield unintended results
```julia
julia> a = [[1,2,3], [1,2]];

julia> sort $ (a, by = length)
sort(..., a = [[1,2,3], [1,2]], by = length)
```
In this first case, `a` is parsed as a part of the NamedTuple and is thus treated as a keyword argument instead of a positional argument

```julia
julia> sort $ (a; by = length)
sort(length, ... )
```
In the second case, the argument to `julia $` is simply a block of two expressions, the result of which is the function `length`.


## Examples

```julia-repl
julia> using PartialFunctions

julia> a(x) = x^2
a (generic function with 1 method)

julia> f = map $ a
map(a, ...)

julia> f([1,2,3])
3-element Vector{Int64}:
 1
 4
 9
```

```jldoctest
julia> simonsays = println $ "Simon says: "
println("Simon says: ", ...)

julia> simonsays("Partial function application is cool!")
Simon says: Partial function application is cool!
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

