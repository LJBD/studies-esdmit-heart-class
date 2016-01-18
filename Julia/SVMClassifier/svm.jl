include("Kernel.jl")


type svm_parameter
  svm_type
  kernel_type
  degree
  gamma
  coef0
end


type svm_model
  rho
  label
  nSV
  probA
  probB
  param::svm_parameter
  sv_indices
  l
  sv_coef
  SV
  free_sv
  nr_class
end


svm_model() = svm_model(
    Float64[], #rho
    Int64[], #label
    Int64[], #nSV
    Float64[], #probA
    Float64[], #probB
    svm_parameter(
      null, #svm_type
      null, #kernel_type
      null, #degree
      null, #gamma
      null  #coef0
    ),
    null, #sv_indices
    null, #l
    null, #sv_coefs
    null, #SV
    -1,  #free_sv
    null #nr_class
  )



function GetNextWord(fp)
  word = ""
  c = read(fp, Char)
  while c=='\n' ||  c==' ' || c=='\r'
    c = read(fp, Char)
  end

  while true
    word = string(word,c)
    c = read(fp, Char)
    if c == '\n' || c == ' ' || c == '\0' #|| c=='\r'
      break
    end
  end
  seek(fp, position(fp)-1)
  return strip(word)
end

svm_type_table = ["c_svc", "nu_svc", "one_class", "epsilon_svr", "nu_svr", null]
kernel_type_table = ["linear", "polynomial", "rbf", "sigmoid", "precomputed", null]

function read_model_header(fp, model::svm_model)
  cmd = ""
  while cmd != "\0"
    cmd = GetNextWord(fp)

    if(cmd=="svm_type")
      cmd = GetNextWord(fp)
      for i = 1:length(svm_type_table)
        if svm_type_table[i] == cmd
          model.param.svm_type = i
          break
        end
        if svm_type_table[i] == null
          print(string("ERROR unknown svm type - ", cmd))
          return false
        end
      end
    elseif(cmd == "kernel_type")
      cmd = GetNextWord(fp)
      for i = 1:length(kernel_type_table)
        if kernel_type_table[i] == cmd
          model.param.kernel_type = i
          break
        end
        if kernel_type_table[i] == null
          print("ERROR unknown kernel function.")
          return false
        end
      end
    elseif(cmd == "degree")
      cmd = GetNextWord(fp)
      model.param.degree = int(cmd)

    elseif(cmd == "gamma")
      cmd = GetNextWord(fp)
      model.param.gamma = float(cmd)

    elseif(cmd == "coef0")
      cmd = GetNextWord(fp)
      model.param.coef0 = float(cmd)

    elseif(cmd == "nr_class")
      cmd = GetNextWord(fp)
      model.nr_class = int(cmd)

    elseif(cmd == "total_sv")
      cmd = GetNextWord(fp)
      model.l = int(cmd)

    elseif(cmd == "rho")
      n = model.nr_class*(model.nr_class-1)/2
      for i = 1:n
        cmd = GetNextWord(fp)
        push!(model.rho, float(cmd))
      end

    elseif(cmd == "label")
      n = model.nr_class
      for i=1:n
        cmd = GetNextWord(fp)
        push!(model.label, int(cmd))
      end

    elseif(cmd == "probA")
      n = model.nr_class*(model.nr_class-1)/2
      for i = 1:n
        cmd = GetNextWord(fp)
        push!(model.probA,float(cmd))
      end

    elseif(cmd == "probB")
      n = model.nr_class*(model.nr_class-1)/2
      for i = 1:n
        cmd = GetNextWord(fp)
        push!(model.probB,float(cmd))
      end

    elseif(cmd == "nr_sv")
      for i = 1:int(model.nr_class)
        cmd = GetNextWord(fp)
        push!(model.nSV, int(cmd))
      end

    elseif(cmd=="SV")
      while true
        c = read(fp, Char)
        if c=='\n' || c==null || c=='\0'
          break
        end
      end
      break
    else
      print(string("ERROR  Unknown text in model file:", cmd))
      return false
    end
  end
  return true
end


function svm_load_model(file_name::ASCIIString)
  fp = open(file_name)
  # read parameters
  model = svm_model()
  # read header
  b = read_model_header(fp, model)
  if b==false
    print("ERROR fscanf failed to read model")
  end

  # read sv_coef and SV
  elements = 0
  pos = position(fp)

  line = readline(fp)
  while line != ""
      p = split(line, ':')
      elements += length(p)-1
      line = readline(fp)
  end
  elements += model.l
  seek(fp, pos)

  m = model.nr_class - 1
  l = model.l

  max = 16

  model.sv_coef = fill(float(0), (m,l))
  model.SV = fill(float(0), (l+1,max))

  for i = 1:l
    line = readline(fp)
    p = split(line, ' ')

    for k = 1:m
      model.sv_coef[k,i] = round(float(p[k]), 6)
    end

    for j = m+1:max+m
      k = split(p[j],':')
      idx = int(k[1])
      val = float(k[2])
      model.SV[i, j - m] = val
    end

  end

  model.free_sv = 1

  close(fp)
  return model
end


function svm_predict(model, x)
  dec_values = Float64[]

  svmType = model.param.svm_type

  #C_SVC
  if svmType == 1
    nr_class = model.nr_class
    l = model.l

    kvalue = Float64[]
    for i = 1:l
      res = float(k_function(x, model.SV[i,:], model.param))
      push!(kvalue, res)
    end

    start = Int64[]
    push!(start, 0)
    for i = 2:nr_class
      push!(start, start[i-1] + model.nSV[i-1])
    end

    vote = Int64[]
    for i = 1:nr_class
      push!(vote, 0)
    end

    p = 1
    for i = 1:nr_class
      for j = i+1:nr_class
        sum = 0
        si = start[i]
        sj = start[j]
        ci = model.nSV[i]
        cj = model.nSV[j]

        coef1 = model.sv_coef[j - 1, :]
        coef2 = model.sv_coef[i, :]

        for k = 1:ci
          sum += coef1[si + k] * kvalue[si + k]
        end
        for k = 1:cj
          sum += coef2[sj + k] * kvalue[sj + k]
        end

        sum -= model.rho[p]
        push!(dec_values, sum)

        if dec_values[p] > 0
          vote[i] += 1
        else
          vote[j] += 1
        end
        p += 1
      end
    end
    vote_max_idx = 1
    for i = 2:nr_class
      if vote[i] > vote[vote_max_idx]
        vote_max_idx = i
      end
    end
    return model.label[vote_max_idx]
  else
    error("ERROR: This type of SVM is not supported yet")
  end

  return -1
end





