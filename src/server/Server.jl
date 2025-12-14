module Server

using Bonito
using ..UI

function launch_app()
    app = App() do
        UI.main_ui()
    end

    display(app)
end

end
