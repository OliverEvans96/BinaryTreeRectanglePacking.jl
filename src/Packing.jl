module Packing

using ..Structs

# Packing Algorithm
# Inspired by [this blog post](https://blackpawn.com/texts/lightmaps/default.html)

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

function pack(container::Rectangle{T}, rectangles::Vector{<:RectangleSize})::BinaryNode{Rectangle{T}} where T
	@assert ismissing(container.data)
	root = BinaryNode(container)
	for rect_size in rectangles
		insert!(root, rect_size)
	end

	return root
end

end # module
