using Pkg
cd(@__DIR__)
using .PCAApp
res = run_pca("student_exam_scores.csv")
screeplot(res.pca)
plot_individuals(res.scores)
plot_variables(res.loadings, res.columns)
