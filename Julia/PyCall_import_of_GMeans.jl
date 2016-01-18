
ENV["PYTHONPATH"] = "../Python"
using PyCall

@pyimport QRSData
@pyimport GMeans.anderson_darling_test as anderson_darling_test
@pyimport GMeans.gmeans as gmeans_base

a = gmeans_base.GMeans()


