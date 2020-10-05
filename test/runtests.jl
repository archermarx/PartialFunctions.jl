using PartialFunctions
using Test

a(x) = x^2
greet(greeting, name, punctuation) = "$(greeting), $(name)$(punctuation)"
@testset "PartialFunctions.jl" begin
    @test map((+)$2, [1,2,3]) == [3, 4, 5]
    @test repr(map $ a) == "map(a, ...)"
    @test (map $ a)([1, 2, 3]) == [1, 4, 9]
    
    @test greet("Hello", "Bob", "!") == "Hello, Bob!"
    sayhello = greet $ "Hello"
    @test repr(sayhello) == "greet(\"Hello\", ...)"
    @test sayhello("Bob", "!") == "Hello, Bob!"
    hi_bob = greet $ "Hi" $ "Bob" $ "!"
    @test hi_bob isa PartialFunctions.PartialFunction{typeof(greet), Tuple{String, String, String}}
end
