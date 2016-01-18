#Clear workspace
workspace()
include("SVMClassifier.jl")
include("QRSData.jl")

#####################TEST###########################
  #Tylko do testowania
  function createRandomQRSData()
      qrs_data = QRS_DATA()

      qrs_data.p_end = rand()*10*rand()*10*rand()
      qrs_data.p_end_val = rand()*10*rand()*10*rand()
      qrs_data.p_onset = rand()*10*rand()*10*rand()
      qrs_data.p_onset_val = rand()*10*rand()*10*rand()
      qrs_data.p_peak = rand()*10*rand()*10*rand()
      qrs_data.p_peak_val = rand()*10*rand()*10*rand()
      qrs_data.qrs_end = rand()*10*rand()*10*rand()
      qrs_data.qrs_end_val = rand()*10*rand()*10*rand()
      qrs_data.qrs_onset = rand()*10*rand()*10*rand()
      qrs_data.qrs_onset_val = rand()*10*rand()*10*rand()
      qrs_data.rr_post_interval = rand()*10*rand()*10*rand()
      qrs_data.rr_pre_interval = rand()*10*rand()*10*rand()
      qrs_data.r_peak = rand()*10*rand()*10*rand()
      qrs_data.r_peak_value = rand()*10*rand()*10*rand()
      qrs_data.t_end = rand()*10*rand()*10*rand()
      qrs_data.t_end_val = rand()*10*rand()*10*rand()
      qrs_data.t_peak = rand()*10*rand()*10*rand()
      qrs_data.t_peak_val = rand()*10*rand()*10*rand()

      return qrs_data
  end

  #Tylko do testowania
  function createRandomQRSVector(size)
      vector = QRS_DATA[]
      for i = 1:size
          push!(vector, createRandomQRSData())
      end
      return vector
  end

  function printQRSVector(qrs)
    for i=1:length(qrs)
      println(qrs[i],2)
    end
  end
  ###########################################################


  #Read model
  #file_name = "C:\\Users\\user\\Desktop\\JunoWorkspace\\model_copy"
  file_name = string(pwd(),"\\model_copy")
  svm = SVMClassifier()
  svm.model = loadSvmModel(file_name)

  #Random data
  qrs_vector  = createRandomQRSVector(10)

  tic()
  #Classify
  predict(svm, qrs_vector)
  toc()


