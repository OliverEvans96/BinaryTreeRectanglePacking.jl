# BinaryTreeRectanglePacking.jl

Fit as many rectangles as possible into a container using binary trees in Julia.

Works in N dimensions.

Packing algorithm inspired by [this blog post](https://blackpawn.com/texts/lightmaps/default.html), binary tree struct implementation inspired by [AbstractTrees.jl examples](https://github.com/JuliaCollections/AbstractTrees.jl/tree/master/examples)

PRs/suggestions welcome!

## Instructions

The main packing function has the signature:

```julia

function pack(
    container_dims::NTuple{N,<:Real},
    rect_dims::Vector{NTuple{N,T}},
)::Vector{Union{NTuple{N,Float64},Nothing}} where {T<:Real} where {N}
```

Give it the dimensions of your container and (pre-sorted) rectangles. It will return a vector with an entry for each rectangle, either `NTuple{N, Float64}` if it was packed successfully, or `nothing` if it couldn't fit.

## Examples

![fig1](https://imgur.com/4ayWLDO)

![fig2](https://imgur.com/YBWrKmh)

![fig3](https://imgur.com/QVFw2jA)
