module BinaryTreeRectanglePacking

using AbstractTrees
using Plots

include("Structs.jl")
include("Packing.jl")
include("Plotting.jl")

using .Structs, .Packing, .Plotting

function run(
    W::Real,
    H::Real,
    num_shapes::Integer,
    num_rectangles::Integer;
    plotting = true,
    logging = true,
)
    # Generate some random shapes
    shapes = [rand(2) for i = 1:num_shapes]
    # Make many copies of them
    rect_sizes = rand(shapes, num_rectangles)
    # Sort them first
    sorted_rect_sizes = sort(rect_sizes; by = maximum, rev = true)

    # Do the packing
    positions = pack((W, H), sorted_rect_sizes)

    # Extract the data
    packed_indices = findall(pos -> !isnothing(pos), positions)
    packed_positions = convert(Vector{NTuple{2,Float64}}, positions[packed_indices])
    packed_sizes = sorted_rect_sizes[packed_indices]
    num_packed = length(packed_indices)
    packed_areas = map(prod, packed_sizes)
    efficiency = sum(packed_areas) / (W * H)

    if logging
        println("Successfully packed $(num_packed)/$num_rectangles rectangles")
        println("Percent of available space used: $(100*round(efficiency, digits=2))%")
    end

    if plotting
        p = Plotting.plot_rectangles(packed_sizes, packed_positions .|> collect)
        display(p)
    end

end

end # module
