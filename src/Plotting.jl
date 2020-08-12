module Plotting

using Plots

using ..Structs

rectangle(x, y, w, h) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

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

using Plots

end # module
