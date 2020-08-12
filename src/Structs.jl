module Structs

using AbstractTrees

export
	AbstractRectangle,
	Rectangle,
	RectangleSize,
	BinaryNode,
	leftchild!,
	rightchild!,
	max_side,
	isleaf,
	samesize,
	area,
	⊂

# Binary Tree Struct
# From [AbstractTrees.jl examples](https://github.com/JuliaCollections/AbstractTrees.jl/tree/master/examples)

abstract type AbstractRectangle{T} end

struct RectangleSize{T} <: AbstractRectangle{T}
	data::Union{T, Missing}
	width::Real
	height::Real
end

struct Rectangle{T} <: AbstractRectangle{T}
	data::Union{T, Missing}
	x::Real
	y::Real
	width::Real
	height::Real
end

mutable struct BinaryNode{T}
	data::T
	parent::BinaryNode{T}
	left::BinaryNode{T}
	right::BinaryNode{T}

	# Root constructor
	BinaryNode{T}(data) where T = new{T}(data)
	# Child node constructor
	BinaryNode{T}(data, parent::BinaryNode{T}) where T = new{T}(data, parent)
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

function replace!(node::BinaryNode, data)
	new_node = typeof(parent)(data, parent)
	if node.parent.right === node
		parent.right = new_node
	else
		parent.right = new_node
	end
	return new_node
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
Base.IteratorSize(::Type{BinaryNode{T}}) where T = Base.SizeUnknown()
Base.eltype(::Type{BinaryNode{T}}) where T = BinaryNode{T}

## Things we need to define to leverage the native iterator over children
## for the purposes of AbstractTrees.
# Set the traits of this kind of tree
Base.eltype(::Type{<:TreeIterator{BinaryNode{T}}}) where T = BinaryNode{T}
Base.IteratorEltype(::Type{<:TreeIterator{BinaryNode{T}}}) where T = Base.HasEltype()
AbstractTrees.parentlinks(::Type{BinaryNode{T}}) where T = AbstractTrees.StoredParents()
AbstractTrees.siblinglinks(::Type{BinaryNode{T}}) where T = AbstractTrees.StoredSiblings()
# Use the native iteration for the children
AbstractTrees.children(node::BinaryNode) = node

Base.parent(root::BinaryNode, node::BinaryNode) = isdefined(node, :parent) ? node.parent : nothing

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

max_side(r::RectangleSize) = max(r.width, r.height)
⊂(small::RectangleSize, big::Rectangle) = small.width <= big.width && small.height <= big.height
isleaf(node::BinaryNode) = !(isdefined(node, :left) || isdefined(node, :right))
samesize(r1::AbstractRectangle, r2::AbstractRectangle) = r1.width == r2.width && r1.height == r2.height
area(r::Rectangle) = r.width * r.height
area(n::BinaryNode{<:Rectangle}) = area(n.data)

end # module
