include("SVMClassifier/SVMClassifier.jl")
if Pkg.installed("Logging") == nothing
   Pkg.add("Logging")
   Pkg.update()
end
using Logging
Logging.configure(filename="logfile.log")
Logging.configure(level=DEBUG)
dataId = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 113, 114, 115, 116, 117, 119, 121, 122, 123, 124, 200, 201, 202, 205, 208, 209, 221, 222, 223, 230, 231, 232, 233, 234];
path = string(dirname(pwd()),"/SVM_models/model101")
include("DataClassifierForPackage.jl")
referenceModel = loadSvmModel(path) #TODO Have problems in svm.jl line 197

fid = open("log", "a")
write(fid, "\n\n")
write(fid, string(now()))
write(fid, "\n--------------------------------------\n")
for i = 1:length(dataId)
  tic()
  classId = DataClassifierForPackage(dataId[i], referenceModel)
  time = toc()
  write(fid, "Package: ", string(dataId[i]), ", Execution time: ", string(time),"\n")
end

close(fid)
