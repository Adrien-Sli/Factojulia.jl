###############################################################
# visualisation_interactive.jl
#
# Démonstration des principaux packages Julia permettant
# de produire des graphiques INTERACTIFS :
# - Makie.jl (WGLMakie)
# - PlotlyJS.jl
# - VegaLite.jl
#
# Auteur : Hanaa Hajmi
# Date : 2025
###############################################################

###############################################################
# 1. Makie.jl - WGLMakie (graphique interactif dans le navigateur)
###############################################################

using WGLMakie

# Données
x = 1:100
y = rand(100)

# Graphique interactif
fig = scatter(x, y,
    markersize = 10,
    color = :blue,
    figure = (; resolution = (600, 400)),
)

# Sauvegarde en HTML interactif (optionnel)
save("makie_interactif.html", fig)

println("Graphique Makie interactif généré : makie_interactif.html")


###############################################################
# 2. PlotlyJS.jl - graphique interactif moderne
###############################################################

using PlotlyJS

plt = plot(
    scatter(
        x = 1:50,
        y = rand(50),
        mode = "markers",
        marker = attr(size=10, color="red")
    ),
    Layout(title="Graphique interactif avec PlotlyJS")
)

savefig(plt, "plotly_interactif.html")

println("Graphique PlotlyJS généré : plotly_interactif.html")


###############################################################
# 3. VegaLite.jl - graphique interactif style Altair/Vega
###############################################################

using VegaLite, DataFrames

df = DataFrame(x = 1:20, y = rand(20))

vl_plot = df |> @vlplot(
    :point,
    x = :x,
    y = :y,
    width = 400,
    height = 300,
    title = "Graphique interactif VegaLite"
)

# Export (HTML interactif)
save("vegalite_interactif.html", vl_plot)

println("Graphique VegaLite généré : vegalite_interactif.html")

###############################################################
# Fin du fichier
###############################################################

println("Tous les graphiques interactifs ont été créés avec succès.")


