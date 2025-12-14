module PCAPlots

using CairoMakie, Makie
using Bonito

export scree_plot, plot_PCA_individuals, plot_PCA_variables

"""
scree_plot(propvar::Vector{Float64})

Renvoie un MakieDisplay avec le scree plot (variance expliquée par composante).
"""
function scree_plot(propvar::Vector{Float64})
    fig = Figure(resolution=(400,300))
    ax = Axis(fig[1,1])
    scatter!(ax, 1:length(propvar), propvar, color=:blue)
    lines!(ax, 1:length(propvar), propvar, color=:red)
    ax.xlabel = "Dimensions"
    ax.ylabel = "Variance (%)"
    ax.title = "Scree plot"
    return Makie.MakieDisplay(fig)
end

"""
plot_PCA_individuals(scores::Matrix{Float64})

Renvoie un MakieDisplay avec le nuage de points des individus.
"""
function plot_PCA_individuals(scores::Matrix{Float64})
    fig = Figure(resolution=(400,300))
    ax = Axis(fig[1,1])
    x = scores[:,1] .* -1
    y = scores[:,2] .* -1
    scatter!(ax, x, y, color=:green)
    hlines!(ax, [0], color=:black, linestyle=:dash)
    vlines!(ax, [0], color=:black, linestyle=:dash)
    ax.xlabel = "Dim 1"
    ax.ylabel = "Dim 2"
    ax.title = "PCA Individuals"
    return Makie.MakieDisplay(fig)
end

"""
plot_PCA_variables(loadings::Matrix{Float64}, colnames::Vector{String})

Renvoie un MakieDisplay avec le nuage de points des variables et cercle de corrélation.
"""
function plot_PCA_variables(loadings::Matrix{Float64}, colnames::Vector{String})
    fig = Figure(resolution=(400,300))
    ax = Axis(fig[1,1], aspect=DataAspect())
    x = loadings[:,1] .* -1
    y = loadings[:,2] .* -1
    scatter!(ax, x, y, color=:orange)
    for i in 1:length(x)
        text!(ax, colnames[i], position=(x[i], y[i]), align=(:center, :bottom))
    end
    θ = range(0, 2π, length=300)
    lines!(ax, cos.(θ), sin.(θ), color=:gray, linestyle=:dash)
    hlines!(ax, [0], color=:black, linestyle=:dash)
    vlines!(ax, [0], color=:black, linestyle=:dash)
    ax.xlabel = "Dim 1"
    ax.ylabel = "Dim 2"
    ax.title = "PCA Variables"
    return Makie.MakieDisplay(fig)
end

end
