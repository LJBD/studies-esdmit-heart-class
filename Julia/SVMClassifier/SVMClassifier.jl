include("svm.jl")
include("QRSData.jl")


type SVMClassifier
  model::svm_model
end

SVMClassifier() = SVMClassifier(svm_model())

function loadSvmModel(file_name::ASCIIString)
  return svm_load_model(file_name)
end

function createSvmVector(qrs_complex)
  node_list = svm_node[]

  push!(node_list, svm_node(1, qrs_complex.p_onset))
  push!(node_list, svm_node(2, qrs_complex.p_onset_val))
  push!(node_list, svm_node(3, qrs_complex.p_peak))
  push!(node_list, svm_node(4, qrs_complex.p_peak_val))
  push!(node_list, svm_node(5, qrs_complex.p_end))
  push!(node_list, svm_node(6, qrs_complex.p_end_val))
  push!(node_list, svm_node(7, qrs_complex.qrs_onset))
  push!(node_list, svm_node(8, qrs_complex.qrs_onset_val))
  push!(node_list, svm_node(9, qrs_complex.qrs_end))
  push!(node_list, svm_node(10, qrs_complex.qrs_end_val))
  push!(node_list, svm_node(11, qrs_complex.t_peak))
  push!(node_list, svm_node(12, qrs_complex.t_peak_val))
  push!(node_list, svm_node(13, qrs_complex.t_end))
  push!(node_list, svm_node(14, qrs_complex.t_end_val))
  push!(node_list, svm_node(15, qrs_complex.rr_pre_interval))
  push!(node_list, svm_node(16, qrs_complex.rr_post_interval))
  push!(node_list, svm_node(-1, null))

  return node_list
end

#Tylko do testowania
function TESTcreateSvmVector(SV)
  node_list = svm_node[]

  for i = 1:16
    push!(node_list, svm_node(i,SV[i].val))
  end
  push!(node_list, svm_node(-1,null))

  return node_list
end

function predict(svm, qrs_complexes)

  for i = 1:length(qrs_complexes)
    ##-- Convert data
    x = createSvmVector(qrs_complexes[i])
    #Tylko w celach testowych - wektory wziete ze zbioru wektorow nosnych
    #x = TESTcreateSvmVector(svm.model.SV[svm.model.nSV[1]+i-5, :])
    ##-- Classify
    class_id = Int(svm_predict(svm.model, x))
    ##-- Save results
    qrs_complexes[i].class_id = class_id
    #println(class_id)
  end
end
