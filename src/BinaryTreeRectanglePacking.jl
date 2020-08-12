module BinaryTreeRectanglePacking

using AbstractTrees

export Structs, Packing, Plotting

include("Structs.jl")
include("Packing.jl")
include("Plotting.jl")

function run()
	W = 5
	H = 4
	N = 200

	container = Structs.Rectangle{Int}(missing, 0, 0, W, H)

	# Generate some random shapes
	shapes = [rand(2) for i=1:10]
	# Make many copies of them
	wh = rand(shapes, N)
	# Create rectangle sizes
	rect_sizes = [Structs.RectangleSize(i, wh[i]...) for i=1:N]
	# Sort them first
	sorted_rect_sizes = sort(rect_sizes; by=Structs.max_side, rev=true)

	# Do the packing
	root = Packing.pack(container, sorted_rect_sizes)

	# Extract the data
	packed_nodes = filter(node -> !ismissing(node.data.data), root |> Leaves |> collect)
	num_packed = packed_nodes |> length
	efficiency = sum(packed_nodes .|> Structs.area) / Structs.area(root)

	println("Successfully packed $(num_packed)/$N rectangles")
	println("Percent of available space used: $(100*round(efficiency, digits=2))%")

	Plotting.plot(root)
end

end # module
