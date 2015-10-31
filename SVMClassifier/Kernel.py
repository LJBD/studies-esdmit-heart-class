__author__ = 'Krystian'

from enum import Enum
class KernelTypes(Enum):
    LINEAR = 0
    POLY = 1
    RBF = 2
    SIGMOID = 3
    PRECOMPUTED = 4

def dot(x,y):
    sum = 0
    ix = 0
    iy = 0
    while x[ix].index != -1 and y[iy].index != -1:
        if(x[ix].index == y[iy].index):
            sum += x[ix].value * y[iy].value
            ix += 1
            iy += 1
        else:
            if x[ix].index > y[iy].index:
                iy += 1
            else:
                ix += 1
    return sum


def powi(base, times):
    tmp = base
    ret = 1.0
    t = times
    while t>0:
        if t%2==1:
            ret *= tmp
        tmp = tmp*tmp
        t = int(t / 2)
	return ret


def k_function(x, y, param):

    kernel_type = param.kernel_type

    if kernel_type == KernelTypes.LINEAR:
        return dot(x,y)

    elif kernel_type == KernelTypes.POLY:
        return powi(param.gamma*dot(x, y) + param.coef0, param.degree)

    elif kernel_type == KernelTypes.RBF:
        return None

    elif kernel_type == KernelTypes.SIGMOID:
        return None

    elif kernel_type == KernelTypes.PRECOMPUTED:
        return None

    else:
        return 0
