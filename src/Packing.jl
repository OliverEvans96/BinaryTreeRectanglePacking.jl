module Packing

using ..Structs

export max_side, PackResult, pack

# Packing Algorithm
# Inspired by [this blog post](https://blackpawn.com/texts/lightmaps/default.html)


PackResult = Vector{Union{NTuple{N,Float64},Nothing}} where {N}

function partition!(
    node::SpaceNode{N},
    dim::Integer,
    pos::Real,
)::NTuple{2,SpaceNode{N}} where {N}
    space = node.data

    left_dims = Tuple(
        i == dim ? pos : space.rect.dims[i]
        for i=1:N
    )
    left_pos = space.rect.pos

    right_dims = Tuple(
        i == dim ? space.rect.dims[i] - pos : space.rect.dims[i]
        for i=1:N
    )
    right_pos = Tuple(
        i == dim ? space.rect.pos[i] + pos : space.rect.pos[i]
        for i=1:N
    )

    left_space = RectangularSpace(left_dims, left_pos)
    left_node = leftchild!(node, left_space)
    right_space = RectangularSpace(right_dims, right_pos)
    right_node = rightchild!(node, right_space)

    return left_node, right_node
end

function partition!(
    node::SpaceNode{N},
    rect::Rectangle{N},
)::NTuple{N,Float64} where {N}
    # We want to split the dimensions in descending order
    # to leave as much contiguous space as possible
    space = node.data
    dim_diff = space.rect.dims .- rect.dims |> collect
    dim_order = sortperm(dim_diff, rev = true)

    target = node
    for dim in dim_order
        # Always split the left child
        target, _ = partition!(target, dim, rect.dims[dim])
    end

    # The leftmost space is now occupied
    target.data.empty = false
    # Return the newly occupied position
    return target.data.rect.pos
end

function insert!(
    node::SpaceNode{N},
    rect::Rectangle{N},
)::Union{NTuple{N,Float64},Nothing} where {N}
    # TODO: Use BFS? Or iterate over leaves, sorted by size?
    if !isleaf(node)
        new_pos = insert!(node.left, rect)
        if new_pos != nothing
            return new_pos
        else
            return insert!(node.right, rect)
        end
    else
        space = node.data
        if isempty(space)
            if samesize(rect, space)
                space.empty = false
                return space.rect.pos
            elseif fits(rect, space)
                return partition!(node, rect)
            end
        end
    end
    return nothing
end

function pack(
    container_dims::NTuple{N,<:Real},
    rect_dims::Vector{NTuple{N,T}},
)::PackResult{N} where {T<:Real} where {N}
    root = BinaryNode(RectangularSpace(container_dims, (0, 0)))
    rectangles = Rectangle.(rect_dims)
    positions = PackResult{N}([])
    for rect in rectangles
        pos = insert!(root, rect)
        push!(positions, pos)
    end

    return positions
end

function pack(
    container_dims::NTuple{N,<:Real},
    rect_dims::Vector{Vector{T}},
)::PackResult{N} where {T<:Real} where {N}
    return pack(container_dims, rect_dims .|> Tuple)
end

end # module
