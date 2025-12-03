module FactoJulia

# Packages
using CSV, DataFrames, Statistics, LinearAlgebra, MultivariateStats
using Bonito       # reactivity
using Printf, Plots

# Include PCA functions
include("pca.jl")

# Export the functions
export PCA_, scree_plot, plot_PCA_individuals, plot_PCA_variables, print_matrix

end
