function _append(t::Tuple, el)
    i = findlast(x -> applicable(combine, x, el), t)
    i === nothing ? (t..., el) : setindex(t, combine(t[i], el), i)
end

struct Product{T<:Tuple}
    elements::T
    Product(args...) = new{typeof(args)}(args)
end
Product(l::Product) = l

append(l::Product, x) = Product(_append(l.elements, x)...)
append(l::Product, m::Product) = foldl(append, m.elements, init=l)

⊗(a, b) = applicable(combine, a, b) ? combine(a, b) : Product(a) ⊗ Product(b)
⊗(a::Product, b::Product) = append(a, b)

function get_type(p::Product, ::Type{T}) where T
    vals = p.elements
    i = findfirst(x -> isa(x, T), vals)
    i === nothing ? T() : vals[i]
end

struct Sum{T<:Tuple}
    elements::T
    Sum(args...) = new{typeof(args)}(args)
end
Sum(l::Sum) = l

⊗(t::Sum, b) = Sum(map(el -> el ⊗ b, t.elements)...)
⊗(a, t::Sum) = Sum(map(el -> a ⊗ el, t.elements)...)
function ⊗(s::Sum, t::Sum)
    f = (s ⊗ first(t.elements))
    ls = (s ⊗ Sum(tail(t.elements)...))
    return f ⊕ ls
end
⊗(s::Sum, ::Sum{Tuple{}}) = Sum()

⊕(a, b) = Sum(a) ⊕ Sum(b)
⊕(a::Sum, b::Sum) = Sum(a.elements..., b.elements...)
