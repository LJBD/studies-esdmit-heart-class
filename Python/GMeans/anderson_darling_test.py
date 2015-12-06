"""
File  andersondarling.py
author  Dr. Ernesto P. Adorio
           UPDEPP, UP Clarkfield
           ernesto.adorio @ gmail. com
revisions
           oct. 26, 2009 Version 0.0.1 release
license
           Citation requested when using this work in research.
"""
import scipy.stats as stat
from numpy import mean, var
# you may use the already posted version of mean and variance Python routines.
from math import *
from matplotlib import pyplot


pnorm = stat.norm.cdf


def adstatistic(X):
    """
    Returns the Anderson darling test statistic.
    """
    n = len(X)
    Y = X[:]
    ybar = mean(Y)
    yvar = var(Y)
    ysd = sqrt(yvar)
    Y = [(y - ybar)/ysd for y in Y]
    A2 = -n
    S = 0.0
    Y.sort()  # don't forget this!!!
    for i, y in enumerate(Y):
        j = i+1
        p = pnorm(y)
        q = 1 - p
        S += (j+j - 1)*log(p)+ (2 *(n-j)+1)* log(q)
    A2 -= S/n

    A2 *= (1.0 + 4.0/n - 25.0/n**2)
    return A2


def AndersonDarlingTest(X, alpha=0.0001):
    alphas = [0.10, 0.05,  0.025, 0.01, 0.0001]
    critvalue = [0.632, 0.751, 0.870, 1.029, 1.8692]
    try:
        for i, a in enumerate(alphas):
            if abs(alpha - a) < 1.0e-4:
                crit = critvalue[i]
                teststat = adstatistic(X)
                print 'Test stat: %s, crit: %s' % (teststat, crit)
                return teststat < crit
    except:
       raise Exception("Signifance level not in range")
    return None


if __name__ == "__main__":
    print pnorm(3.0)
    n = 10
    data_x = [stat.norm.rvs() for i in range(n)]
    pyplot.plot(data_x, 'ro')
    print 'TEST VERDICT:', AndersonDarlingTest(data_x)
    pyplot.show()