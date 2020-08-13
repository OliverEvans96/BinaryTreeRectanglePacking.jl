module Plotting

using Plots

using ..Structs

export plot_rectangles

rectangle(x, y, w, h) = Shape(x .+ [0, w, w, 0], y .+ [0, 0, h, h])

function plot_rectangles(rect_sizes, positions)
    p = Plots.plot(legend = false)

    for (dims, pos) in zip(rect_sizes, positions)
        Plots.plot!(
            p,
            rectangle(pos..., dims...),
            #fillcolor=nothing,
            # linewidth=0
        )
    end

    return p
end

end # module
