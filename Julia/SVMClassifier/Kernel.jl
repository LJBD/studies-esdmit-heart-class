
function k_function(x, y, param)
  kernel_type = param.kernel_type

  #LINEAR
  if kernel_type == 1
    error("Not implemented exception")
  #POLY
  elseif kernel_type == 2
    error("Not implemented exception")
  #RBF
  elseif kernel_type == 3

    sum = 0
    ix = 1
    iy = 1
    while x[ix].idx != -1 && y[iy].idx != -1
      if x[ix].idx == y[iy].idx
        d = x[ix].val - y[iy].val
        sum += d*d
        ix += 1
        iy += 1
      else
        if x[ix].idx > y[iy].idx
          sum += y[iy].val*y[iy].val
          iy += 1
        else
          sum += x[ix].val*x[ix].val
          ix += 1
        end
      end
    end

    while x[ix].idx != -1
      sum += x[ix].val * x[ix].val
      ix += 1
    end
    while y[iy].idx != -1
      sum += y[iy].val * y[iy].val
      iy += 1
    end

    return exp(-param.gamma*sum)

  #SIGMOID
  elseif kernel_type == 4
    error("Not implemented exception")
  #PRECOMPUTED
  else kernel_type == 5
    error("Not implemented exception")
  end

  return 0
end

