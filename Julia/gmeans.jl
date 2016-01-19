ENV["PYTHONPATH"] = "../Python"
using PyCall
using Logging
@pyimport QRSData as qrs
@pyimport GMeans.anderson_darling_test as anderson_darling_test
@pyimport GMeans.gmeans as gmeans_base

function Gmeans(normalizedQRSComplexes)  
    info("Starting Gmeans")
    qrs_vector =  qrs.QRSData(normalizedQRSComplexes[:,1])
    for i = 2: size(normalizedQRSComplexes,2)
        qrs_vector=[qrs_vector; qrs.QRSData(normalizedQRSComplexes[:,i])]
    end
    debug("Converted QRS complexes to python QRS.")
    gMeans = gmeans_base.GMeans("DEBUG")
    centroids, lables = gMeans[:cluster_data](qrs_vector)
    info(str("Finished python gMeans centroids size: ", size(centroids), " labels size: ", size(labels)))
    c_idx = [];
    numberOfGroups = length(lables)
    for i = 1:numberOfGroups
        c_idx = [c_idx;lables[i-1]];
    end
    debug("Converted labels dictionary to ordered array")
    return c_idx
end