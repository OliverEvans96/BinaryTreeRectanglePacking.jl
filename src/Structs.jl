module Structs

using AbstractTrees

export Rectangle,
    RectangularSpace,
    BinaryNode,
    SpaceNode,
    leftchild!,
    rightchild!,
    max_side,
    isleaf,
    samesize,
    area,
    fits

# Binary Tree Struct
# From [AbstractTrees.jl examples](https://github.com/JuliaCollections/AbstractTrees.jl/tree/master/examples)

struct Rectangle{N}
    dims::NTuple{N,Float64}
    pos::Union{NTuple{N,Float64},Missing}

    Rectangle(dims::NTuple{N,<:Real}) where {N} = new{N}(dims, missing)
    Rectangle(dims::NTuple{N,<:Real}, pos::NTuple{N,<:Real}) where {N} =
        new{N}(dims, pos)
end

mutable struct RectangularSpace{N}
    rect::Rectangle{N}
    empty::Bool

    RectangularSpace(rect::Rectangle{N}; empty = true) where {N} =
        new{N}(rect, empty)
    RectangularSpace(dims::NTuple{N,<:Real}) where {N} = RectangularSpace(Rectangle(dims))
    RectangularSpace(dims::NTuple{N,<:Real}, pos::NTuple{N,<:Real}) where {N} =
        RectangularSpace(Rectangle(dims, pos))
end

mutable struct BinaryNode{T}
    data::T
    parent::BinaryNode{T}
    left::BinaryNode{T}
    right::BinaryNode{T}

    # Root constructor
    BinaryNode{T}(data) where {T} = new{T}(data)
    # Child node constructor
    BinaryNode{T}(data, parent::BinaryNode{T}) where {T} = new{T}(data, parent)
end
BinaryNode(data) = BinaryNode{typeof(data)}(data)

function leftchild!(parent::BinaryNode, data)
    !isdefined(parent, :left) || error("left child is already assigned")
    node = typeof(parent)(data, parent)
    parent.left = node
end

function rightchild!(parent::BinaryNode, data)
    !isdefined(parent, :right) || error("right child is already assigned")
    node = typeof(parent)(data, parent)
    parent.right = node
end

# Implement iteration over the immediate children of a node
function Base.iterate(node::BinaryNode)
    isdefined(node, :left) && return (node.left, false)
    isdefined(node, :right) && return (node.right, true)
    return nothing
end
function Base.iterate(node::BinaryNode, state::Bool)
    state && return nothing
    isdefined(node, :right) && return (node.right, true)
    return nothing
end
Base.IteratorSize(::Type{BinaryNode{T}}) where {T} = Base.SizeUnknown()
Base.eltype(::Type{BinaryNode{T}}) where {T} = BinaryNode{T}

## Things we need to define to leverage the native iterator over children
## for the purposes of AbstractTrees.
# Set the traits of this kind of tree
Base.eltype(::Type{<:TreeIterator{BinaryNode{T}}}) where {T} = BinaryNode{T}
Base.IteratorEltype(::Type{<:TreeIterator{BinaryNode{T}}}) where {T} =
    Base.HasEltype()
AbstractTrees.parentlinks(::Type{BinaryNode{T}}) where {T} =
    AbstractTrees.StoredParents()
AbstractTrees.siblinglinks(::Type{BinaryNode{T}}) where {T} =
    AbstractTrees.StoredSiblings()
# Use the native iteration for the children
AbstractTrees.children(node::BinaryNode) = node

Base.parent(root::BinaryNode, node::BinaryNode) =
    isdefined(node, :parent) ? node.parent : nothing

function AbstractTrees.nextsibling(tree::BinaryNode, child::BinaryNode)
    isdefined(child, :parent) || return nothing
    p = child.parent
    if isdefined(p, :right)
        child === p.right && return nothing
        return p.right
    end
    return nothing
end

# We also need `pairs` to return something sensible.
# If you don't like integer keys, you could do, e.g.,
#   Base.pairs(node::BinaryNode) = BinaryNodePairs(node)
# and have its iteration return, e.g., `:left=>node.left` and `:right=>node.right` when defined.
# But the following is easy:
Base.pairs(node::BinaryNode) = enumerate(node)

AbstractTrees.printnode(io::IO, node::BinaryNode) = print(io, node.data)

fits(small::Rectangle, big::Rectangle) = all(small.dims .<= big.dims)
isleaf(node::BinaryNode) = !(isdefined(node, :left) || isdefined(node, :right))
samesize(r1::Rectangle, r2::Rectangle) = all(r1.dims .== r2.dims)
area(r::Rectangle) = prod(r.dims)

Base.isempty(space::RectangularSpace) = space.empty
fits(rect::Rectangle, space::RectangularSpace) = fits(rect, space.rect)
samesize(rect::Rectangle, space::RectangularSpace) = samesize(rect, space.rect)
samesize(space::RectangularSpace, rect::Rectangle) = samesize(rect, space)

SpaceNode = BinaryNode{RectangularSpace{N}} where {N}

end # module
