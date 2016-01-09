__author__ = 'Krystian'
from math import exp, tanh
from enum import Enum


class KernelTypes(Enum):
    LINEAR = 0
    POLY = 1
    RBF = 2
    SIGMOID = 3
    PRECOMPUTED = 4


def dot(x, y):
    sum = 0
    ix = 0
    iy = 0
    while x[ix].index != -1 and y[iy].index != -1:
        if x[ix].index == y[iy].index:
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
    while True:
        if t % 2 == 1:
            ret *= tmp
        tmp *= tmp
        t /= 2
        if t <= 0:
            break
    return ret


def k_function(x, y, param):

    kernel_type = KernelTypes(param.kernel_type)

    if kernel_type == KernelTypes.LINEAR:
        return dot(x, y)

    elif kernel_type == KernelTypes.POLY:
        return powi(param.gamma*dot(x, y) + param.coef0, param.degree)

    elif kernel_type == KernelTypes.RBF:
        sum = 0
        ix = 0
        iy = 0
        while x[ix].index != -1 and y[iy].index != -1:
            if x[ix].index == y[iy].index:
                d = x[ix].value - y[iy].value
                sum += d*d
                ix += 1
                iy += 1
            else:
                if x[ix].index > y[iy].index:
                    sum += y[iy].value*y[iy].value
                    iy += 1
                else:
                    sum += x[ix].value*x[ix].value
                    ix += 1
        while x[ix].index != -1:
            sum += x[ix].value * x[ix].value
            ix += 1
        while y[iy].index != -1:
            sum += y[iy].value * y[iy].value
            iy += 1
        return exp(-param.gamma*sum)

    elif kernel_type == KernelTypes.SIGMOID:
        return tanh(param.gamma*dot(x, y) + param.coef0)

    elif kernel_type == KernelTypes.PRECOMPUTED:
        # To nie ma prawa dzialac
        # return x[int(y[0].value)].value
        print("ERROR: PRECOMPUTED kernel_type\nin k_function")
        input("Press any key to continue...")
        return None

    else:
        print("ERROR: Unreachable\nin k_function")
        return 0
