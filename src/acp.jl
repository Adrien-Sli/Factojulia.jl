say_hello() = print("hello") # test fonctionnement package

"""
Function that compute a standart pca

Inputs : X should be either a 


Outputs : results of the pca analysis
- 
- 
-
-
-
-
-
-
-
-
-
-
"""
function pca(df::DataFrame; scale::Bool = true, dropmissing_flag::Bool = true)

    numcols = [name for name in names(df) if eltype(skipmissing(df[!, name])) <: Number] # select num columns
    num_df = df[:, numcols]

    if dropmissing_flag
        ### Drop missing lines if true
        num_df = dropmissing(num_df)
    end

    X = Matrix(num_df) # convert for matrix operations

    # Compute cov / corr matrix
    cov_mat = scale ? cor(X) : cov(X)
    println("Matrice de cov / corr :")
    println(round.(cov_mat, digits = 3))

    Xc = X .-mean(X, dims = 1)
    if scale
        #### Compute scaling if true
        sds = std(X, dims=1, corrected = true)
        sds[sds .==0.0] .= 1.0
        Xc .= Xc ./ sds
    end

    ### Compute pca
    pca = fit(PCA, Xc; maxoutdim = size(Xc, 2))
    ## Compute needed values
    ### Scores
    scores = MultivariateStats.transform(pca, Xc)
    ### eigen values
    eigvals = principalvars(pca)
    ### loadings
    loadings = pca.proj

    # Plots (render in browser)
    ## Scree Plot
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

    return(cov_mat = cov_mat, model = pca, scores = scores, loadings = loadings)

end