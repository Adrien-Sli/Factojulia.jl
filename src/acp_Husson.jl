# Fichier visant à reproduire les méthodes d'ACP de factomineR de François Husson

# Fonctions intermediaires
mutable struct ptab{T<Real}
    V::Matrix{T}
    Poids::Vector{T}
end

function moy_ptab(ptab)
    w = ptab.Poids ./ sum(ptab.Poids)
    return vec(w' * ptab.V)
end

function ec_tab(ptab)
    w = ptab.Poids ./ sum(ptab.Poids)
    ecart_type = sqrt.(vec(w' * (ptab.V .^ 2)))
    replace!(ecart_type, x -> x ≤ 1e-16 ? 1.0 : x) # Seuil
    return ecart_type
end

mutable struct etz2_input{T<Real}
    tt::Matrix{T}
    x::Matrix{T}
    weights::Vector{T}
    ni::Vector{T}

    # Constructeur interne
    function pre_trait(vec, x::Matrix{T}, weights::Vector{T}) where {T<:Real}
        #
        tt = zeros(T, length(vec), length(unique(vec)))
        for (i,v) in enumerate(vec)
            tt[i, findfirst(==(v), unique(vec))] = 1
        end

        ni = vec(sum(tt .* weights, Dims= 1))

        return new(tt, x, weights, ni)
    end
end

function VB(input::etz2_input, xx::Vector)
    col = sum((input.tt .* xx) .* input.weights, Dims = 1)
    return sum((col .^ 2) ./ input.ni)    
end

function eta2(input::etz2_input)
    numerateur = [VB(input, input.x[:,j]) for j in 1:size(input.x, 2)]
    denominateur = vec(sum((input.x .* input.x) .* input.weights, Dims=1))
    return numerateur ./ denominateur
end


# PCA
struct PCA{T<Real} 
    #

end

"""
    PCA(X::Matrix{T}, scale.unit = TRUE, ncp = 5, ind.sup = NULL, quanti.sup = NULL, 
    quali.sup = NULL, row.w = NULL, col.w = NULL, graph = TRUE, 
    axes = c(1, 2)) # TODO



"""
function PCA()
    
end