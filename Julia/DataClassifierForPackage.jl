function DataClassifierForPackage(dataId, referenceModel)
    if Pkg.installed("Gadfly") == nothing
        Pkg.add("Gadfly")
        Pkg.update()
    end    
    using Gadfly
    include("GetQRSFromFile.jl")
    include("ConvertToNormalizedQRSComplexesWithId.jl")
    include("dummyGmeans.jl")
    include("SVMClassifier\\SVMClassifier.jl")
    #GetNormalizedDataFromFile
    

    #TODO TemporaryDate until modulw will be completed
    #referenceModel = loadSvmModel(ascii(joinpath(pwd(),"SVMClassifier\\model_copy"))) #TODO Have problems in svm.jl line 197
    
    #
    
    folder = string(dataId)
    directory = dirname(pwd())
    QRSDataPath = joinpath(directory, "ReferencyjneDane", folder, "ConvertedQRSRawData.txt")
    QRSClassIdPath = joinpath(directory, "ReferencyjneDane" , folder , "Class_IDs.txt")
    formatSpec = (repmat([Float64], 18)) 
    QRSDataMatrix = GetQRSFromFile(QRSDataPath, formatSpec) #TODO Try to figure how to use formatSpec
    QRSClassIdVector = GetQRSFromFile(QRSClassIdPath, Float64);
    normalizedQRSComplexes = ConvertToNormalizedQRSComplexesWithId(QRSDataMatrix, QRSClassIdVector); #TODO THIS IS NOT A CLASS ONE QRS IS 19x1 ARRAY

    #create matrix of featrures X and vector of corresponding labels Y

    Y = QRSClassIdVector
    X = QRSDataMatrix[:,3:18]
    
    # Grouping TODO
    magicNumber =  0.0005
    groups, centers = dummyGmeans(X, length(X) * magicNumber)
    
    c_idx = [];
    numberOfGroups = length(groups)
    for i = 1:numberOfGroups
       c_idx = [c_idx;i * ones(size(groups[i],1))];
    end

    p = plot(x=c_idx, Geom.histogram(bincount=numberOfGroups), Guide.title("Liczba wektorów cech w poszczególnych klastrach"))

    svm = SVMClassifier()
    svm.model = referenceModel
    predict(svm, qrs_vector)
end