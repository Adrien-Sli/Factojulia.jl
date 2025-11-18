"""
    pre_data(df::DataFrame; scale::Bool=true, dropmissing_flag::Bool=true)

Prepare the data for a Principal Component Analysis (scaling, center, missing values handling).
All numerical columns are automatically selected (if no numerical columns are in the dataset, return an error).

# Returns
- `X::Matrix`: prepared data matrix
- `numcols::Vector{Symbol}`: names of numeric columns
"""
function pre_data(df::DataFrame; scale::Bool=true, dropmissing_flag::Bool=true)
    # Select numeric columns
    numcols = [c for c in names(df) if eltype(skipmissing(df[!, c])) <: Number]
    @assert !isempty(numcols) "No numeric columns found in DataFrame."

    # Drop missing values if requested
    num_df = dropmissing_flag ? dropmissing(df[:, numcols]) : df[:, numcols]

    # Convert to matrix
    X = Matrix(num_df)

    return X, numcols
end

"""
    run_pca(X::Matrix; scale::Bool=true)

Perform a Principal Component Analysis using MultivariateStats on the prepared numeric matrix.

# Returns
Named tuple with:
- `model`: fitted PCA model
- `scores`: PCA-transformed data
- `loadings`: PCA loadings (projection matrix)
- `eigvals`: eigenvalues (principal variances)
- `var_exp`: explained variance ratio
"""
function run_pca(X::Matrix; scale::Bool=true)
    model = fit(PCA, X; maxoutdim=size(X,2), mean=true, std=scale)
    scores = transform(model, X)
    eigvals = principalvars(model)
    loadings = projection(model)
    var_exp = eigvals ./ sum(eigvals)

    return (model=model, scores=scores, loadings=loadings,
            eigvals=eigvals, var_exp=var_exp)
end

"""
    plot_pca(pca_results)

Display PCA plots (scree plot, biplot, etc.) and handle interactivity.

This function should:
- Create a scree plot (variance explained)
- Add optional hover labels or tooltips
- Possibly render a biplot (scores vs. loadings)
- Display figures interactively
"""

function plot_pca(pca_results)
    var_exp = eigvals / sum(eigvals)
    cum_var = cumsum(var_exp)
    PCs = 1:length(eigvals)

    fig = Figure()
    ax = Axis(fig[1,1], title="Scree Plot", xlabel="PC", ylabel="Variance (%)")
    barplot!(ax, PCs, var_exp .* 100, color=:dodgerblue)
    lines!(ax, PCs, cum_var .* 100, color=:red)

    # Generic nearest bar function
    function nearest_bar(pos; bar_positions=1:5, bar_width=1.0)
        mouse_x = pos[1]
        for (i, bar_x) in enumerate(bar_positions)
            half_width = bar_width / 2
            if abs(mouse_x - bar_x) <= half_width
                return i
            end
        end
        return nothing
    end

    # Floating label (add to figure, not directly to scene)
    hover_label = Label(fig[1,1], "")  # attach to axis cell

    display(fig)  # display figure before using events

    # Mouse hover interaction
        on(events(fig).mouseposition) do screen_pos
        pos = try
            to_world(ax, screen_pos)
        catch
            nothing
        end

        # Check if pos is valid
        if pos === nothing || any(!isfinite, pos)
            hover_label.text[] = ""
            return
        end

        i = nearest_bar(pos, bar_positions=PCs)
        if i !== nothing
            # Only set position if all values are finite
            x = PCs[i]
            y = var_exp[i]*100 + 5
            if isfinite(x) && isfinite(y)
                hover_label.text[] = "PC$i: $(round(var_exp[i]*100, digits=1))% (cum $(round(cum_var[i]*100, digits=1))%)"
                hover_label.position[] = Point2f0(x, y)  # or Vec2f0(x, y)
            else
                hover_label.text[] = ""
            end
        else
            hover_label.text[] = ""
        end
    end
end

"""
    pca_analysis(df::DataFrame; scale::Bool=true, dropmissing_flag::Bool=true, showplots::Bool=true)

Full PCA workflow: prepare data, run PCA, and optionally show plots.

# Keyword Arguments
- `scale::Bool`: if true, standardize variables
- `dropmissing_flag::Bool`: if true, remove rows with missing values
- `showplots::Bool`: if true, display interactive plots (default: true)

# Returns
Named tuple of PCA results.
"""
function pca_analysis(df::DataFrame; scale::Bool=true, dropmissing_flag::Bool=true, showplots::Bool=true)
    # Step 1 — Data preparation
    X, numcols = pre_data(df; scale=scale, dropmissing_flag=dropmissing_flag)

    # Step 2 — Run PCA
    pca_res = run_pca(X; scale=scale)

    # Step 3 — Optional plotting
    if showplots
        plot_pca(pca_res)
    end

    # Step 4 — Return computed results
    return (
        columns = numcols,
        model = pca_res.model,
        scores = pca_res.scores,
        loadings = pca_res.loadings,
        eigvals = pca_res.eigvals,
        var_exp = pca_res.var_exp
    )
end
