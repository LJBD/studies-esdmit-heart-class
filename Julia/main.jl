include("SVMClassifier/SVMClassifier.jl")

dataId = 101
path = string(dirname(pwd()),"\\SVM_models\\model101")
include("DataClassifierForPackage.jl")
referenceModel = loadSvmModel(path) #TODO Have problems in svm.jl line 197
DataClassifierForPackage(dataId, referenceModel)