using Gadfly
using Logging
include("GetQRSFromFile.jl")
include("ConvertToNormalizedQRSComplexesWithId.jl")
#include("dummyGmeans.jl")
include("gmeans.jl")
include("SVMClassifier\\SVMClassifier.jl")

function DataClassifierForPackage(dataId, referenceModel)
    #if Pkg.installed("Gadfly") == nothing
    #    Pkg.add("Gadfly")
    #    Pkg.update()
    #end    
    #GetNormalizedDataFromFile
    

    #TODO TemporaryDate until modulw will be completed
    #dataId = 101
    #path = string(dirname(pwd()),"\\SVM_models\\model101")
    #referenceModel = loadSvmModel(path) #TODO Have problems in svm.jl line 197
    #
    
    folder = string(dataId)
    directory = dirname(pwd())
    QRSDataPath = joinpath(directory, "ReferencyjneDane", folder, "ConvertedQRSRawData.txt")
    QRSClassIdPath = joinpath(directory, "ReferencyjneDane" , folder , "Class_IDs.txt")
    formatSpec = (repmat([Float64], 18)) 
    QRSDataMatrix = GetQRSFromFile(QRSDataPath, formatSpec)
    QRSClassIdVector = GetQRSFromFile(QRSClassIdPath, Float64);
    normalizedQRSComplexes = ConvertToNormalizedQRSComplexesWithId(QRSDataMatrix, QRSClassIdVector);

    
    debug("Creating Y, X matrixes")
    Y = QRSClassIdVector
    X = normalizedQRSComplexes[2:19,:]
    qrs_vector = QRS_DATA[]
    for i = 1: size(normalizedQRSComplexes,2)
        push!(qrs_vector, QRS_DATA(normalizedQRSComplexes[2:19,i]))
    end
    info(string("Created necessary matrixes, and vector: X size: ", size(X), " Y size: ", size(Y), "qrsVector size: ", size(qrs_vector)))
    # Grouping TODO
    lablesOrdered = Gmeans(X)
    p = plot(x=lablesOrdered, Geom.histogram(bincount=size(lablesOrdered,1)), Guide.title("Liczba wektorów cech w poszczególnych klastrach"))

    svm = SVMClassifier()
    svm.model = referenceModel
    predict(svm, qrs_vector)
    
    qrsIdAfterPrediction = []
    for i = 1: size(normalizedQRSComplexes,2)
        qrsIdAfterPrediction = [qrsIdAfterPrediction; qrs_vector[i].class_id]
    end

    p = plot(
        x=qrsIdAfterPrediction,
        Geom.histogram(bincount = 1),
        Guide.title("Klasyfikacja zespołów QRS"))
end