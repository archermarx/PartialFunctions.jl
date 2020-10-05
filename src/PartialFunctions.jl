module PartialFunctions

export $

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

($)(f::Function, args...) = PartialFunction(f, args)
($)(f::Function, arg) = PartialFunction(f, (arg,))

function Base.Symbol(pf::PartialFunction)
    func_name = name(pf.func)
    argstring = "(" * join(repr.(pf.args), ", ") *", ...)"
    Base.Symbol("$(func_name)$(argstring)")
end

Base.show(io::IO, pf::PartialFunction) = print(io, name(pf))
Base.show(io::IO, ::MIME"text/plain", pf::PartialFunction) = show(io, pf)

end
