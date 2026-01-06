module UI

using Bonito
using ..PCAAnalysis: compute_PCA
using CSV, DataFrames

bouton_input_file = Bonito.FileInput()
on(bouton_input_file.value) do file
    @show file
end
bouton_lancement = Bonito.Button("Lancer l'analyse")
on(bouton_lancement.value) do click::Bool
    println("Click")
    df = CSV.read(bouton_input_file[][1], DataFrame)
    println("en memoire")
    resultat_acp = compute_PCA(df)
    println("acp prête")
    #TODO graphiques à afficher 
end

function main_ui()
    Col(
        DOM.h1("FactoJulia", style = Styles(
            CSS("text-align" => "center")
        )),

        Row(
            Col(
                DOM.h3("Contrôles", style = Styles(
                    CSS("text-align" => "center")
                )),
                bouton_input_file,
                DOM.br(),
                Bonito.Dropdown(["ACP", "ACP_Husson", "ACP_multivariateStats"]),
                DOM.br(),
                bouton_lancement,
                style = Styles(
                    CSS("background-color" => "#f0f0f0")
                )
            ),

            Col(
                DOM.h3("Zone graphique"),
                DOM.p("Les graphiques s'afficheront ici ;)"),
            )
        )
    )
end

end
