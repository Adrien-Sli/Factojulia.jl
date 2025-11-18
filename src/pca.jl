using CSV, DataFrames, Statistics, LinearAlgebra, Plots



"""
    scree_plot(propvar::Vector{Float64})

Generates a scree plot showing the percentage of variance explained by each principal component.

# Arguments
- `propvar` : vector of percentage of variance explained by each component

"""


function scree_plot(propvar::Vector{Float64})

    k = length(propvar)
    pc_index = 1:k

    # Bar plot for variance %
    p = bar(pc_index, propvar;
            legend = :topright,
            xlabel = "Dimensions",
            ylabel = "Percentage of variance explained",
            title = "Scree plot with ncp = $k",
            ylim = (0, 100),
            label = "Variance explained (%)",
            framestyle = :box,
            color = :lightblue)

    # Line connecting tops of bars
    plot!(p, pc_index, propvar;
            lw = 2, marker = :circle, markersize = 4,
            label = "Variance explained (%)",
            color = :red,
            legend = :topright)

    # Annotate each point
    y_offset = maximum(propvar) * 0.06
    for (x, y) in zip(pc_index, propvar)
        lbl = string(round(y, digits=1), "%")
        annotate!(p, x, y + y_offset, text(lbl, 9, :black))
    end

    # Force y-axis
    ylims!(p, (0, 100))

    display(p)

end



"""
    plot_PCA_individuals(scores::Matrix{Float64};
                         pcs::Tuple{Int,Int} = (1,2))

Plots individuals on a PCA factor map with 4 quadrants.

# Arguments
- `scores` : matrix of PCA scores (rows = individuals, columns = components)
- `pcs` : tuple of component indices to plot, e.g., (1,2) for dim 1 vs dim 2
"""

function plot_PCA_individuals(scores::Matrix{Float64};
                              pcs::Tuple{Int,Int} = (1,2))

    # Extract components (-1 = flip to match FactoMineR orientation)
    x = scores[:, pcs[1]] .* -1
    y = scores[:, pcs[2]] .* -1

    # Labels = row indices
    labels = string.(1:size(scores,1))

    # ---- Symmetric axis limits for clear 4-quadrant view ----
    maxabs = maximum(abs.([x; y]))
    lim = maxabs * 1.15     # small margin
    xlims = (-lim, lim)
    ylims = (-lim, lim)

    # ---- Plot ----
    p = scatter(x, y;
        xlabel = "Dim $(pcs[1])",
        ylabel = "Dim $(pcs[2])",
        title = "PCA Individuals Factor Map (Dim $(pcs[1]) vs Dim $(pcs[2]))",
        legend = false,
        color = :blue,
        markersize = 2,
        framestyle = :box,
        xlim = xlims,
        ylim = ylims
    )

    # Heavy central axes (more visible)
    vline!(p, [0], lw=1.8, linestyle=:dash, color=:black)
    hline!(p, [0], lw=1.8, linestyle=:dash, color=:black)

    # Annotate above points
    y_off = (ylims[2] - ylims[1]) * 0.04  # relative offset
    for i in 1:length(x)
        annotate!(p, x[i], y[i] + y_off, text(labels[i], :black, 8))
    end

    display(p)
end



"""
    plot_PCA_variables(loadings::Matrix{Float64};
                      pcs::Tuple{Int,Int} = (1,2),
                      var_names::Vector{String} = String[])

Plots variables on a PCA factor map with arrows from origin.
# Arguments
- `loadings` : matrix of PCA loadings (rows = variables, columns = components)
- `pcs` : tuple of component indices to plot, e.g., (1,2) for PC1 vs PC2
- `var_names` : vector of variable names; if empty, uses indices as names"""


function plot_PCA_variables(loadings::Matrix{Float64};
                            pcs::Tuple{Int,Int} = (1,2),
                            var_names::Vector{String} = String[])

    # Extract loadings for specified PCs and flip signs
    x = loadings[:, pcs[1]] .* -1
    y = loadings[:, pcs[2]] .* -1

    # Variable names
    if isempty(var_names)
        var_names = string.(1:size(loadings,1))
    end

    # ---- Determine limits: ensure the circle is inside ----
    maxabs = maximum(abs.([x; y]))
    lim = max(1.0, maxabs) * 1.15
    xlims = (-lim, lim)
    ylims = (-lim, lim)

    # ---- Base plot with equal aspect ratio ----
    p = plot(
        xlabel = "Dim $(pcs[1])",
        ylabel = "Dim $(pcs[2])",
        title = "PCA Variables Factor Map (Dim $(pcs[1]) vs Dim $(pcs[2]))",
        legend = false,
        framestyle = :box,
        xlim = xlims,
        ylim = ylims,
        aspect_ratio = :equal
    )

    # ---- Draw unit correlation circle ----
    θ = range(0, 2π, length=300)
    plot!(p, cos.(θ), sin.(θ); lw=1.0, linestyle=:dash, color=:gray)

    # ---- Draw arrows for variables ----
    for i in 1:length(x)
        plot!(p, [0, x[i]], [0, y[i]];
              arrow=:arrow, lw=1.6, color=:blue)
    end

    # ---- Central axes ----
    vline!(p, [0], lw=1.6, linestyle=:dash, color=:black)
    hline!(p, [0], lw=1.6, linestyle=:dash, color=:black)

    # ---- Labels ----
    y_off = (ylims[2] - ylims[1]) * 0.04
    for i in 1:length(x)
        annotate!(p, x[i], y[i] + y_off, text(var_names[i], :black, 9))
    end

    display(p)
end


"""
    print_matrix(name::String, mat::Matrix{Float64},
                 colnames::Vector{String})

Prints a matrix with row and column names in a formatted way (like FactoMineR).
"""

import Printf

function print_matrix(name, mat, rownames)

    println("\n\$$name")

    colnames = ["Dim $(i)" for i in 1:size(mat,2)]

    # How wide should each column be?
    col_width = 12   # enough for sign + digits + decimals
    row_width = 18   # left padding for row names

    # Build header
    header = "  " ^ 12 *
             join([rpad(col, col_width) for col in colnames], "")

    println(header)

    # Print each row
    for (i, r) in enumerate(eachrow(mat))
        rowname = rpad(rownames[i], row_width)
        vals = round.(collect(r), digits=6)
        vals_str = join([lpad(string(v), col_width) for v in vals], "")
        println(rowname * vals_str)
    end

    println()
end




"""
    PCA(X::DataFrame; scale::Bool=true, ncp::Int=5,  
        dropNa::Bool=true, graph::Bool=true))

FactoMineR PCA in Julia with optional automatic plotting.

# Arguments
- `X` : DataFrame with numeric columns for PCA
- `scale` : whether to standardize variables (true = correlation matrix, false = covariance matrix)
- `ncp` : number of principal components to retain (not used in this implementation)
- `dropNa` : whether to drop rows with missing values
- `graph` : whether to generate PCA plots (individuals, variables, scree plot)


Returns a Dict containing:
- `cov_mat` : covariance or correlation matrix
- `scores` : PCA scores for individuals 
- `loadings` : PCA loadings for variables
- `eigvals` : eigenvalues
- `propvar` : percentage of variance explained by each component
- `cumvar` : cumulative variance explained
- `colnames` : names of numeric columns used in PCA
"""

function PCA(df::DataFrame; scale::Bool = true, ncp::Int = 5, dropNa::Bool = true, graph::Bool = true)
    # ---------- Select numeric columns ----------
    numcols = [name for name in names(df) if eltype(skipmissing(df[!, name])) <: Number]
    num_df = df[:, numcols]

    # Drop missing rows if requested
    if dropNa
        num_df = dropmissing(num_df)
    end

    # Convert to matrix
    X = Matrix(num_df)
    n, p = size(X)

    if p == 0
        error("No numeric columns available for PCA.")
    end
    if n < 2
        error("Too few observations (n < 2).")
    end
    if ncp < 1
        error("ncp must be >= 1")
    end

    # Covariance or correlation matrix
    cov_mat = scale ? cor(X) : cov(X)
    println("\n-------- Matrice de covariance/corrélation -------- ")
    for (i, row) in enumerate(eachrow(cov_mat))
        println(" ", round.(collect(row), digits=4))
    end
    println()

    # Center (and scale if requested)
    Xc = X .- mean(X, dims=1)
    if scale
        sds = std(X, dims=1, corrected=true)
        sds[sds .== 0.0] .= 1.0
        Xc .= Xc ./ sds
    end

    # Decide how many components we can actually keep
    max_ncp = min(n - 1, p)
    if ncp > max_ncp
        @warn "Requested ncp = $ncp greater than maximum available ($max_ncp). Using ncp = $max_ncp."
    end

    ncp = min(ncp, max_ncp)             # effective number of components to keep
    k = ncp                             # for clarity

    # ---------- PCA via eigen decomposition ----------
    E = eigen(Symmetric(cov_mat))
    # sort descending
    ord = sortperm(E.values, rev=true)
    eigvals = E.values[ord]
    total_var = sum(eigvals)            # keep track of total variance

    eigvals = eigvals[1:k]              # keep only first k eigenvalues
    loadings = E.vectors[:, ord]        # eigenvectors

    # Keep only first k components for returned loadings & scores
    loadings = loadings[:, 1:k]         # p × k

    # Compute scores on the centered (and scaled) data, then truncate to k
    scores = Xc * loadings              # n × k
    scores = scores[:, 1:k]             # n × k

    # Variance explained
    propvar = 100 .* eigvals ./ total_var
    cumvar = cumsum(propvar)

    println("\n----------------- Eigenvalues -----------------\n", round.(eigvals, digits=4))
    println("Cumulative variance explained(%): ", round(cumvar[end], digits=2))

    println("\n---------- Eigenvectors (loadings) ----------")
    for (i, col) in enumerate(eachcol(loadings))
        println(" a$(i) ", round.(col, digits=4))
    end
    println()

    println("---------- Variables coordinates ----------")
    # Coordinates (correlations between variables and components)
    coord = loadings .* - sqrt.(eigvals')    # p × k

    print_matrix("coord", coord, numcols)

    println("---------- Variables cos2 (squared cosines) ----------")
    # cos2 = squared coordinates
    cos2 = coord .^ 2
    print_matrix("cos2", cos2, numcols)

    println("---------- Variables contributions ----------")
    # Contribution of variables to components
    contrib = (cos2 ./ eigvals') .* 100
    print_matrix("contrib", contrib, numcols)


    # ---------- Scree plot ----------
    if graph

        # scree plot uses propvar
        try
            scree_plot(propvar)
        catch err
            @warn "scree_plot not available or errored: $err"   
        end

        # plot individuals and variables using functions you already defined
        # we pass the truncated scores & full loadings (or truncated loadings) depending on your plotting functions
        # plot individuals (uses scores matrix)
        try
            plot_PCA_individuals(scores)  # if this function is defined earlier
        catch err
            @warn "plot_PCA_individuals not available or errored: $err"
        end

        # plot variables (we pass loadings; variable plot will usually show first 2 components)
        try
            plot_PCA_variables(loadings; pcs=(1,2), var_names=numcols)
        catch err
            @warn "plot_PCA_variables not available or errored: $err"
        end
    end

    return (cov_mat = cov_mat,
            scores = scores,                        # n × k
            loadings = loadings,                    # p × k
            eigvals = eigvals,                      # eigenvalues
            propvar = propvar,
            cumvar = cumvar,
            var = (coord=coord, cos2=cos2, contrib=contrib),
            ncp_requested = ncp,
            ncp_used = k,
            colnames = numcols)
end