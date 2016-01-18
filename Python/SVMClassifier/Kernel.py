from math import exp, tanh
from enum import Enum
__author__ = 'Krystian'


class KernelTypes(Enum):
    LINEAR = 0
    POLY = 1
    RBF = 2
    SIGMOID = 3
    PRECOMPUTED = 4


def k_function(x, y, param):
    kernel_type = KernelTypes(param.kernel_type)
    if kernel_type == KernelTypes.RBF:
        sum = 0
        for i in range(0, y.__len__()):
            sum += (x[i]-y[i])*(x[i]-y[i])

        return exp(-param.gamma*sum)

    else:
        print ("ERROR: This type of kernel function is not supported yet")
        return 0
