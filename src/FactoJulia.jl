module FactoJulia

include("analyses/acp_Husson.jl")
include("ui/UI.jl")
include("server/Server.jl")

using .PCAAnalysis: compute_PCA
using .UI
using .Server: launch_app

export launch_app

end
