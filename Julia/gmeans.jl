ENV["PYTHONPATH"] = "../Python"
using PyCall
using Logging
using StatsBase
@pyimport QRSData as qrs
@pyimport GMeans.anderson_darling_test as anderson_darling_test
@pyimport GMeans.gmeans as gmeans_base

function Gmeans(normalizedQRSComplexes)  
    info("Starting Gmeans")
    debug(normalizedQRSComplexes[:,1])
    qrs_vector =  qrs.QRSData(normalizedQRSComplexes[:,1])
    for i = 2: size(normalizedQRSComplexes,2)
        qrs_vector=[qrs_vector; qrs.QRSData(normalizedQRSComplexes[:,i])]
    end
    debug("Converted QRS complexes to python QRS.")
    gMeans = gmeans_base.GMeans()
    centroids, labels = gMeans[:cluster_data](qrs_vector)
    info(string("Finished python gMeans centroids size: ", size(centroids), " labels size: ", length(labels)))
    numberOfClasses = sort(union(values(labels)))
    debug(string("Converted labels dictionary to ordered array: ", numberOfClasses))
    allValues = [labels[key] for key in keys(labels)]
    valuesRounded = round(Int64,allValues)
    numberOfElements = counts(valuesRounded, 1:length(numberOfClasses))
    info(string("Number of elements in each cluster", numberOfElements))
    return numberOfElements
end