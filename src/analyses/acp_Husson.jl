module PCAAnalysis

using DataFrames, Statistics, LinearAlgebra

export compute_PCA

"""
compute_PCA(df::DataFrame; scale=true, ncp=5, dropNa=true)

Calcule une analyse en composantes principales (PCA) sur les colonnes numériques.
Retourne un NamedTuple avec : scores, loadings, eigvals, propvar, colnames.
"""
function compute_PCA(df::DataFrame; scale::Bool=true, ncp::Int=5, dropNa::Bool=true)

    # Sélection colonnes numériques
    numcols = [name for name in names(df) if eltype(skipmissing(df[!, name])) <: Number]
    num_df = dropNa ? dropmissing(df[:, numcols]) : df[:, numcols]
    X = Matrix(num_df)
    n, p = size(X)

    if p == 0
        error("Aucune colonne numérique disponible pour la PCA.")
    elseif n < 2
        error("Trop peu d'observations (n < 2).")
    end

    # Covariance ou corrélation
    cov_mat = scale ? cor(X) : cov(X)

    # Centrage et échelle
    Xc = X .- mean(X, dims=1)
    if scale
        sds = std(Xc, dims=1, corrected=true)
        sds[sds .== 0] .= 1.0
        Xc ./= sds
    end

    # Eigen décomposition
    E = eigen(Symmetric(cov_mat))
    ord = sortperm(E.values, rev=true)
    eigvals = E.values[ord]
    k = min(ncp, min(n-1, p))
    eigvals = eigvals[1:k]
    loadings = E.vectors[:, ord][:, 1:k]
    scores = Xc * loadings
    propvar = 100 .* eigvals ./ sum(E.values)

    return (scores=scores, loadings=loadings, eigvals=eigvals, propvar=propvar, colnames=numcols)
end

end
