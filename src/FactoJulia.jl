module FactoJulia

using Bonito
using WGLMakie
using Makie
using CSV, DataFrames

include("pca.jl")
include("styles.jl")
# using .ACP named module of pca.jl, maybe alright

export run_app

"""
Fonction permettant de lancer l'application permettant la mise en oeuvre et l'affichage automatique des analyses factorielles

    run_app() fonctionne par défaut sur le port local 8000
"""
function run_app(; port=8000)
    # Elements
    file_input   = Bonito.FileInput()
    analysis_sel = Bonito.Dropdown(["ACP"])
    run_button   = Bonito.Button("Afficher résultats", style = button_style)
    fig_scree    = Bonito.Observable(nothing)
    fig_ind      = Bonito.Observable(nothing)
    fig_var      = Bonito.Observable(nothing)

    # evenements
    Bonito.on(run_button.value) do clicked
        if clicked
            # Placeholder figures
            fig_scree[] = Makie.Figure(resolution=(400,300))
            axis_s = Makie.Axis(fig_scree[], title="Scree plot placeholder")
            Makie.text!(axis_s, 0.5, 0.5, "Scree plot", align = (:center, :center))

            fig_ind[] = Makie.Figure(resolution=(400,300))
            axis_i = Makie.Axis(fig_ind[], title="Individus placeholder")
            Makie.text!(axis_i, 0.5, 0.5, "Individus", align = (:center, :center))

            fig_var[] = Makie.Figure(resolution=(400,300))
            axis_v = Makie.Axis(fig_var[], title="Variables placeholder")
            Makie.text!(axis_v, 0.5, 0.5, "Variables", align = (:center, :center))

            # Reset button
            run_button.value[] = false
        end
    end

    # ui
ui = Bonito.DOM.div(
    [
        Bonito.DOM.div(Bonito.HTML("<h3>Selectionnez un ficher .csv</h3>")),    
        file_input,
        Bonito.DOM.div(Bonito.HTML("<h3>2. Choisissez l'analyse à effectuer</h3>")),
        analysis_sel,
        Bonito.DOM.div(Bonito.HTML("<h3>3. Affichez les résultats</h3>")),
        run_button,
        Bonito.map(fig_scree) do f
            f isa Makie.Figure ? f : Bonito.HTML("")
        end,
        Bonito.map(fig_ind) do f
            f isa Makie.Figure ? f : Bonito.HTML("")
        end,
        Bonito.map(fig_var) do f
            f isa Makie.Figure ? f : Bonito.HTML("")
        end
    ]
)


    # APP & SERVER
    app = Bonito.App(ui)
    server = Bonito.Server(app, "127.0.0.1", port)

    println("Server running at http://127.0.0.1:$port") # port local, à voir pr mettre en auto le port ip LAN du lanceur
    return server
end

end
