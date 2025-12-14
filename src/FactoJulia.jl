module FactoJulia

include("ui/UI.jl")
include("server/Server.jl")

using .Server: launch_app
export launch_app

end
