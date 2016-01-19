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
from scipy import stats
from numpy import mean, var
from math import sqrt, log
# from matplotlib import pyplot


def adstatistic(X):
    """
    Returns the Anderson darling test statistic.
    """
    n = len(X)
    Y = X[:]
    y_bar = mean(Y)
    y_var = var(Y)
    ysd = sqrt(y_var)
    Y = [(y - y_bar)/ysd for y in Y]
    A2 = -n
    S = 0.0
    Y.sort()  # don't forget this!!!
    for i, y in enumerate(Y):
        j = i+1
        p = stats.norm.cdf(y)
        q = 1 - p
        try:
            S += (j+j - 1)*log(p)+ (2 *(n-j)+1)* log(q)
        except ValueError:
            raise Exception('VALUE ERROR: y = %f, p = %f, q = %f' % (y, p, q))
    A2 -= S/n

    A2 *= (1.0 + 4.0/n - 25.0/n**2)
    return A2


def AndersonDarlingTest(X, alpha=0.0001):
    alphas = [0.10, 0.05,  0.025, 0.01, 0.0001]
    critical_value = [0.632, 0.751, 0.870, 1.029, 1.8692]
    try:
        for i, a in enumerate(alphas):
            if abs(alpha - a) < 1.0e-4:
                crit = critical_value[i]
                teststat = adstatistic(X)
                # print('Anderson-Darling test stat: %s, crit: %s' % (teststat, crit))
                return teststat < crit
    except IndexError:
        raise Exception("Significance level not in range. Got %s as alpha, type of alpha: %s." % (alpha, alpha.__class__.__name__))
    return None


if __name__ == "__main__":
    print(stats.norm.cdf(3.0))
    n = 10
    data_x = [stats.norm.rvs() for i in range(n)]
    pyplot.plot(data_x, 'ro')
    print('ANDERSON-DARLING TEST VERDICT:', AndersonDarlingTest(data_x))
    pyplot.show()
