function DataClassifierForPackage(dataId, referenceModel)
    
    include("GetQRSFromFile.jl")
    include("ConvertToNormalizedQRSComplexesWithId.jl")
    
    #GetNormalizedDataFromFile
    
    folder = string(101)
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
end