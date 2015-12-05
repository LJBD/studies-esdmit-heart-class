include("svm.jl")
file_name = "C:\\Users\\user\\Desktop\\JunoWorkspace\\kopia"
svm = SVMClassifier()
svm.model = loadSvmModel(file_name)

svm.model.SV
