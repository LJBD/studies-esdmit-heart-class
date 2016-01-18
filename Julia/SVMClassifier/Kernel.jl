
function k_function(x, y, param)
  kernel_type = param.kernel_type
  #RBF
  if kernel_type == 3

    sum = 0
    for i=1:length(x)
      sum += (x[i]-y[i])*(x[i]-y[i])
    end

    return exp(-param.gamma*sum)

  else
    error("ERROR: This type of kernel function is not supported yet")
  end
  return 0
end

