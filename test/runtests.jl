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
    @test hi_bob isa PartialFunctions.PartialFunction{typeof(greet), Tuple{String, String, String}, NamedTuple{(), Tuple{}}}
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

@testset "Keyword Arguments" begin
    a = [[1,2,3], [1,2]]
    sort_by_length = sort $ (; by = length)
    @test sort(a, by = length) == sort_by_length(a)

    sort_a_by_length = sort $ (a, (;by = length))
    @test sort(a, by = length) == sort_a_by_length()

    sort_a_by_length_2 = sort $ ((a,), (;by = length))
    @test sort_a_by_length == sort_a_by_length_2

    @test repr(sort_a_by_length) == "sort([[1, 2, 3], [1, 2]], ...; by = length, ...)"
end

@testset "Generalized Partial Functions" begin
    @test map(@$(+(2, _)), [1,2,3]) == [3, 4, 5]
    @test map(@$(+(_, 2)), [1,2,3]) == [3, 4, 5]
    @test repr(@$(map(a, _))) == "map(a, _)"
    @test (@$(map(a, _)))([1, 2, 3]) == [1, 4, 9]
    
    @test greet("Hello", "Bob", "!") == "Hello, Bob!"
    sayhello = @$ greet("Hello", _, _)
    @test repr(sayhello) == "greet(\"Hello\", _, _)"
    @test repr("text/plain", sayhello) == repr(sayhello)

    @test sayhello("Bob", "!") == "Hello, Bob!"

    sayhellobob = sayhello("Bob")
    @test repr(sayhellobob) == "greet(\"Hello\", _, _)(\"Bob\", ...)"
    @test sayhellobob("!") == "Hello, Bob!"

    hi_bob = @$(@$(greet("Hi", _, _))("Bob", _))
    @test @$(hi_bob("!")) == "Hi, Bob!"
    @test hi_bob isa PartialFunctions.GeneralizedPartialFunction
    @test sayhello <| ("Jimmy", "?")... == "Hello, Jimmy?"

    @test hi_bob <| "!" == "Hi, Bob!"

    @testset "Keyword Arguments" begin
        a = [[1,2,3], [1,2]]
        sort_by_length = @$(sort(_; by = length))
        @test sort(a, by = length) == sort_by_length(a)

        sorted_a_by_length = @$(sort(a; by = length))
        @test sort(a, by = length) == sorted_a_by_length

        @test repr(sort_by_length) == "sort(_; by = length)"
    end    
end
