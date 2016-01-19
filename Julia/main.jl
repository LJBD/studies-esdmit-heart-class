include("SVMClassifier/SVMClassifier.jl")
if Pkg.installed("Logging") == nothing
   Pkg.add("Logging")
   Pkg.update()
end
using Logging
Logging.configure(filename="logfile.log")
Logging.configure(level=DEBUG)
dataId = 117
path = string(dirname(pwd()),"/SVM_models/model101")
include("DataClassifierForPackage.jl")
referenceModel = loadSvmModel(path) #TODO Have problems in svm.jl line 197
DataClassifierForPackage(dataId, referenceModel)
