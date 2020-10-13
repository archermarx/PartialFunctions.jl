using PartialFunctions
using Test

a(x) = x^2
greet(greeting, name, punctuation) = "$(greeting), $(name)$(punctuation)"

@testset "Partial functions" begin
    @test map((+)$2, [1,2,3]) == [3, 4, 5]
    @test repr(map $ a) == "map(a, ...)"
    @test (map $ a)([1, 2, 3]) == [1, 4, 9]
    
    @test greet("Hello", "Bob", "!") == "Hello, Bob!"
    sayhello = greet $ "Hello"
    @test repr(sayhello) == "greet(\"Hello\", ...)"
    @test repr("text/plain", sayhello) == repr(sayhello)

    @test sayhello("Bob", "!") == "Hello, Bob!"
    hi_bob = greet $ "Hi" $ "Bob" $ "!"
    @test hi_bob isa PartialFunctions.PartialFunction{typeof(greet), Tuple{String, String, String}}
    @test hi_bob <| () == "Hi, Bob!"
    @test sayhello <| ("Jimmy", "?")... == "Hello, Jimmy?"

    @test greet $ ("Hi", "Bob") <| "!" == "Hi, Bob!"
end

@testset "Reversed functions" begin
    revmap = flip(map)
    @test flip(revmap) == map
    @test revmap([1,2,3], sin) == map(sin, [1,2,3])
    
    func(x, y) = x - y
    func(x, y, z) = x - y - z 
    @test func(1, 2) == -1
    @test func(1, 3, 6) == -8
    flipped = flip(func)
    @test flipped(2, 1) == -1
    @test flipped(3, 2, 1) == -4 
    
end