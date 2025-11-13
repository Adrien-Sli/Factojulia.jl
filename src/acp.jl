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
function pca()
    ## compute pca


    # Plots (render in browser)
    ## Scree Plot
    var_exp = [0.45, 0.25, 0.15, 0.10, 0.05]
    cum_var = cumsum(var_exp)
    PCs = 1:length(var_exp)

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