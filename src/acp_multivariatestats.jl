module PCAApp

using CSV
using DataFrames
using Statistics
using LinearAlgebra
using MultivariateStats: PCA, fit, principalvars, projection, loadings
using PyPlot

export PCAResult, run_pca, screeplot, plot_individuals, plot_variables
mutable struct PCAResult
    pca::PCA
    eigenvalues::Vector{Float64}
    explained::Vector{Float64}
    loadings::Matrix{Float64}
    scores::Matrix{Float64}
    columns::Vector{String}
end
#Load data + PCA (standardized like FactoMineR)
function run_pca(path::String)
    isempty(path) && error("Chemin de fichier vide")
    isfile(path) || error("Fichier introuvable : $path")

    df = CSV.read(path, DataFrame)

    # Colonnes numériques
    numcols = [name for name in names(df) if eltype(skipmissing(df[!, name])) <: Number]
    isempty(numcols) && error("Aucune colonne numérique détectée")

    X = Matrix(df[:, numcols])

    # Standardisation
    μ = mean(X, dims=1)
    σ = std(X, dims=1)
    σ[σ .== 0] .= 1.0
    Xs = (X .- μ) ./ σ

    # PCA
    pca_model = fit(PCA, Xs; maxoutdim=min(size(Xs)...))
    eigenvalues = principalvars(pca_model)
    explained = eigenvalues ./ sum(eigenvalues) .* 100
    load_mat = loadings(pca_model)
    scores = projection(pca_model)
    return PCAResult(pca_model, eigenvalues, explained, load_mat, scores, numcols)
end 



#   1) Scree Plot
function screeplot(pca)

    λ = pca.prinvars
    prop = 100 .* λ ./ sum(λ)
    n = length(prop)

    figure(figsize=(6,4))
    bar(1:n, prop, color="lightblue")
    plot(1:n, prop, marker="o", linestyle="-", color="red")

    for i in 1:n
        text(i, prop[i] + 1, string(round(prop[i], digits=1), "%"),
                ha="center", fontsize=9)
    end

    xlabel("Composantes principales")
    ylabel("% Variance expliquée")
    title("Scree Plot")
    ylim(0, maximum(prop)*1.25)
    grid(true, linestyle="--", alpha=0.5)
    gcf()
end


#   2) Individuals Factor Map
function plot_individuals(scores)

    x = scores[:,1]
    y = scores[:,2]

    maxabs = maximum(abs.([x; y])) * 1.2

    figure(figsize=(6,6))
    scatter(x, y, s=35, color="dodgerblue", alpha=0.8)

    for i in 1:length(x)
        text(x[i], y[i], string(i), fontsize=8)
    end

    axvline(0, color="black", linestyle="--")
    axhline(0, color="black", linestyle="--")

    axis([-maxabs, maxabs, -maxabs, maxabs])
    xlabel("PC1")
    ylabel("PC2")
    title("Individuals Factor Map")
    grid(true, linestyle="--", alpha=0.4)
    gcf()
end



#  3) Variables Correlation Map

function plot_variables(loadings, columns)

    x = loadings[:,1]
    y = loadings[:,2]

    figure(figsize=(6,6))

    # cercle de corrélation
    θ = range(0, 2π, length=300)
    plot(cos.(θ), sin.(θ), linestyle="--", color="gray")

    # flèches
    for i in 1:length(columns)
        arrow(0, 0, x[i], y[i], head_width=0.03, color="red")
        text(x[i]*1.1, y[i]*1.1, string(columns[i]), fontsize=9, color="red")
    end

    axvline(0, color="black", linestyle="--")
    axhline(0, color="black", linestyle="--")

    axis("equal")
    xlabel("PC1")
    ylabel("PC2")
    title("Variables Correlation Map")
    grid(true, linestyle="--", alpha=0.4)
    gcf()
end

end # module


