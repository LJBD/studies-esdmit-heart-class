ENV["PYTHONPATH"] = "../Python"
using PyCall
@pyimport QRSData as qrs
@pyimport GMeans.anderson_darling_test as anderson_darling_test
@pyimport GMeans.gmeans as gmeans_base

function Gmeans(normalizedQRSComplexes)    
    qrs_vector =  qrs.QRSData(normalizedQRSComplexes[:,1])
    for i = 2: size(normalizedQRSComplexes,2)
        qrs_vector=[qrs_vector; qrs.QRSData(normalizedQRSComplexes[:,i])]
    end
    qrs_vector
    gMeans = gmeans_base.GMeans()
    centroids, lables = gMeans[:cluster_data](qrs_vector)
    c_idx = [];
    numberOfGroups = length(lables)
    for i = 1:numberOfGroups
        c_idx = [c_idx;lables[i-1]];
    end
    return c_idx
end