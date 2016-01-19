include("GetQRSFromFile.jl")
Pkg.add("StatsBase")
using Gadfly
using StatsBase
dataId = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 113, 114, 115, 116, 117, 119, 121, 122, 123, 124, 200, 201, 202, 203, 205, 208, 209, 221, 222, 223, 230, 231, 232, 233, 234];
directory = dirname(pwd())
for i = 1:length(dataId)
    QRSClassIdPath = joinpath(directory, "ReferencyjneDane" , string(dataId[i]) , "Class_IDs.txt")
    QRSClassIdVector = GetQRSFromFile(QRSClassIdPath, Float64);
    QRSClassIdVectorSorted = sort(union(QRSClassIdVector))
    clusterElements = counts(round(Int64,QRSClassIdVector), int(QRSClassIdVectorSorted[end]))
    p = plot(y = clusterElements)
    draw(SVG(string(dataId[i],".svg"), 4inch, 3inch), p)
end