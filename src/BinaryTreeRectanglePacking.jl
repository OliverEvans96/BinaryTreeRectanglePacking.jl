module BinaryTreeRectanglePacking

using AbstractTrees
using Plots

include("Structs.jl")
include("Packing.jl")
include("Plotting.jl")

using .Structs, .Packing, .Plotting

export pack

end # module
