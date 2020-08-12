module BinaryTreeRectanglePacking

using AbstractTrees
using GeometryBasics
using Plots

# Binary Tree Struct
# From [AbstractTrees.jl examples](https://github.com/JuliaCollections/AbstractTrees.jl/tree/master/examples)

# Packing Algorithm
# Inspired by [this blog post](https://blackpawn.com/texts/lightmaps/default.html)

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

function plot!(p::Plots.Plot, node::BinaryNode{<:Rectangle})
	rect = node.data
	if ismissing(rect.data)
		Plots.plot!(
			p,
			rectangle(rect.x, rect.y, rect.width, rect.height),
			fillcolor=nothing,
			#fillalpha=0.05,
			linewidth=1
		)
	else
		Plots.plot!(
			p,
			rectangle(rect.x, rect.y, rect.width, rect.height),
			#fillcolor=nothing,
			linewidth=0
		)
	end

	xc = rect.x + rect.width / 2
	yc = rect.y + rect.height / 2

	if isdefined(node, :left)
		plot!(p, node.left)
	end
	if isdefined(node, :right)
		plot!(p, node.right)
	end

	return p
end

function plot(node::BinaryNode{<:Rectangle})
	p = Plots.plot(legend=false)
	plot!(p, node)
end

max_side(r::RectangleSize) = max(r.width, r.height)
⊂(small::RectangleSize, big::Rectangle) = small.width <= big.width && small.height <= big.height
isleaf(node::BinaryNode) = !(isdefined(node, :left) || isdefined(node, :right))
samesize(r1::AbstractRectangle, r2::AbstractRectangle) = r1.width == r2.width && r1.height == r2.height
area(r::Rectangle) = r.width * r.height
area(n::BinaryNode{<:Rectangle}) = area(n.data)
rectangle(x, y, w, h) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

function insert!(node::BinaryNode{<:AbstractRectangle{T}}, rect::RectangleSize) where T
	if !isleaf(node)
		new_node = insert!(node.left, rect)
		if new_node != nothing
			return new_node
		else
			return insert!(node.right, rect)
		end
	else
		space = node.data
		if ismissing(space.data)
			if samesize(rect, space)
				return replace!(node, rect)
			elseif rect ⊂ space
				new_rect = Rectangle(
					rect.data,
					space.x,
					space.y,
					rect.width,
					rect.height
				)

				# Decide which way to split
				# We want to split the larger dimension first
				# to leave as much space as possible
				dw = space.width - rect.width
				dh = space.height - rect.height

				if dw > dh
					# Split width
					new_space_1 = Rectangle{Int}(
						missing,
						space.x,
						space.y,
						rect.width,
						space.height,
					)
					new_space_2 = Rectangle{Int}(
						missing,
						space.x + rect.width,
						space.y,
						space.width - rect.width,
						space.height,
					)
					new_space_3 = Rectangle{Int}(
						missing,
						space.x,
						space.y + rect.height,
						rect.width,
						space.height - rect.height,
					)

					new_space_node_1 = leftchild!(node, new_space_1)
					new_space_node_2 = rightchild!(node, new_space_2)
					new_rect_node = leftchild!(new_space_node_1, new_rect)
					new_space_node_3 = rightchild!(new_space_node_1, new_space_3)
					return new_rect_node
				else
					# Split height
					new_space_1 = Rectangle{T}(
						missing,
						space.x,
						space.y,
						space.width,
						rect.height,
					)
					new_space_2 = Rectangle{T}(
						missing,
						space.x,
						space.y + rect.height,
						space.width,
						space.height - rect.height,
					)
					new_space_3 = Rectangle{T}(
						missing,
						space.x + rect.width,
						space.y,
						space.width - rect.width,
						rect.height,
					)

					new_space_node_1 = leftchild!(node, new_space_1)
					new_space_node_2 = rightchild!(node, new_space_2)
					new_rect_node = leftchild!(new_space_node_1, new_rect)
					new_space_node_3 = rightchild!(new_space_node_1, new_space_3)
					return new_rect_node
				end
			end
		end
	end
	return nothing
end

function run()
	W = 5
	H = 4
	N = 200

	shapes = [rand(2) for i=1:10]
	wh = zip(rand(shapes, N)...) |> collect;
	w = wh[1];
	h = wh[2];
	rect_sizes = [RectangleSize(i, w[i], h[i]) for i=1:N]
	sorted_rect_sizes = sort(rect_sizes; by=max_side, rev=true)

		errors = []
		nodes = []
		root = BinaryNode{Rectangle{Int}}(Rectangle{Int}(missing, 0, 0, W, H))
		push!(nodes, root)
		for (i, rect_size) in enumerate(sorted_rect_sizes)
			node = insert!(root, rect_size)
			push!(nodes, node)
		end

	packed_nodes = filter(node -> !ismissing(node.data.data), root |> Leaves |> collect)
	num_packed = packed_nodes |> length
	efficiency = sum(packed_nodes .|> area) / area(root)

	plot(root)
end

end # module
