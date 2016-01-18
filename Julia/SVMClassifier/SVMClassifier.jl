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
  node_list = Float64[]

  push!(node_list, qrs_complex.p_onset)
  push!(node_list, qrs_complex.p_onset_val)
  push!(node_list, qrs_complex.p_peak)
  push!(node_list, qrs_complex.p_peak_val)
  push!(node_list, qrs_complex.p_end)
  push!(node_list, qrs_complex.p_end_val)
  push!(node_list, qrs_complex.qrs_onset)
  push!(node_list, qrs_complex.qrs_onset_val)
  push!(node_list, qrs_complex.qrs_end)
  push!(node_list, qrs_complex.qrs_end_val)
  push!(node_list, qrs_complex.t_peak)
  push!(node_list, qrs_complex.t_peak_val)
  push!(node_list, qrs_complex.t_end)
  push!(node_list, qrs_complex.t_end_val)
  push!(node_list, qrs_complex.rr_pre_interval)
  push!(node_list, qrs_complex.rr_post_interval)

  return node_list
end

#Tylko do testowania
function TESTcreateSvmVector(SV)
  node_list = Float64[]

  for i = 1:16
    push!(node_list, SV[i])
  end

  return node_list
end

function predict(svm, qrs_complexes)

  for i = 1:length(qrs_complexes)
    ##-- Convert data
    x = createSvmVector(qrs_complexes[i])
    ##-- Classify
    class_id = Int(svm_predict(svm.model, x))
    ##-- Save results
    qrs_complexes[i].class_id = class_id
    println(class_id)
  end
end
